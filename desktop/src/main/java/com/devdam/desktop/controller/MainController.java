package com.devdam.desktop.controller;

import com.devdam.desktop.model.DependencyAnalysis;
import com.devdam.desktop.model.PackageConfiguration;
import com.devdam.desktop.model.PackagingResult;
import com.devdam.desktop.service.ConfigurationService;
import com.devdam.desktop.service.ConsoleLoggerService;
import com.devdam.desktop.service.DependencyAnalysisService;
import com.devdam.desktop.service.PackagingService;
import com.devdam.desktop.service.ViewManager;
import javafx.application.Platform;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.collections.FXCollections;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.control.*;
import javafx.scene.layout.VBox;
import javafx.stage.DirectoryChooser;
import javafx.stage.FileChooser;
import javafx.util.Duration;
import lombok.extern.slf4j.Slf4j;
import org.controlsfx.control.CheckListView;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.File;
import java.net.URL;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.prefs.Preferences;
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

    // Animation
    private Timeline progressAnimation;
    private double currentProgress = 0.0;
    private boolean isIncrementing = true;
    private static final double PROGRESS_STEP = 0.05; // 5% increments

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
    
    // Preferences for theme persistence
    private static final Preferences prefs = Preferences.userRoot().node("com/devdam/desktop/theme");
    private static final String DARK_THEME_KEY = "darkTheme";

    // Menu Items
    @FXML private MenuItem newConfigMenuItem;
    @FXML private MenuItem openConfigMenuItem;
    @FXML private MenuItem saveConfigMenuItem;
    @FXML private MenuItem exitMenuItem;
    @FXML private MenuItem analyzeJarMenuItem;
    @FXML private MenuItem packageAppMenuItem;
    @FXML private MenuItem clearConsoleMenuItem;
    @FXML private MenuItem setupMenuItem;
    @FXML private MenuItem aboutMenuItem;
    @FXML private MenuItem backToMainMenuItem;

    @Autowired
    private DependencyAnalysisService dependencyService;

    @Autowired
    private PackagingService packagingService;

    @Autowired
    private ConfigurationService configurationService;

    @Autowired
    private ViewManager viewManager;

    @Autowired
    private ConsoleLoggerService consoleLogger;

    // Application properties
    @Value("${application.description}")
    private String applicationDescription;
    
    @Value("${application.version}")
    private String applicationVersion;

    private PackageConfiguration currentConfig;
    
    // View management
    private boolean isSetupGuideViewActive = false;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        initializeComponents();
        loadDefaultConfiguration();
        refreshPresets();
        updateToolAvailability();
        
        // Initialize console logger
        consoleLogger.setConsoleArea(consoleArea);
        consoleLogger.info("SYSTEM", "Packaroo application initialized successfully");
        
        // Initialize menu visibility
        updateMenuVisibility();
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
        
        // Load saved theme preference
        loadThemePreference();
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
        clearConsoleButton.setOnAction(e -> {
            consoleLogger.clear();
            consoleLogger.info("SYSTEM", "Console cleared");
        });
        exportLogsButton.setOnAction(e -> exportLogs());

        // Modules
        addModuleButton.setOnAction(e -> addCustomModule());

        // Presets
        savePresetButton.setOnAction(e -> savePreset());
        loadPresetButton.setOnAction(e -> loadPreset());
        deletePresetButton.setOnAction(e -> deletePreset());

        // Theme
        darkThemeCheck.setOnAction(e -> toggleTheme());

        // Menu Items
        setupMenuHandlers();

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
        // Populate description field from loaded config/preset if available
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
            
            // Keep description field blank - don't auto-populate
            // descriptionArea.setText(applicationDescription);
            // log.info("Auto-populated description: '{}'", applicationDescription);
            
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
                Platform.runLater(() -> {
                    consoleLogger.section("JAR DEPENDENCY ANALYSIS");
                    consoleLogger.info("ANALYSIS", "Starting analysis of: " + jarFile.getFileName());
                });
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
                    consoleLogger.error("ANALYSIS", "Analysis failed: " + getException().getMessage());
                    statusLabel.setText("Analysis failed");
                });
            }
        };

        statusLabel.textProperty().bind(analyzeTask.messageProperty());
        new Thread(analyzeTask).start();
    }

    private void handleAnalysisResult(DependencyAnalysis analysis) {
        if (analysis.isSuccess()) {
            consoleLogger.success("ANALYSIS", "Analysis completed successfully!");
            consoleLogger.info("ANALYSIS", "JAR: " + analysis.getJarPath());

            // Auto-populate application fields from JAR filename (similar to file selection)
            if (analysis.getJarPath() != null) {
                try {
                    File jarFile = new File(analysis.getJarPath());
                    populateFieldsFromJarFile(jarFile);
                    consoleLogger.info("CONFIG", "Auto-populated app config fields from JAR filename");
                } catch (Exception e) {
                    log.warn("Could not auto-populate fields from JAR filename during analysis", e);
                }
            }

            if (analysis.getMainClass() != null) {
                mainClassField.setText(analysis.getMainClass());
                consoleLogger.info("CONFIG", "Detected main class: " + analysis.getMainClass());
            }
            
            // If there's a Start-Class, use it for vendor extraction and display
            if (analysis.getStartClass() != null) {
                mainClassField.setText(analysis.getStartClass());
                consoleLogger.info("CONFIG", "Detected start class (using for main class): " + analysis.getStartClass());
                
                // Extract vendor from start class package
                String vendorFromPackage = extractVendorFromMainClass(analysis.getStartClass());
                if (vendorFromPackage != null && !vendorFromPackage.trim().isEmpty()) {
                    vendorField.setText(vendorFromPackage);
                    consoleLogger.info("CONFIG", "Set vendor from start class package: " + vendorFromPackage);
                }
            } else if (analysis.getMainClass() != null) {
                // Fallback to main class for vendor extraction if no start class
                String vendorFromPackage = extractVendorFromMainClass(analysis.getMainClass());
                if (vendorFromPackage != null && !vendorFromPackage.trim().isEmpty()) {
                    vendorField.setText(vendorFromPackage);
                    consoleLogger.info("CONFIG", "Set vendor from main class package: " + vendorFromPackage);
                }
            }

            // Populate app config fields from manifest information (this will override filename-based values if available)
            if (analysis.hasManifestInfo()) {
                populateAppConfigFromManifest(analysis);
            }

            if (analysis.hasRequiredModules()) {
                consoleLogger.info("ANALYSIS", "Required modules: " + analysis.getRequiredModules().size());
                for (String module : analysis.getRequiredModules()) {
                    consoleLogger.info("MODULES", "  - " + module);
                }

                // Update modules list and select required ones
                updateModulesList(analysis.getRequiredModules());
            }

            if (analysis.hasMissingModules()) {
                consoleLogger.warning("MODULES", "Missing modules detected:");
                for (String module : analysis.getMissingModules()) {
                    consoleLogger.warning("MODULES", "  - " + module + " (not available in current JDK)");
                }
            }
        } else {
            consoleLogger.error("ANALYSIS", "Analysis failed: " + analysis.getErrorMessage());
            showAlert(Alert.AlertType.ERROR, "Analysis Failed", analysis.getErrorMessage());
        }
    }
    
    private void populateAppConfigFromManifest(DependencyAnalysis analysis) {
        consoleLogger.info("CONFIG", "Populating app config from manifest information...");
        
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
                (!manifestAppName.equals(currentAppName) && (!manifestAppName.toLowerCase().contains("memzo-extracter") || !manifestAppName.toLowerCase().contains("-")))) {
                String formattedAppName = formatApplicationName(manifestAppName);
                appNameField.setText(formattedAppName);
                consoleLogger.info("CONFIG", "Set app name from manifest: " + formattedAppName);
                
                // Set output directory based on app name from manifest
                setOutputDirectoryFromAppName(formattedAppName);
                
                // Update preset name field with app name + "Config"
                updatePresetNameField(formattedAppName);
            } else {
                consoleLogger.info("CONFIG", "Keeping filename-based app name: " + currentAppName);
            }
        }
        
        if (version != null && !version.trim().isEmpty()) {
            versionField.setText(version.trim());
            consoleLogger.info("CONFIG", "Set app version from manifest: " + version.trim());
        }
        
        if (vendor != null && !vendor.trim().isEmpty()) {
            vendorField.setText(vendor.trim());
            consoleLogger.info("CONFIG", "Set vendor from manifest: " + vendor.trim());
        } else {
            // Try to extract vendor from start class first, then main class if available
            String classForVendor = analysis.getStartClass() != null ? analysis.getStartClass() : analysis.getMainClass();
            if (classForVendor != null && !classForVendor.trim().isEmpty()) {
                String vendorFromPackage = extractVendorFromMainClass(classForVendor);
                if (vendorFromPackage != null && !vendorFromPackage.trim().isEmpty()) {
                    vendorField.setText(vendorFromPackage);
                    String classType = analysis.getStartClass() != null ? "start class" : "main class";
                    consoleLogger.info("CONFIG", "Set vendor from " + classType + " package: " + vendorFromPackage);
                }
            }
        }
        
        // Populate description field from manifest if available
        if (description != null && !description.trim().isEmpty()) {
            descriptionArea.setText(description.trim());
            consoleLogger.info("CONFIG", "Set description from manifest: " + description.trim());
        }
        
        if (appName == null && version == null && vendor == null && description == null) {
            consoleLogger.warning("CONFIG", "No useful manifest information found for app config");
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
            String presetName = appName.trim() + " Preset";
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
                    Platform.runLater(() -> consoleLogger.info("BUILD", logMessage));
                });
            }

            @Override
            protected void succeeded() {
                PackagingResult result = getValue();
                Platform.runLater(() -> {
                    statusLabel.textProperty().unbind();
                    handlePackagingResult(result);
                    stopAnimatedProgressBar();
                    progressBar.setVisible(false);
                    statusLabel.setText(result.isSuccess() ? "Packaging completed" : "Packaging failed");
                });
            }

            @Override
            protected void failed() {
                Platform.runLater(() -> {
                    statusLabel.textProperty().unbind();
                    consoleLogger.error("BUILD", "Packaging failed: " + getException().getMessage());
                    stopAnimatedProgressBar();
                    progressBar.setVisible(false);
                    statusLabel.setText("Packaging failed");
                });
            }
        };

        // Start animated progress bar instead of binding to task progress
        progressBar.setVisible(true);
        startAnimatedProgressBar();
        statusLabel.textProperty().bind(packageTask.messageProperty());

        // Disable package button during processing
        packageButton.setDisable(true);
        packageTask.setOnSucceeded(e -> {
            packageButton.setDisable(false);
            stopAnimatedProgressBar();
        });
        packageTask.setOnFailed(e -> {
            packageButton.setDisable(false);
            stopAnimatedProgressBar();
        });

        new Thread(packageTask).start();
    }

    private void handlePackagingResult(PackagingResult result) {
        if (result.isSuccess()) {
            consoleLogger.separator();
            consoleLogger.success("BUILD", "PACKAGING COMPLETED SUCCESSFULLY!");
            consoleLogger.info("BUILD", "Output location: " + result.getOutputPath());
            consoleLogger.info("BUILD", "Execution time: " + result.getExecutionTimeMs() + " ms");
            consoleLogger.separator();

            showAlert(Alert.AlertType.INFORMATION, "Success",
                    "Application packaged successfully!\n\nOutput location: " + result.getOutputPath());
        } else {
            consoleLogger.separator();
            consoleLogger.error("BUILD", "PACKAGING FAILED!");
            consoleLogger.error("BUILD", "Error: " + result.getMessage());
            consoleLogger.separator();

            showAlert(Alert.AlertType.ERROR, "Packaging Failed", result.getMessage());
        }

        // Log all messages
        if (result.getLogs() != null) {
            for (String log : result.getLogs()) {
                consoleLogger.info("BUILD", log);
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
        boolean isDarkTheme = darkThemeCheck.isSelected();
        
        // Save theme preference
        prefs.putBoolean(DARK_THEME_KEY, isDarkTheme);
        
        // Apply theme
        applyTheme(isDarkTheme);
    }
    
    private void loadThemePreference() {
        // Load saved theme preference (default to false/light theme)
        boolean isDarkTheme = prefs.getBoolean(DARK_THEME_KEY, false);
        
        // Set the checkbox state
        darkThemeCheck.setSelected(isDarkTheme);
        
        // Apply the theme
        applyTheme(isDarkTheme);
    }
    
    private void applyTheme(boolean isDarkTheme) {
        if (rootPane != null) {
            if (isDarkTheme) {
                if (!rootPane.getStyleClass().contains("dark-theme")) {
                    rootPane.getStyleClass().add("dark-theme");
                }
            } else {
                rootPane.getStyleClass().removeAll("dark-theme");
            }
        }
    }

    private void updateToolAvailability() {
        Task<Void> checkTask = new Task<Void>() {
            @Override
            protected Void call() throws Exception {
                boolean jpackageAvailable = packagingService.isJPackageAvailable();
                boolean jlinkAvailable = packagingService.isJLinkAvailable();

                Platform.runLater(() -> {
                    if (!jpackageAvailable) {
                        consoleLogger.warning("SYSTEM", "jpackage tool is not available. Please ensure JDK 14+ is installed.");
                        packageButton.setDisable(true);
                    }

                    if (!jlinkAvailable) {
                        consoleLogger.warning("SYSTEM", "jlink tool is not available. JLink features will be disabled.");
                        enableJLinkCheck.setDisable(true);
                        enableJLinkCheck.setSelected(false);
                    }
                });

                return null;
            }
        };

        new Thread(checkTask).start();
    }

    private void showAlert(Alert.AlertType type, String title, String message) {
        Alert alert = new Alert(type);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }

    private void setupMenuHandlers() {
        // File Menu
        newConfigMenuItem.setOnAction(e -> newConfiguration());
        openConfigMenuItem.setOnAction(e -> openConfiguration());
        saveConfigMenuItem.setOnAction(e -> saveConfiguration());
        exitMenuItem.setOnAction(e -> exitApplication());

        // Tools Menu
        analyzeJarMenuItem.setOnAction(e -> analyzeJar());
        packageAppMenuItem.setOnAction(e -> packageApplication());
        clearConsoleMenuItem.setOnAction(e -> consoleArea.clear());

        // Help Menu
        setupMenuItem.setOnAction(e -> showSetupGuideView());
        aboutMenuItem.setOnAction(e -> showAboutDialog());
        
        // View Menu
        if (backToMainMenuItem != null) {
            backToMainMenuItem.setOnAction(e -> showMainView());
        }
    }

    // File Menu Actions
    private void newConfiguration() {
        Alert confirmation = new Alert(Alert.AlertType.CONFIRMATION);
        confirmation.setTitle("New Configuration");
        confirmation.setHeaderText("Create New Configuration");
        confirmation.setContentText("This will reset all current settings. Continue?");
        
        confirmation.showAndWait().ifPresent(response -> {
            if (response == ButtonType.OK) {
                resetForm();
                consoleLogger.info("CONFIG", "New configuration created");
            }
        });
    }

    private void openConfiguration() {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Open Configuration");
        fileChooser.getExtensionFilters().add(
            new FileChooser.ExtensionFilter("JSON Files", "*.json")
        );
        
        java.io.File file = fileChooser.showOpenDialog(appNameField.getScene().getWindow());
        if (file != null) {
            try {
                PackageConfiguration config = configurationService.loadConfigurationFromFile(file.getAbsolutePath());
                currentConfig = config;
                updateUIFromConfiguration(config);
                consoleLogger.success("CONFIG", "Configuration loaded from: " + file.getName());
                showAlert(Alert.AlertType.INFORMATION, "Success", "Configuration loaded successfully!");
            } catch (Exception ex) {
                consoleLogger.error("CONFIG", "Error loading configuration: " + ex.getMessage());
                showAlert(Alert.AlertType.ERROR, "Error", "Failed to load configuration: " + ex.getMessage());
            }
        }
    }

    private void saveConfiguration() {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Save Configuration");
        fileChooser.getExtensionFilters().add(
            new FileChooser.ExtensionFilter("JSON Files", "*.json")
        );
        
        // Set default filename based on app name
        String appName = appNameField.getText();
        if (appName != null && !appName.trim().isEmpty()) {
            fileChooser.setInitialFileName(appName.trim() + " Config.json");
        } else {
            fileChooser.setInitialFileName("Packaroo Config.json");
        }
        
        java.io.File file = fileChooser.showSaveDialog(appNameField.getScene().getWindow());
        if (file != null) {
            try {
                PackageConfiguration config = getConfigurationFromUI();
                configurationService.saveConfigurationToFile(config, file.getAbsolutePath());
                consoleLogger.success("CONFIG", "Configuration saved to: " + file.getName());
                showAlert(Alert.AlertType.INFORMATION, "Success", "Configuration saved successfully!");
            } catch (Exception ex) {
                consoleLogger.error("CONFIG", "Error saving configuration: " + ex.getMessage());
                showAlert(Alert.AlertType.ERROR, "Error", "Failed to save configuration: " + ex.getMessage());
            }
        }
    }

    private void exitApplication() {
        Alert confirmation = new Alert(Alert.AlertType.CONFIRMATION);
        confirmation.setTitle("Exit Application");
        confirmation.setHeaderText("Exit Packaroo");
        confirmation.setContentText("Are you sure you want to exit?");
        
        confirmation.showAndWait().ifPresent(response -> {
            if (response == ButtonType.OK) {
                Platform.exit();
                System.exit(0);
            }
        });
    }

    // Help Menu Actions
    private void showAboutDialog() {
        Alert about = new Alert(Alert.AlertType.INFORMATION);
        about.setTitle("About Packaroo");
        about.setHeaderText("Packaroo Desktop");
        about.setContentText(
            "Version: 1.0.0\n" +
            "A modern JavaFX application packaging tool\n\n" +
            "Features:\n" +
            "• JAR dependency analysis\n" +
            "• Custom JLink runtime creation\n" +
            "• Native application packaging\n" +
            "• Cross-platform support\n\n" +
            "Built with JavaFX and Spring Boot\n" +
            "© 2025 DevDam"
        );
        about.setResizable(true);
        about.getDialogPane().setPrefWidth(400);
        about.showAndWait();
    }

    private void showSetupGuideView() {
        viewManager.showSetupGuide();
    }
    
    private void showMainView() {
        // Reload the main view by creating a new scene
        try {
            Platform.runLater(() -> {
                try {
                    FXMLLoader loader = new FXMLLoader(getClass().getResource("/fxml/main.fxml"));
                    VBox newMainView = loader.load();
                    
                    // Replace the scene root
                    rootPane.getScene().setRoot(newMainView);
                    
                } catch (Exception e) {
                    log.error("Failed to load main view", e);
                }
            });
            
        } catch (Exception e) {
            log.error("Failed to show main view", e);
            showAlert(Alert.AlertType.ERROR, "Error", "Failed to return to main view: " + e.getMessage());
        }
    }
    
    private void updateMenuVisibility() {
        // Show/hide back to main menu item based on current view
        if (backToMainMenuItem != null) {
            backToMainMenuItem.setVisible(isSetupGuideViewActive);
        }
    }
    
    // Animated Progress Bar Methods
    private void startAnimatedProgressBar() {
        // Stop any existing animation
        stopAnimatedProgressBar();
        
        // Add animated loading style class
        progressBar.getStyleClass().add("animated-loading");
        
        // Reset progress values
        currentProgress = 0.0;
        isIncrementing = true;
        progressBar.setProgress(currentProgress);
        
        // Create incremental progress animation
        progressAnimation = new Timeline();
        progressAnimation.setCycleCount(Timeline.INDEFINITE);
        
        // Update progress every 100ms for smooth animation
        KeyFrame progressFrame = new KeyFrame(Duration.millis(100), e -> updateIncrementalProgress());
        progressAnimation.getKeyFrames().add(progressFrame);
        progressAnimation.play();
    }
    
    private void stopAnimatedProgressBar() {
        // Stop animation
        if (progressAnimation != null) {
            progressAnimation.stop();
            progressAnimation = null;
        }
        
        // Remove animated loading style class
        progressBar.getStyleClass().removeAll("animated-loading");
        
        // Reset to determinate mode
        progressBar.setProgress(0.0);
        currentProgress = 0.0;
        isIncrementing = true;
    }
    
    private void updateIncrementalProgress() {
        Platform.runLater(() -> {
            if (isIncrementing) {
                // Increment from 0 to 100%
                currentProgress += PROGRESS_STEP;
                if (currentProgress >= 1.0) {
                    currentProgress = 1.0;
                    isIncrementing = false; // Start decrementing
                }
            } else {
                // Decrement from 100% to 0
                currentProgress -= PROGRESS_STEP;
                if (currentProgress <= 0.0) {
                    currentProgress = 0.0;
                    isIncrementing = true; // Start incrementing again
                }
            }
            
            progressBar.setProgress(currentProgress);
        });
    }
}
