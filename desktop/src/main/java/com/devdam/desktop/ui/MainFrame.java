package com.devdam.desktop.ui;

import com.devdam.desktop.model.PackageConfiguration;
import com.devdam.desktop.service.ConfigurationService;
import com.devdam.desktop.service.ConsoleLoggerService;
import com.devdam.desktop.service.DependencyAnalysisService;
import com.devdam.desktop.service.PackagingService;
import com.devdam.desktop.ui.panels.ConsolePanel;
import com.devdam.desktop.ui.panels.FileSelectionPanel;
import com.devdam.desktop.ui.panels.PackageConfigPanel;
import com.devdam.desktop.ui.panels.AdvancedOptionsPanel;
import com.devdam.desktop.ui.theme.PackarooTheme;
import com.devdam.desktop.ui.components.ModernButton;
import com.formdev.flatlaf.FlatDarkLaf;
import com.formdev.flatlaf.FlatLightLaf;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.swing.*;
import java.awt.*;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.util.prefs.Preferences;

@Slf4j
@Component
public class MainFrame extends JFrame {
    
    private static final String DARK_THEME_KEY = "darkTheme";
    private static final String WINDOW_WIDTH_KEY = "windowWidth";
    private static final String WINDOW_HEIGHT_KEY = "windowHeight";
    private static final String WINDOW_X_KEY = "windowX";
    private static final String WINDOW_Y_KEY = "windowY";
    
    private final Preferences prefs = Preferences.userRoot().node("com/devdam/desktop");
    
    // UI Panels
    private FileSelectionPanel fileSelectionPanel;
    private PackageConfigPanel packageConfigPanel;
    private AdvancedOptionsPanel advancedOptionsPanel;
    private ConsolePanel consolePanel;
    
    // Menu and toolbar
    private JMenuBar menuBar;
    private JToolBar toolBar;
    private JCheckBoxMenuItem darkThemeMenuItem;
    
    // Action buttons
    private JButton analyzeButton;
    private JButton packageButton;
    private JButton resetButton;
    
    // Status bar
    private JPanel statusBar;
    private JLabel statusLabel;
    private JProgressBar progressBar;
    
    @Autowired
    private DependencyAnalysisService dependencyService;
    
    @Autowired
    private PackagingService packagingService;
    
    @Autowired
    private ConfigurationService configurationService;
    
    @Autowired
    private ConsoleLoggerService consoleLogger;
    
    @Value("${application.version:1.0.0}")
    private String applicationVersion;
    
    public MainFrame() {
        // Initialize components first
        initializeFrame();
        createMenuBar();
        createToolBar();
        createMainContent();
        createStatusBar();
        setupEventHandlers();
        loadPreferences();
        
        log.info("MainFrame initialized successfully");
    }
    
    @Autowired
    public void initializeServices(ConsoleLoggerService consoleLogger) {
        // Set up console logger after panels are created
        SwingUtilities.invokeLater(() -> {
            consoleLogger.setConsolePanel(consolePanel);
            consoleLogger.info("SYSTEM", "Packaroo application initialized successfully");
        });
    }
    
    private void initializeFrame() {
        setTitle("Packaroo - Java Application Packager");
        setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        
        // Try to load application icon
        try {
            ImageIcon icon = new ImageIcon(getClass().getResource("/images/icon.png"));
            if (icon.getIconWidth() > 0) {
                setIconImage(icon.getImage());
            }
        } catch (Exception e) {
            log.warn("Could not load application icon", e);
        }
        
        setLayout(new BorderLayout());
    }
    
    private void createMenuBar() {
        menuBar = new JMenuBar();
        
        // File Menu
        JMenu fileMenu = new JMenu("File");
        fileMenu.setMnemonic('F');
        
        JMenuItem newConfigItem = new JMenuItem("New Configuration");
        newConfigItem.setAccelerator(KeyStroke.getKeyStroke("ctrl N"));
        newConfigItem.addActionListener(e -> newConfiguration());
        
        JMenuItem openConfigItem = new JMenuItem("Open Configuration...");
        openConfigItem.setAccelerator(KeyStroke.getKeyStroke("ctrl O"));
        openConfigItem.addActionListener(e -> openConfiguration());
        
        JMenuItem saveConfigItem = new JMenuItem("Save Configuration...");
        saveConfigItem.setAccelerator(KeyStroke.getKeyStroke("ctrl S"));
        saveConfigItem.addActionListener(e -> saveConfiguration());
        
        fileMenu.add(newConfigItem);
        fileMenu.add(openConfigItem);
        fileMenu.add(saveConfigItem);
        fileMenu.addSeparator();
        
        JMenuItem exitItem = new JMenuItem("Exit");
        exitItem.setAccelerator(KeyStroke.getKeyStroke("ctrl Q"));
        exitItem.addActionListener(e -> exitApplication());
        fileMenu.add(exitItem);
        
        // Tools Menu
        JMenu toolsMenu = new JMenu("Tools");
        toolsMenu.setMnemonic('T');
        
        JMenuItem analyzeItem = new JMenuItem("Analyze JAR");
        analyzeItem.setAccelerator(KeyStroke.getKeyStroke("ctrl A"));
        analyzeItem.addActionListener(e -> analyzeJar());
        
        JMenuItem packageItem = new JMenuItem("Package Application");
        packageItem.setAccelerator(KeyStroke.getKeyStroke("ctrl P"));
        packageItem.addActionListener(e -> packageApplication());
        
        toolsMenu.add(analyzeItem);
        toolsMenu.add(packageItem);
        
        // View Menu
        JMenu viewMenu = new JMenu("View");
        viewMenu.setMnemonic('V');
        
        darkThemeMenuItem = new JCheckBoxMenuItem("Dark Theme");
        darkThemeMenuItem.addActionListener(e -> toggleTheme());
        viewMenu.add(darkThemeMenuItem);
        
        // Help Menu
        JMenu helpMenu = new JMenu("Help");
        helpMenu.setMnemonic('H');
        
        JMenuItem setupGuideItem = new JMenuItem("Setup Guide");
        setupGuideItem.addActionListener(e -> showSetupGuide());
        
        JMenuItem aboutItem = new JMenuItem("About");
        aboutItem.addActionListener(e -> showAbout());
        
        helpMenu.add(setupGuideItem);
        helpMenu.addSeparator();
        helpMenu.add(aboutItem);
        
        menuBar.add(fileMenu);
        menuBar.add(toolsMenu);
        menuBar.add(viewMenu);
        menuBar.add(helpMenu);
        
        setJMenuBar(menuBar);
    }
    
    private void createToolBar() {
        toolBar = new JToolBar();
        toolBar.setFloatable(false);
        toolBar.setBackground(PackarooTheme.BACKGROUND_CARD);
        toolBar.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(0, 0, 1, 0, PackarooTheme.BORDER_LIGHT),
            BorderFactory.createEmptyBorder(8, 16, 8, 16)
        ));
        
        analyzeButton = new ModernButton("Analyze JAR");
        analyzeButton.setToolTipText("Analyze selected JAR file dependencies");
        analyzeButton.addActionListener(e -> analyzeJar());
        
        packageButton = new ModernButton("Package Application");
        packageButton.setToolTipText("Package application with current configuration");
        packageButton.addActionListener(e -> packageApplication());
        
        resetButton = new ModernButton("Reset");
        resetButton.setToolTipText("Reset all fields to default values");
        resetButton.addActionListener(e -> resetForm());
        
        toolBar.add(analyzeButton);
        toolBar.add(Box.createHorizontalStrut(8));
        toolBar.add(packageButton);
        toolBar.addSeparator();
        toolBar.add(resetButton);
        
        add(toolBar, BorderLayout.NORTH);
    }
    
    private void createMainContent() {
        // Create panels
        fileSelectionPanel = new FileSelectionPanel();
        packageConfigPanel = new PackageConfigPanel();
        advancedOptionsPanel = new AdvancedOptionsPanel();
        consolePanel = new ConsolePanel();
        
        // Create tabbed pane for main content with modern styling
        JTabbedPane tabbedPane = new JTabbedPane();
        tabbedPane.setBackground(PackarooTheme.BACKGROUND_LIGHT);
        tabbedPane.setBorder(BorderFactory.createEmptyBorder(8, 8, 8, 8));
        
        // Configuration tab
        JPanel configTab = new JPanel(new BorderLayout(8, 8));
        configTab.setBackground(PackarooTheme.BACKGROUND_LIGHT);
        configTab.setBorder(BorderFactory.createEmptyBorder(16, 16, 16, 16));
        
        // Top panel for file selection and package config
        JPanel topPanel = new JPanel(new BorderLayout(0, 8));
        topPanel.setBackground(PackarooTheme.BACKGROUND_LIGHT);
        topPanel.add(fileSelectionPanel, BorderLayout.NORTH);
        topPanel.add(packageConfigPanel, BorderLayout.CENTER);
        
        configTab.add(topPanel, BorderLayout.NORTH);
        configTab.add(advancedOptionsPanel, BorderLayout.CENTER);
        
        tabbedPane.addTab("Configuration", configTab);
        tabbedPane.addTab("Console", consolePanel);
        
        add(tabbedPane, BorderLayout.CENTER);
    }
    
    private void createStatusBar() {
        statusBar = new JPanel(new BorderLayout());
        statusBar.setBackground(PackarooTheme.BACKGROUND_CARD);
        statusBar.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createMatteBorder(1, 0, 0, 0, PackarooTheme.BORDER_LIGHT),
            BorderFactory.createEmptyBorder(8, 16, 8, 16)
        ));
        
        statusLabel = new JLabel("Ready");
        statusLabel.setForeground(PackarooTheme.TEXT_SECONDARY);
        statusLabel.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        
        progressBar = new JProgressBar();
        progressBar.setVisible(false);
        progressBar.setPreferredSize(new Dimension(200, 16));
        
        statusBar.add(statusLabel, BorderLayout.CENTER);
        statusBar.add(progressBar, BorderLayout.EAST);
        
        add(statusBar, BorderLayout.SOUTH);
    }
    
    private void setupEventHandlers() {
        // Window close handler
        addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                exitApplication();
            }
        });
        
        // Save window state when closing
        addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                savePreferences();
            }
        });
    }
    
    private void loadPreferences() {
        // Load theme preference
        boolean isDarkTheme = prefs.getBoolean(DARK_THEME_KEY, false);
        darkThemeMenuItem.setSelected(isDarkTheme);
        if (isDarkTheme) {
            applyDarkTheme();
        }
        
        // Load window size and position
        int width = prefs.getInt(WINDOW_WIDTH_KEY, 1200);
        int height = prefs.getInt(WINDOW_HEIGHT_KEY, 800);
        int x = prefs.getInt(WINDOW_X_KEY, -1);
        int y = prefs.getInt(WINDOW_Y_KEY, -1);
        
        setSize(width, height);
        
        if (x >= 0 && y >= 0) {
            setLocation(x, y);
        } else {
            setLocationRelativeTo(null);
        }
        
        setMinimumSize(new Dimension(800, 600));
    }
    
    private void savePreferences() {
        // Save theme preference
        prefs.putBoolean(DARK_THEME_KEY, darkThemeMenuItem.isSelected());
        
        // Save window size and position
        prefs.putInt(WINDOW_WIDTH_KEY, getWidth());
        prefs.putInt(WINDOW_HEIGHT_KEY, getHeight());
        prefs.putInt(WINDOW_X_KEY, getX());
        prefs.putInt(WINDOW_Y_KEY, getY());
        
        try {
            prefs.flush();
        } catch (Exception e) {
            log.warn("Failed to save preferences", e);
        }
    }
    
    // Menu action methods
    private void newConfiguration() {
        int result = JOptionPane.showConfirmDialog(
            this,
            "This will reset all current settings. Continue?",
            "New Configuration",
            JOptionPane.YES_NO_OPTION,
            JOptionPane.QUESTION_MESSAGE
        );
        
        if (result == JOptionPane.YES_OPTION) {
            resetForm();
            consoleLogger.info("CONFIG", "New configuration created");
        }
    }
    
    private void openConfiguration() {
        JFileChooser fileChooser = new JFileChooser();
        fileChooser.setFileFilter(new javax.swing.filechooser.FileNameExtensionFilter(
            "JSON Files", "json"));
        
        int result = fileChooser.showOpenDialog(this);
        if (result == JFileChooser.APPROVE_OPTION) {
            try {
                PackageConfiguration config = configurationService.loadConfigurationFromFile(
                    fileChooser.getSelectedFile().getAbsolutePath());
                updateUIFromConfiguration(config);
                consoleLogger.success("CONFIG", "Configuration loaded from: " + 
                    fileChooser.getSelectedFile().getName());
                showMessage("Configuration loaded successfully!", "Success", JOptionPane.INFORMATION_MESSAGE);
            } catch (Exception ex) {
                consoleLogger.error("CONFIG", "Error loading configuration: " + ex.getMessage());
                showMessage("Failed to load configuration: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
    }
    
    private void saveConfiguration() {
        JFileChooser fileChooser = new JFileChooser();
        fileChooser.setFileFilter(new javax.swing.filechooser.FileNameExtensionFilter(
            "JSON Files", "json"));
        
        int result = fileChooser.showSaveDialog(this);
        if (result == JFileChooser.APPROVE_OPTION) {
            try {
                PackageConfiguration config = getConfigurationFromUI();
                configurationService.saveConfigurationToFile(config, 
                    fileChooser.getSelectedFile().getAbsolutePath());
                consoleLogger.success("CONFIG", "Configuration saved to: " + 
                    fileChooser.getSelectedFile().getName());
                showMessage("Configuration saved successfully!", "Success", JOptionPane.INFORMATION_MESSAGE);
            } catch (Exception ex) {
                consoleLogger.error("CONFIG", "Error saving configuration: " + ex.getMessage());
                showMessage("Failed to save configuration: " + ex.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
    }
    
    private void exitApplication() {
        int result = JOptionPane.showConfirmDialog(
            this,
            "Are you sure you want to exit?",
            "Exit Packaroo",
            JOptionPane.YES_NO_OPTION,
            JOptionPane.QUESTION_MESSAGE
        );
        
        if (result == JOptionPane.YES_OPTION) {
            savePreferences();
            System.exit(0);
        }
    }
    
    private void analyzeJar() {
        String jarPath = fileSelectionPanel.getJarFilePath();
        
        if (jarPath == null || jarPath.trim().isEmpty()) {
            showMessage("Please select a JAR file to analyze", "No JAR Selected", JOptionPane.WARNING_MESSAGE);
            return;
        }
        
        // Switch to console tab to show output
        java.awt.Component tabbedPane = getContentPane().getComponent(1); // Assuming tabbed pane is second component
        if (tabbedPane instanceof JTabbedPane) {
            ((JTabbedPane) tabbedPane).setSelectedIndex(1); // Console tab
        }
        
        // Clear console and show starting message
        consolePanel.clear();
        consolePanel.appendMessage("INFO", "ANALYSIS", "Starting JAR analysis for: " + jarPath);
        statusLabel.setText("Analyzing JAR file...");
        
        // Disable analyze button during analysis
        analyzeButton.setEnabled(false);
        
        // Run analysis in background thread
        SwingWorker<Void, String> worker = new SwingWorker<Void, String>() {
            @Override
            protected Void doInBackground() throws Exception {
                try {
                    var analysis = dependencyService.analyzeJar(java.nio.file.Path.of(jarPath));
                    
                    SwingUtilities.invokeLater(() -> {
                        if (analysis.isSuccess()) {
                            consolePanel.appendMessage("SUCCESS", "ANALYSIS", "JAR analysis completed successfully");
                            consolePanel.appendMessage("INFO", "MANIFEST", "Main-Class: " + 
                                (analysis.getMainClass() != null ? analysis.getMainClass() : "Not found"));
                            consolePanel.appendMessage("INFO", "MODULES", "Required modules: " + analysis.getRequiredModules().size());
                            
                            // Update package config with found information
                            if (analysis.getMainClass() != null && !analysis.getMainClass().isEmpty()) {
                                packageConfigPanel.setMainClass(analysis.getMainClass());
                            }
                            
                            // Display module information
                            for (String module : analysis.getRequiredModules()) {
                                consolePanel.appendMessage("DEBUG", "MODULE", "Required: " + module);
                            }
                            
                            if (!analysis.getMissingModules().isEmpty()) {
                                consolePanel.appendMessage("WARN", "MODULES", "Missing modules detected: " + analysis.getMissingModules().size());
                                for (String missing : analysis.getMissingModules()) {
                                    consolePanel.appendMessage("WARN", "MODULE", "Missing: " + missing);
                                }
                            }
                        } else {
                            consolePanel.appendMessage("ERROR", "ANALYSIS", "JAR analysis failed: " + analysis.getErrorMessage());
                        }
                        
                        statusLabel.setText("Analysis complete");
                        analyzeButton.setEnabled(true);
                    });
                } catch (Exception e) {
                    SwingUtilities.invokeLater(() -> {
                        consolePanel.appendMessage("ERROR", "ANALYSIS", "Analysis failed: " + e.getMessage());
                        statusLabel.setText("Analysis failed");
                        analyzeButton.setEnabled(true);
                    });
                }
                return null;
            }
        };
        
        worker.execute();
    }
    
    private void packageApplication() {
        // Validate required fields
        String jarPath = fileSelectionPanel.getJarFilePath();
        String outputDir = fileSelectionPanel.getOutputDirectoryPath();
        String appName = packageConfigPanel.getAppName();
        String mainClass = packageConfigPanel.getMainClass();
        
        if (jarPath == null || jarPath.trim().isEmpty()) {
            showMessage("Please select a JAR file to package", "No JAR Selected", JOptionPane.WARNING_MESSAGE);
            return;
        }
        
        if (outputDir == null || outputDir.trim().isEmpty()) {
            showMessage("Please select an output directory", "No Output Directory", JOptionPane.WARNING_MESSAGE);
            return;
        }
        
        if (appName == null || appName.trim().isEmpty()) {
            showMessage("Please enter an application name", "No Application Name", JOptionPane.WARNING_MESSAGE);
            return;
        }
        
        if (mainClass == null || mainClass.trim().isEmpty()) {
            showMessage("Please specify the main class", "No Main Class", JOptionPane.WARNING_MESSAGE);
            return;
        }
        
        // Switch to console tab to show output
        java.awt.Component tabbedPane = getContentPane().getComponent(1);
        if (tabbedPane instanceof JTabbedPane) {
            ((JTabbedPane) tabbedPane).setSelectedIndex(1); // Console tab
        }
        
        // Clear console and show starting message
        consolePanel.clear();
        consolePanel.appendMessage("INFO", "PACKAGING", "Starting application packaging...");
        statusLabel.setText("Packaging application...");
        
        // Disable package button during packaging
        packageButton.setEnabled(false);
        
        // Create configuration from UI
        PackageConfiguration.PackageConfigurationBuilder configBuilder = PackageConfiguration.builder()
                .jarFile(java.nio.file.Path.of(jarPath))
                .outputDirectory(java.nio.file.Path.of(outputDir))
                .appName(appName)
                .mainClass(mainClass)
                .targetPlatform(packageConfigPanel.getTargetPlatform())
                .outputFormat(packageConfigPanel.getOutputFormat());
        
        // Add optional fields
        String version = packageConfigPanel.getVersion();
        if (version != null && !version.trim().isEmpty()) {
            configBuilder.version(version);
        }
        
        String vendor = packageConfigPanel.getVendor();
        if (vendor != null && !vendor.trim().isEmpty()) {
            configBuilder.vendor(vendor);
        }
        
        String description = packageConfigPanel.getDescription();
        if (description != null && !description.trim().isEmpty()) {
            configBuilder.description(description);
        }
        
        String copyright = packageConfigPanel.getCopyright();
        if (copyright != null && !copyright.trim().isEmpty()) {
            configBuilder.copyright(copyright);
        }
        
        String iconPath = fileSelectionPanel.getIconFilePath();
        if (iconPath != null && !iconPath.trim().isEmpty()) {
            configBuilder.iconFile(java.nio.file.Path.of(iconPath));
        }
        
        PackageConfiguration config = configBuilder.build();
        
        // Run packaging in background thread
        SwingWorker<Void, String> worker = new SwingWorker<Void, String>() {
            @Override
            protected Void doInBackground() throws Exception {
                try {
                    var result = packagingService.packageApplication(config, message -> {
                        SwingUtilities.invokeLater(() -> 
                            consolePanel.appendMessage("INFO", "PACKAGING", message)
                        );
                    });
                    
                    SwingUtilities.invokeLater(() -> {
                        if (result.isSuccess()) {
                            consolePanel.appendMessage("SUCCESS", "PACKAGING", "Application packaged successfully!");
                            consolePanel.appendMessage("INFO", "OUTPUT", "Package created at: " + result.getOutputPath());
                            consolePanel.appendMessage("INFO", "TIME", "Packaging took: " + result.getExecutionTimeMs() + "ms");
                            statusLabel.setText("Packaging completed successfully");
                            
                            // Show success dialog
                            int choice = JOptionPane.showConfirmDialog(
                                MainFrame.this,
                                "Application packaged successfully!\n\nOutput: " + result.getOutputPath() + 
                                "\n\nWould you like to open the output directory?",
                                "Packaging Complete",
                                JOptionPane.YES_NO_OPTION,
                                JOptionPane.INFORMATION_MESSAGE
                            );
                            
                            if (choice == JOptionPane.YES_OPTION) {
                                try {
                                    Desktop.getDesktop().open(java.nio.file.Path.of(result.getOutputPath()).getParent().toFile());
                                } catch (Exception e) {
                                    consolePanel.appendMessage("WARN", "SYSTEM", "Could not open output directory: " + e.getMessage());
                                }
                            }
                        } else {
                            consolePanel.appendMessage("ERROR", "PACKAGING", "Packaging failed: " + result.getMessage());
                            statusLabel.setText("Packaging failed");
                            
                            // Show error dialog
                            showMessage("Packaging failed: " + result.getMessage(), "Packaging Error", JOptionPane.ERROR_MESSAGE);
                        }
                        
                        packageButton.setEnabled(true);
                    });
                } catch (Exception e) {
                    SwingUtilities.invokeLater(() -> {
                        consolePanel.appendMessage("ERROR", "PACKAGING", "Packaging failed: " + e.getMessage());
                        statusLabel.setText("Packaging failed");
                        packageButton.setEnabled(true);
                        showMessage("Packaging failed: " + e.getMessage(), "Packaging Error", JOptionPane.ERROR_MESSAGE);
                    });
                }
                return null;
            }
        };
        
        worker.execute();
    }
    
    private void resetForm() {
        fileSelectionPanel.reset();
        packageConfigPanel.reset();
        advancedOptionsPanel.reset();
        consolePanel.clear();
        statusLabel.setText("Ready");
        log.info("Form reset to default values");
    }
    
    private void toggleTheme() {
        if (darkThemeMenuItem.isSelected()) {
            applyDarkTheme();
        } else {
            applyLightTheme();
        }
    }
    
    private void applyDarkTheme() {
        try {
            UIManager.setLookAndFeel(new FlatDarkLaf());
            SwingUtilities.updateComponentTreeUI(this);
            log.info("Dark theme applied");
        } catch (Exception e) {
            log.error("Failed to apply dark theme", e);
        }
    }
    
    private void applyLightTheme() {
        try {
            UIManager.setLookAndFeel(new FlatLightLaf());
            SwingUtilities.updateComponentTreeUI(this);
            log.info("Light theme applied");
        } catch (Exception e) {
            log.error("Failed to apply light theme", e);
        }
    }
    
    private void showSetupGuide() {
        SetupGuideDialog setupDialog = new SetupGuideDialog(this);
        setupDialog.showDialog();
    }
    
    private void showAbout() {
        String message = String.format(
            "Packaroo Desktop\n\n" +
            "Version: %s\n" +
            "A modern Java application packaging tool\n\n" +
            "Features:\n" +
            "• JAR dependency analysis\n" +
            "• Custom JLink runtime creation\n" +
            "• Native application packaging\n" +
            "• Cross-platform support\n\n" +
            "Built with Swing and Spring Boot\n" +
            "© 2025 DevDam",
            applicationVersion
        );
        
        JOptionPane.showMessageDialog(this, message, "About Packaroo", JOptionPane.INFORMATION_MESSAGE);
    }
    
    private void showMessage(String message, String title, int messageType) {
        JOptionPane.showMessageDialog(this, message, title, messageType);
    }
    
    private PackageConfiguration getConfigurationFromUI() {
        return PackageConfiguration.builder()
                .jarFile(fileSelectionPanel.getJarFilePath().isEmpty() ? 
                    null : java.nio.file.Paths.get(fileSelectionPanel.getJarFilePath()))
                .iconFile(fileSelectionPanel.getIconFilePath().isEmpty() ? 
                    null : java.nio.file.Paths.get(fileSelectionPanel.getIconFilePath()))
                .outputDirectory(fileSelectionPanel.getOutputDirectoryPath().isEmpty() ? 
                    null : java.nio.file.Paths.get(fileSelectionPanel.getOutputDirectoryPath()))
                .appName(packageConfigPanel.getAppName())
                .version(packageConfigPanel.getVersion())
                .mainClass(packageConfigPanel.getMainClass())
                .vendor(packageConfigPanel.getVendor())
                .description(packageConfigPanel.getDescription())
                .copyright(packageConfigPanel.getCopyright())
                .targetPlatform(packageConfigPanel.getTargetPlatform())
                .outputFormat(packageConfigPanel.getOutputFormat())
                .enableJLink(advancedOptionsPanel.isJLinkEnabled())
                .requiredModules(advancedOptionsPanel.getSelectedModules())
                .jvmArgs(advancedOptionsPanel.getJvmArgs().isEmpty() ? null : advancedOptionsPanel.getJvmArgs())
                .appArgs(advancedOptionsPanel.getAppArgs().isEmpty() ? null : advancedOptionsPanel.getAppArgs())
                .build();
    }
    
    private void updateUIFromConfiguration(PackageConfiguration config) {
        // Update file selection panel
        fileSelectionPanel.setJarFilePath(config.getJarFile() != null ? config.getJarFile().toString() : "");
        fileSelectionPanel.setIconFilePath(config.getIconFile() != null ? config.getIconFile().toString() : "");
        fileSelectionPanel.setOutputDirectoryPath(config.getOutputDirectory() != null ? config.getOutputDirectory().toString() : "");
        
        // Update package config panel
        packageConfigPanel.setAppName(config.getAppName() != null ? config.getAppName() : "");
        packageConfigPanel.setVersion(config.getVersion() != null ? config.getVersion() : "");
        packageConfigPanel.setMainClass(config.getMainClass() != null ? config.getMainClass() : "");
        packageConfigPanel.setVendor(config.getVendor() != null ? config.getVendor() : "");
        packageConfigPanel.setDescription(config.getDescription() != null ? config.getDescription() : "");
        packageConfigPanel.setCopyright(config.getCopyright() != null ? config.getCopyright() : "");
        packageConfigPanel.setTargetPlatform(config.getTargetPlatform() != null ? 
            config.getTargetPlatform() : PackageConfiguration.TargetPlatform.CURRENT);
        packageConfigPanel.setOutputFormat(config.getOutputFormat() != null ? 
            config.getOutputFormat() : PackageConfiguration.OutputFormat.APP_IMAGE);
        
        // Update advanced options panel
        advancedOptionsPanel.setJLinkEnabled(config.isEnableJLink());
        advancedOptionsPanel.setSelectedModules(config.getRequiredModules());
        advancedOptionsPanel.setJvmArgs(config.getJvmArgs());
        advancedOptionsPanel.setAppArgs(config.getAppArgs());
    }
    
    // Getters for panels (for use by other components)
    public FileSelectionPanel getFileSelectionPanel() { return fileSelectionPanel; }
    public PackageConfigPanel getPackageConfigPanel() { return packageConfigPanel; }
    public AdvancedOptionsPanel getAdvancedOptionsPanel() { return advancedOptionsPanel; }
    public ConsolePanel getConsolePanel() { return consolePanel; }
    public JLabel getStatusLabel() { return statusLabel; }
    public JProgressBar getProgressBar() { return progressBar; }
}
