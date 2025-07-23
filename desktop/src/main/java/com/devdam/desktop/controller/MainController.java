package com.devdam.desktop.controller;

import com.devdam.desktop.model.DependencyAnalysis;
import com.devdam.desktop.model.PackageConfiguration;
import com.devdam.desktop.model.PackagingResult;
import com.devdam.desktop.service.ConfigurationService;
import com.devdam.desktop.service.DependencyAnalysisService;
import com.devdam.desktop.service.PackagingService;
import javafx.application.Platform;
import javafx.collections.FXCollections;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.*;
import javafx.scene.layout.VBox;
import javafx.stage.DirectoryChooser;
import javafx.stage.FileChooser;
import lombok.extern.slf4j.Slf4j;
import org.controlsfx.control.CheckListView;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.File;
import java.net.URL;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Component
public class MainController implements Initializable {

    // File Selection
    @FXML private TextField jarFileField;
    @FXML private Button browseJarButton;
    @FXML private TextField iconFileField;
    @FXML private Button browseIconButton;
    @FXML private TextField outputDirField;
    @FXML private Button browseOutputButton;

    // Application Configuration
    @FXML private TextField appNameField;
    @FXML private TextField versionField;
    @FXML private TextField mainClassField;
    @FXML private TextField vendorField;
    @FXML private TextArea descriptionArea;
    @FXML private TextField copyrightField;

    // Platform and Format
    @FXML private ComboBox<PackageConfiguration.TargetPlatform> targetPlatformCombo;
    @FXML private ComboBox<PackageConfiguration.OutputFormat> outputFormatCombo;

    // JLink Configuration
    @FXML private CheckBox enableJLinkCheck;
    @FXML private CheckListView<String> modulesListView;
    @FXML private TextField customModuleField;
    @FXML private Button addModuleButton;

    // Advanced Options
    @FXML private TextArea jvmArgsArea;
    @FXML private TextArea appArgsArea;

    // Actions
    @FXML private Button analyzeButton;
    @FXML private Button packageButton;
    @FXML private Button resetButton;
    @FXML private ProgressBar progressBar;
    @FXML private Label statusLabel;

    // Console
    @FXML private TextArea consoleArea;
    @FXML private Button clearConsoleButton;
    @FXML private Button exportLogsButton;

    // Presets
    @FXML private ComboBox<String> presetsCombo;
    @FXML private TextField presetNameField;
    @FXML private Button savePresetButton;
    @FXML private Button loadPresetButton;
    @FXML private Button deletePresetButton;

    // Theme
    @FXML private CheckMenuItem darkThemeCheck;
    @FXML private VBox rootPane;

    @Autowired
    private DependencyAnalysisService dependencyService;

    @Autowired
    private PackagingService packagingService;

    @Autowired
    private ConfigurationService configurationService;

    // Application properties
    @Value("${application.description}")
    private String applicationDescription;
    
    @Value("${application.version}")
    private String applicationVersion;

    private PackageConfiguration currentConfig;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        initializeComponents();
        loadDefaultConfiguration();
        refreshPresets();
        updateToolAvailability();
    }

    private void initializeComponents() {
        // Initialize ComboBoxes
        List<PackageConfiguration.TargetPlatform> sortedPlatforms = Arrays.asList(PackageConfiguration.TargetPlatform.values());
        sortedPlatforms.sort((a, b) -> a.toString().compareToIgnoreCase(b.toString()));
        targetPlatformCombo.setItems(FXCollections.observableArrayList(sortedPlatforms));
        
        List<PackageConfiguration.OutputFormat> sortedFormats = Arrays.asList(PackageConfiguration.OutputFormat.values());
        sortedFormats.sort((a, b) -> a.toString().compareToIgnoreCase(b.toString()));
        outputFormatCombo.setItems(FXCollections.observableArrayList(sortedFormats));

        // Set default values
        targetPlatformCombo.setValue(PackageConfiguration.TargetPlatform.CURRENT);
        outputFormatCombo.setValue(PackageConfiguration.OutputFormat.APP_IMAGE);

        // Initialize modules list
        modulesListView.setItems(FXCollections.observableArrayList(dependencyService.getSuggestedModules()));

        // Set up event handlers
        setupEventHandlers();

        // Initialize progress bar
        progressBar.setVisible(false);
        progressBar.setProgress(0);

        // Set initial status
        statusLabel.setText("Ready");
    }

    private void setupEventHandlers() {
        // File browsing
        browseJarButton.setOnAction(e -> browseJarFile());
        browseIconButton.setOnAction(e -> browseIconFile());
        browseOutputButton.setOnAction(e -> browseOutputDirectory());

        // Actions
        analyzeButton.setOnAction(e -> analyzeJar());
        packageButton.setOnAction(e -> packageApplication());
        resetButton.setOnAction(e -> resetForm());

        // Console
        clearConsoleButton.setOnAction(e -> consoleArea.clear());
        exportLogsButton.setOnAction(e -> exportLogs());

        // Modules
        addModuleButton.setOnAction(e -> addCustomModule());

        // Presets
        savePresetButton.setOnAction(e -> savePreset());
        loadPresetButton.setOnAction(e -> loadPreset());
        deletePresetButton.setOnAction(e -> deletePreset());

        // Theme
        darkThemeCheck.setOnAction(e -> toggleTheme());

        // Auto-update output directory when app name changes
        appNameField.textProperty().addListener((observable, oldValue, newValue) -> {
            if (newValue != null && !newValue.trim().isEmpty() && !newValue.equals(oldValue)) {
                setOutputDirectoryFromAppName(newValue.trim());
            }
        });

        // Enable/disable JLink options
        enableJLinkCheck.setOnAction(e -> {
            boolean enabled = enableJLinkCheck.isSelected();
            modulesListView.setDisable(!enabled);
            customModuleField.setDisable(!enabled);
            addModuleButton.setDisable(!enabled);
        });
    }

    private void loadDefaultConfiguration() {
        currentConfig = configurationService.getDefaultConfiguration();
        updateUIFromConfiguration(currentConfig);
    }

    private void updateUIFromConfiguration(PackageConfiguration config) {
        // Clear or set file fields
        jarFileField.setText(config.getJarFile() != null ? config.getJarFile().toString() : "");
        iconFileField.setText(config.getIconFile() != null ? config.getIconFile().toString() : "");
        outputDirField.setText(config.getOutputDirectory() != null ? config.getOutputDirectory().toString() : "");

        // Clear or set application configuration fields
        appNameField.setText(config.getAppName() != null ? config.getAppName() : "");
        versionField.setText(config.getVersion() != null ? config.getVersion() : "");
        mainClassField.setText(config.getMainClass() != null ? config.getMainClass() : "");
        vendorField.setText(config.getVendor() != null ? config.getVendor() : "");
        descriptionArea.setText(config.getDescription() != null ? config.getDescription() : "");
        copyrightField.setText(config.getCopyright() != null ? config.getCopyright() : "");

        // Set platform and format (with defaults)
        targetPlatformCombo.setValue(config.getTargetPlatform() != null ? config.getTargetPlatform() : PackageConfiguration.TargetPlatform.CURRENT);
        outputFormatCombo.setValue(config.getOutputFormat() != null ? config.getOutputFormat() : PackageConfiguration.OutputFormat.APP_IMAGE);

        // Set JLink configuration
        enableJLinkCheck.setSelected(config.isEnableJLink());

        // Clear or set advanced options
        jvmArgsArea.setText(config.getJvmArgs() != null ? String.join("\n", config.getJvmArgs()) : "");
        appArgsArea.setText(config.getAppArgs() != null ? String.join("\n", config.getAppArgs()) : "");

        // Clear and update modules selection
        modulesListView.getCheckModel().clearChecks();
        if (config.getRequiredModules() != null) {
            for (String module : config.getRequiredModules()) {
                int index = modulesListView.getItems().indexOf(module);
                if (index >= 0) {
                    modulesListView.getCheckModel().check(index);
                }
            }
        }
    }

    private PackageConfiguration getConfigurationFromUI() {
        Set<String> selectedModules = modulesListView.getCheckModel().getCheckedItems()
                .stream().collect(Collectors.toSet());

        List<String> jvmArgs = Arrays.stream(jvmArgsArea.getText().split("\n"))
                .filter(line -> !line.trim().isEmpty())
                .collect(Collectors.toList());

        List<String> appArgs = Arrays.stream(appArgsArea.getText().split("\n"))
                .filter(line -> !line.trim().isEmpty())
                .collect(Collectors.toList());

        return PackageConfiguration.builder()
                .jarFile(jarFileField.getText().isEmpty() ? null : Paths.get(jarFileField.getText()))
                .iconFile(iconFileField.getText().isEmpty() ? null : Paths.get(iconFileField.getText()))
                .outputDirectory(outputDirField.getText().isEmpty() ? null : Paths.get(outputDirField.getText()))
                .appName(appNameField.getText())
                .version(versionField.getText())
                .mainClass(mainClassField.getText())
                .vendor(vendorField.getText())
                .description(descriptionArea.getText())
                .copyright(copyrightField.getText())
                .targetPlatform(targetPlatformCombo.getValue())
                .outputFormat(outputFormatCombo.getValue())
                .enableJLink(enableJLinkCheck.isSelected())
                .requiredModules(selectedModules)
                .jvmArgs(jvmArgs.isEmpty() ? null : jvmArgs)
                .appArgs(appArgs.isEmpty() ? null : appArgs)
                .build();
    }

    private void browseJarFile() {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Select JAR File");
        fileChooser.getExtensionFilters().add(new FileChooser.ExtensionFilter("JAR Files", "*.jar"));

        File file = fileChooser.showOpenDialog(jarFileField.getScene().getWindow());
        if (file != null) {
            jarFileField.setText(file.getAbsolutePath());
            
            // Auto-populate application fields based on JAR filename
            populateFieldsFromJarFile(file);
        }
    }
    
    private void populateFieldsFromJarFile(File jarFile) {
        try {
            String fileName = jarFile.getName();
            
            // Remove .jar extension
            if (fileName.toLowerCase().endsWith(".jar")) {
                fileName = fileName.substring(0, fileName.length() - 4);
            }
            
            // Extract application name and version
            String appName = "";
            String version = "";
            
            // Handle common patterns like "app-name-1.0.0" or "appname-version"
            String[] parts = fileName.split("-");
            if (parts.length >= 2) {
                // Look for version pattern (numbers and dots)
                for (int i = parts.length - 1; i >= 0; i--) {
                    if (parts[i].matches("\\d+(\\.\\d+)*.*")) {
                        // Found version, everything before is app name
                        version = parts[i];
                        appName = String.join("-", Arrays.copyOfRange(parts, 0, i));
                        break;
                    }
                }
                
                // If no version found, treat the entire filename as app name
                if (appName.isEmpty()) {
                    appName = fileName; // Use the whole filename as app name
                }
            } else {
                appName = fileName;
            }
            
            // Format application name (convert to Title Case)
            if (!appName.isEmpty()) {
                appName = formatApplicationName(appName);
                appNameField.setText(appName);
                
                // Set output directory based on app name
                setOutputDirectoryFromAppName(appName);
                
                // Update preset name field with app name + "Config"
                updatePresetNameField(appName);
            }
            
            // Set version if found (always update)
            if (!version.isEmpty()) {
                versionField.setText(version);
                log.info("Auto-populated version: '{}'", version);
            }
            
            // Set default vendor (always update)
            vendorField.setText("DevDam");
            log.info("Auto-populated vendor: 'DevDam'");
            
            // Set application description from properties (always update)
            descriptionArea.setText(applicationDescription);
            log.info("Auto-populated description: '{}'", applicationDescription);
            
            log.info("Auto-populated fields from JAR file: {} -> App Name: '{}', Version: '{}'", 
                    fileName, appName, version);
                    
        } catch (Exception e) {
            log.warn("Could not auto-populate fields from JAR file: {}", jarFile.getName(), e);
        }
    }
    
    private String formatApplicationName(String name) {
        // Replace hyphens and underscores with spaces
        name = name.replace("-", " ").replace("_", " ");
        
        // Convert to title case
        String[] words = name.split("\\s+");
        StringBuilder formatted = new StringBuilder();
        
        for (String word : words) {
            if (!word.isEmpty()) {
                if (formatted.length() > 0) {
                    formatted.append(" ");
                }
                formatted.append(Character.toUpperCase(word.charAt(0)));
                if (word.length() > 1) {
                    formatted.append(word.substring(1).toLowerCase());
                }
            }
        }
        
        return formatted.toString();
    }
    
    private void setOutputDirectoryFromAppName(String appName) {
        try {
            // Remove spaces and special characters for folder name
            String folderName = appName.replaceAll("\\s+", "").replaceAll("[^a-zA-Z0-9]", "") + "BuildOutput";
            
            // Get current working directory or user home as base
            String baseDir = System.getProperty("user.home");
            Path outputPath = Paths.get(baseDir, "Desktop", folderName);
            
            outputDirField.setText(outputPath.toString());
            log.info("Auto-set output directory: '{}'", outputPath.toString());
            
        } catch (Exception e) {
            log.warn("Could not set output directory from app name: {}", appName, e);
        }
    }

    private void browseIconFile() {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Select Icon File");
        fileChooser.getExtensionFilters().addAll(
                new FileChooser.ExtensionFilter("Image Files", "*.png", "*.jpg", "*.jpeg", "*.gif", "*.ico"),
                new FileChooser.ExtensionFilter("PNG Files", "*.png"),
                new FileChooser.ExtensionFilter("ICO Files", "*.ico")
        );

        File file = fileChooser.showOpenDialog(iconFileField.getScene().getWindow());
        if (file != null) {
            iconFileField.setText(file.getAbsolutePath());
        }
    }

    private void browseOutputDirectory() {
        DirectoryChooser directoryChooser = new DirectoryChooser();
        directoryChooser.setTitle("Select Output Directory");

        File directory = directoryChooser.showDialog(outputDirField.getScene().getWindow());
        if (directory != null) {
            outputDirField.setText(directory.getAbsolutePath());
        }
    }

    private void analyzeJar() {
        String jarPath = jarFileField.getText();
        if (jarPath.isEmpty()) {
            showAlert(Alert.AlertType.WARNING, "Warning", "Please select a JAR file first.");
            return;
        }

        Path jarFile = Paths.get(jarPath);
        if (!jarFile.toFile().exists()) {
            showAlert(Alert.AlertType.ERROR, "Error", "Selected JAR file does not exist.");
            return;
        }

        Task<DependencyAnalysis> analyzeTask = new Task<DependencyAnalysis>() {
            @Override
            protected DependencyAnalysis call() throws Exception {
                updateMessage("Analyzing JAR dependencies...");
                return dependencyService.analyzeJar(jarFile);
            }

            @Override
            protected void succeeded() {
                DependencyAnalysis analysis = getValue();
                Platform.runLater(() -> {
                    statusLabel.textProperty().unbind();
                    handleAnalysisResult(analysis);
                    statusLabel.setText("Analysis completed");
                });
            }

            @Override
            protected void failed() {
                Platform.runLater(() -> {
                    statusLabel.textProperty().unbind();
                    logToConsole("Analysis failed: " + getException().getMessage());
                    statusLabel.setText("Analysis failed");
                });
            }
        };

        statusLabel.textProperty().bind(analyzeTask.messageProperty());
        new Thread(analyzeTask).start();
    }

    private void handleAnalysisResult(DependencyAnalysis analysis) {
        if (analysis.isSuccess()) {
            logToConsole("Analysis completed successfully!");
            logToConsole("JAR: " + analysis.getJarPath());

            // Auto-populate application fields from JAR filename (similar to file selection)
            if (analysis.getJarPath() != null) {
                try {
                    File jarFile = new File(analysis.getJarPath());
                    populateFieldsFromJarFile(jarFile);
                    logToConsole("Auto-populated app config fields from JAR filename");
                } catch (Exception e) {
                    log.warn("Could not auto-populate fields from JAR filename during analysis", e);
                }
            }

            if (analysis.getMainClass() != null) {
                mainClassField.setText(analysis.getMainClass());
                logToConsole("Detected main class: " + analysis.getMainClass());
            }
            
            // If there's a Start-Class, use it for vendor extraction and display
            if (analysis.getStartClass() != null) {
                mainClassField.setText(analysis.getStartClass());
                logToConsole("Detected start class (using for main class): " + analysis.getStartClass());
                
                // Extract vendor from start class package
                String vendorFromPackage = extractVendorFromMainClass(analysis.getStartClass());
                if (vendorFromPackage != null && !vendorFromPackage.trim().isEmpty()) {
                    vendorField.setText(vendorFromPackage);
                    logToConsole("Set vendor from start class package: " + vendorFromPackage);
                }
            } else if (analysis.getMainClass() != null) {
                // Fallback to main class for vendor extraction if no start class
                String vendorFromPackage = extractVendorFromMainClass(analysis.getMainClass());
                if (vendorFromPackage != null && !vendorFromPackage.trim().isEmpty()) {
                    vendorField.setText(vendorFromPackage);
                    logToConsole("Set vendor from main class package: " + vendorFromPackage);
                }
            }

            // Populate app config fields from manifest information (this will override filename-based values if available)
            if (analysis.hasManifestInfo()) {
                populateAppConfigFromManifest(analysis);
            }

            if (analysis.hasRequiredModules()) {
                logToConsole("Required modules: " + analysis.getRequiredModules().size());
                for (String module : analysis.getRequiredModules()) {
                    logToConsole("  - " + module);
                }

                // Update modules list and select required ones
                updateModulesList(analysis.getRequiredModules());
            }

            if (analysis.hasMissingModules()) {
                logToConsole("WARNING: Missing modules detected:");
                for (String module : analysis.getMissingModules()) {
                    logToConsole("  - " + module + " (not available in current JDK)");
                }
            }
        } else {
            logToConsole("Analysis failed: " + analysis.getErrorMessage());
            showAlert(Alert.AlertType.ERROR, "Analysis Failed", analysis.getErrorMessage());
        }
    }
    
    private void populateAppConfigFromManifest(DependencyAnalysis analysis) {
        logToConsole("Populating app config from manifest information...");
        
        // Prioritize Implementation-* attributes, fallback to Specification-* or Bundle-*
        String appName = getFirstNonNull(analysis.getImplementationTitle(), 
                                        analysis.getSpecificationTitle(),
                                        analysis.getBundleName());
        
        String version = getFirstNonNull(analysis.getImplementationVersion(),
                                        analysis.getSpecificationVersion(),
                                        analysis.getBundleVersion());
        
        String vendor = getFirstNonNull(analysis.getImplementationVendor(),
                                       analysis.getSpecificationVendor(),
                                       analysis.getBundleVendor());
        
        String description = analysis.getBundleDescription();
        
        // Update fields if we have data and it's different/better than what we already have
        if (appName != null && !appName.trim().isEmpty()) {
            String currentAppName = appNameField.getText();
            String manifestAppName = appName.trim();
            
            // Only update if manifest has a different/better app name than what we extracted from filename
            if (currentAppName == null || currentAppName.trim().isEmpty() || 
                (!manifestAppName.equals(currentAppName) && !manifestAppName.toLowerCase().contains("memzo-extracter"))) {
                String formattedAppName = formatApplicationName(manifestAppName);
                appNameField.setText(formattedAppName);
                logToConsole("Set app name from manifest: " + formattedAppName);
                
                // Set output directory based on app name from manifest
                setOutputDirectoryFromAppName(formattedAppName);
                
                // Update preset name field with app name + "Config"
                updatePresetNameField(formattedAppName);
            } else {
                logToConsole("Keeping filename-based app name: " + currentAppName);
            }
        }
        
        if (version != null && !version.trim().isEmpty()) {
            versionField.setText(version.trim());
            logToConsole("Set app version from manifest: " + version.trim());
        }
        
        if (vendor != null && !vendor.trim().isEmpty()) {
            vendorField.setText(vendor.trim());
            logToConsole("Set vendor from manifest: " + vendor.trim());
        } else {
            // Try to extract vendor from start class first, then main class if available
            String classForVendor = analysis.getStartClass() != null ? analysis.getStartClass() : analysis.getMainClass();
            if (classForVendor != null && !classForVendor.trim().isEmpty()) {
                String vendorFromPackage = extractVendorFromMainClass(classForVendor);
                if (vendorFromPackage != null && !vendorFromPackage.trim().isEmpty()) {
                    vendorField.setText(vendorFromPackage);
                    String classType = analysis.getStartClass() != null ? "start class" : "main class";
                    logToConsole("Set vendor from " + classType + " package: " + vendorFromPackage);
                }
            }
        }
        
        if (description != null && !description.trim().isEmpty()) {
            descriptionArea.setText(description.trim());
            logToConsole("Set description from manifest: " + description.trim());
        }
        
        if (appName == null && version == null && vendor == null && description == null) {
            logToConsole("No useful manifest information found for app config");
        }
    }
    
    private String getFirstNonNull(String... values) {
        for (String value : values) {
            if (value != null && !value.trim().isEmpty()) {
                return value;
            }
        }
        return null;
    }
    
    private String extractVendorFromMainClass(String mainClass) {
        try {
            if (mainClass == null || mainClass.trim().isEmpty()) {
                return null;
            }
            
            // Split the main class by dots to get package parts
            String[] parts = mainClass.split("\\.");
            
            // Look for common package patterns like com.vendor.app or org.vendor.app
            if (parts.length >= 3) {
                String firstPart = parts[0].toLowerCase();
                
                // Handle common package prefixes
                if (firstPart.equals("com") || firstPart.equals("org") || firstPart.equals("net") || firstPart.equals("io")) {
                    // Vendor is typically the second part
                    String vendor = parts[1];
                    return formatVendorName(vendor);
                } else {
                    // If no standard prefix, use the first part as vendor
                    return formatVendorName(parts[0]);
                }
            } else if (parts.length >= 2) {
                // For shorter packages, use the first part
                return formatVendorName(parts[0]);
            }
            
            return null;
        } catch (Exception e) {
            log.warn("Could not extract vendor from main class: {}", mainClass, e);
            return null;
        }
    }
    
    private String formatVendorName(String vendor) {
        if (vendor == null || vendor.trim().isEmpty()) {
            return null;
        }
        
        // Remove any special characters and numbers
        vendor = vendor.replaceAll("[^a-zA-Z0-9]", "");
        
        if (vendor.isEmpty()) {
            return null;
        }
        
        // Convert to title case - first letter uppercase, rest lowercase
        return Character.toUpperCase(vendor.charAt(0)) + vendor.substring(1).toLowerCase();
    }

    private void updatePresetNameField(String appName) {
        if (appName != null && !appName.trim().isEmpty()) {
            String presetName = appName.trim() + " Config";
            presetNameField.setText(presetName);
        }
    }

    private void updateModulesList(Set<String> requiredModules) {
        // Add any missing modules to the list
        for (String module : requiredModules) {
            if (!modulesListView.getItems().contains(module)) {
                modulesListView.getItems().add(module);
            }
        }

        // Select required modules
        modulesListView.getCheckModel().clearChecks();
        for (String module : requiredModules) {
            int index = modulesListView.getItems().indexOf(module);
            if (index >= 0) {
                modulesListView.getCheckModel().check(index);
            }
        }
    }

    private void packageApplication() {
        PackageConfiguration config = getConfigurationFromUI();

        // Validate configuration
        if (config.getJarFile() == null || !config.getJarFile().toFile().exists()) {
            showAlert(Alert.AlertType.WARNING, "Warning", "Please select a valid JAR file.");
            return;
        }

        if (config.getAppName() == null || config.getAppName().trim().isEmpty()) {
            showAlert(Alert.AlertType.WARNING, "Warning", "Please enter an application name.");
            return;
        }

        if (config.getMainClass() == null || config.getMainClass().trim().isEmpty()) {
            showAlert(Alert.AlertType.WARNING, "Warning", "Please enter the main class.");
            return;
        }

        if (config.getOutputDirectory() == null) {
            showAlert(Alert.AlertType.WARNING, "Warning", "Please select an output directory.");
            return;
        }

        Task<PackagingResult> packageTask = new Task<PackagingResult>() {
            @Override
            protected PackagingResult call() throws Exception {
                updateMessage("Packaging application...");
                updateProgress(0, 1);

                return packagingService.packageApplication(config, logMessage -> {
                    Platform.runLater(() -> logToConsole(logMessage));
                });
            }

            @Override
            protected void succeeded() {
                PackagingResult result = getValue();
                Platform.runLater(() -> {
                    statusLabel.textProperty().unbind();
                    handlePackagingResult(result);
                    progressBar.setVisible(false);
                    statusLabel.setText(result.isSuccess() ? "Packaging completed" : "Packaging failed");
                });
            }

            @Override
            protected void failed() {
                Platform.runLater(() -> {
                    statusLabel.textProperty().unbind();
                    logToConsole("Packaging failed: " + getException().getMessage());
                    progressBar.setVisible(false);
                    statusLabel.setText("Packaging failed");
                });
            }
        };

        progressBar.setVisible(true);
        progressBar.progressProperty().bind(packageTask.progressProperty());
        statusLabel.textProperty().bind(packageTask.messageProperty());

        // Disable package button during processing
        packageButton.setDisable(true);
        packageTask.setOnSucceeded(e -> packageButton.setDisable(false));
        packageTask.setOnFailed(e -> packageButton.setDisable(false));

        new Thread(packageTask).start();
    }

    private void handlePackagingResult(PackagingResult result) {
        if (result.isSuccess()) {
            logToConsole("\n" + "=".repeat(50));
            logToConsole("PACKAGING COMPLETED SUCCESSFULLY!");
            logToConsole("Output location: " + result.getOutputPath());
            logToConsole("Execution time: " + result.getExecutionTimeMs() + " ms");
            logToConsole("=".repeat(50));

            showAlert(Alert.AlertType.INFORMATION, "Success",
                    "Application packaged successfully!\n\nOutput location: " + result.getOutputPath());
        } else {
            logToConsole("\n" + "=".repeat(50));
            logToConsole("PACKAGING FAILED!");
            logToConsole("Error: " + result.getMessage());
            logToConsole("=".repeat(50));

            showAlert(Alert.AlertType.ERROR, "Packaging Failed", result.getMessage());
        }

        // Log all messages
        if (result.getLogs() != null) {
            for (String log : result.getLogs()) {
                logToConsole(log);
            }
        }
    }

    private void resetForm() {
        // Clear all file fields
        jarFileField.clear();
        iconFileField.clear();
        outputDirField.clear();
        
        // Clear all application configuration fields
        appNameField.clear();
        versionField.clear();
        mainClassField.clear();
        vendorField.clear();
        descriptionArea.clear();
        copyrightField.clear();
        
        // Reset platform and format to defaults
        targetPlatformCombo.setValue(PackageConfiguration.TargetPlatform.CURRENT);
        outputFormatCombo.setValue(PackageConfiguration.OutputFormat.APP_IMAGE);
        
        // Reset JLink configuration
        enableJLinkCheck.setSelected(false);
        modulesListView.getCheckModel().clearChecks();
        customModuleField.clear();
        
        // Clear advanced options
        jvmArgsArea.clear();
        appArgsArea.clear();
        
        // Clear console and reset status
        consoleArea.clear();
        statusLabel.setText("Ready");
        progressBar.setVisible(false);
        
        log.info("Form reset to default values");
    }

    private void addCustomModule() {
        String module = customModuleField.getText().trim();
        if (!module.isEmpty() && !modulesListView.getItems().contains(module)) {
            modulesListView.getItems().add(module);
            modulesListView.getCheckModel().check(modulesListView.getItems().size() - 1);
            customModuleField.clear();
        }
    }

    private void savePreset() {
        String name = presetNameField.getText().trim();
        if (name.isEmpty()) {
            showAlert(Alert.AlertType.WARNING, "Warning", "Please enter a preset name.");
            return;
        }

        try {
            PackageConfiguration config = getConfigurationFromUI();
            configurationService.savePreset(name, config);
            refreshPresets();
            presetNameField.clear();
            showAlert(Alert.AlertType.INFORMATION, "Success", "Preset saved successfully!");
        } catch (Exception e) {
            showAlert(Alert.AlertType.ERROR, "Error", "Failed to save preset: " + e.getMessage());
        }
    }

    private void loadPreset() {
        String selectedPreset = presetsCombo.getValue();
        if (selectedPreset == null) {
            showAlert(Alert.AlertType.WARNING, "Warning", "Please select a preset to load.");
            return;
        }

        try {
            PackageConfiguration config = configurationService.loadPreset(selectedPreset);
            updateUIFromConfiguration(config);
            showAlert(Alert.AlertType.INFORMATION, "Success", "Preset loaded successfully!");
        } catch (Exception e) {
            showAlert(Alert.AlertType.ERROR, "Error", "Failed to load preset: " + e.getMessage());
        }
    }

    private void deletePreset() {
        String selectedPreset = presetsCombo.getValue();
        if (selectedPreset == null) {
            showAlert(Alert.AlertType.WARNING, "Warning", "Please select a preset to delete.");
            return;
        }

        Alert confirmAlert = new Alert(Alert.AlertType.CONFIRMATION);
        confirmAlert.setTitle("Confirm Delete");
        confirmAlert.setHeaderText("Delete Preset");
        confirmAlert.setContentText("Are you sure you want to delete the preset '" + selectedPreset + "'?");

        if (confirmAlert.showAndWait().orElse(ButtonType.CANCEL) == ButtonType.OK) {
            try {
                configurationService.deletePreset(selectedPreset);
                refreshPresets();
                showAlert(Alert.AlertType.INFORMATION, "Success", "Preset deleted successfully!");
            } catch (Exception e) {
                showAlert(Alert.AlertType.ERROR, "Error", "Failed to delete preset: " + e.getMessage());
            }
        }
    }

    private void refreshPresets() {
        List<String> presets = configurationService.getAvailablePresets();
        presets.sort(String::compareToIgnoreCase);
        presetsCombo.setItems(FXCollections.observableArrayList(presets));
    }

    private void exportLogs() {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Export Logs");
        fileChooser.setInitialFileName("packaroo-logs.txt");
        fileChooser.getExtensionFilters().add(new FileChooser.ExtensionFilter("Text Files", "*.txt"));

        File file = fileChooser.showSaveDialog(exportLogsButton.getScene().getWindow());
        if (file != null) {
            try {
                java.nio.file.Files.write(file.toPath(), consoleArea.getText().getBytes());
                showAlert(Alert.AlertType.INFORMATION, "Success", "Logs exported successfully!");
            } catch (Exception e) {
                showAlert(Alert.AlertType.ERROR, "Error", "Failed to export logs: " + e.getMessage());
            }
        }
    }

    private void toggleTheme() {
        // This will be implemented with CSS switching
        // For now, just log the action
        logToConsole("Theme toggle: " + (darkThemeCheck.isSelected() ? "Dark" : "Light"));
    }

    private void updateToolAvailability() {
        Task<Void> checkTask = new Task<Void>() {
            @Override
            protected Void call() throws Exception {
                boolean jpackageAvailable = packagingService.isJPackageAvailable();
                boolean jlinkAvailable = packagingService.isJLinkAvailable();

                Platform.runLater(() -> {
                    if (!jpackageAvailable) {
                        logToConsole("WARNING: jpackage tool is not available. Please ensure JDK 14+ is installed.");
                        packageButton.setDisable(true);
                    }

                    if (!jlinkAvailable) {
                        logToConsole("WARNING: jlink tool is not available. JLink features will be disabled.");
                        enableJLinkCheck.setDisable(true);
                        enableJLinkCheck.setSelected(false);
                    }
                });

                return null;
            }
        };

        new Thread(checkTask).start();
    }

    private void logToConsole(String message) {
        Platform.runLater(() -> {
            consoleArea.appendText("[" + java.time.LocalTime.now().toString() + "] " + message + "\n");
            consoleArea.setScrollTop(Double.MAX_VALUE);
        });
    }

    private void showAlert(Alert.AlertType type, String title, String message) {
        Alert alert = new Alert(type);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}
