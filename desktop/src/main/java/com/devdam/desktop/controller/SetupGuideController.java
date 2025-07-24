package com.devdam.desktop.controller;

import com.devdam.desktop.service.ViewManager;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.*;
import javafx.scene.layout.VBox;
import javafx.scene.web.WebEngine;
import javafx.scene.web.WebView;
import javafx.stage.Stage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.net.URL;
import java.util.ResourceBundle;
import java.util.prefs.Preferences;

@Slf4j
@Component
public class SetupGuideController implements Initializable {
    
    @FXML private VBox rootPane;
    @FXML private CheckMenuItem darkThemeCheck;
    @FXML private MenuItem newConfigMenuItem;
    @FXML private MenuItem openConfigMenuItem;
    @FXML private MenuItem saveConfigMenuItem;
    @FXML private MenuItem exitMenuItem;
    @FXML private MenuItem analyzeJarMenuItem;
    @FXML private MenuItem packageAppMenuItem;
    @FXML private MenuItem clearConsoleMenuItem;
    @FXML private MenuItem setupMenuItem;
    @FXML private MenuItem aboutMenuItem;
    @FXML private Button backToMainButton;
    @FXML private WebView setupWebView;

    @Autowired
    private ViewManager viewManager;

    // Preferences for theme persistence
    private static final Preferences prefs = Preferences.userRoot().node("com/devdam/desktop/theme");
    private static final String DARK_THEME_KEY = "darkTheme";

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        setupMenuHandlers();
        initializeSetupWebView();
        loadThemeState();
    }

    private void setupMenuHandlers() {
        // File Menu
        newConfigMenuItem.setOnAction(e -> returnToMainAndExecute("newConfiguration"));
        openConfigMenuItem.setOnAction(e -> returnToMainAndExecute("openConfiguration"));
        saveConfigMenuItem.setOnAction(e -> returnToMainAndExecute("saveConfiguration"));
        exitMenuItem.setOnAction(e -> System.exit(0));

        // Tools Menu
        analyzeJarMenuItem.setOnAction(e -> returnToMainAndExecute("analyzeJar"));
        packageAppMenuItem.setOnAction(e -> returnToMainAndExecute("packageApplication"));
        clearConsoleMenuItem.setOnAction(e -> returnToMainAndExecute("clearConsole"));

        // Help Menu
        setupMenuItem.setOnAction(e -> {
            // Already in setup guide, do nothing or refresh
            initializeSetupWebView();
        });
        aboutMenuItem.setOnAction(e -> showAboutDialog());
        
        // View Menu
        darkThemeCheck.setOnAction(e -> toggleDarkTheme());
        
        // Navigation
        backToMainButton.setOnAction(e -> showMainView());
    }

    private void returnToMainAndExecute(String action) {
        // Return to main view first, then execute the action
        // This is a simplified approach - in a real app you might want to pass parameters
        showMainView();
    }

    private void toggleDarkTheme() {
        boolean isDarkTheme = darkThemeCheck.isSelected();
        if (isDarkTheme) {
            rootPane.getStyleClass().add("dark-theme");
        } else {
            rootPane.getStyleClass().remove("dark-theme");
        }
        
        // Save theme preference
        prefs.putBoolean(DARK_THEME_KEY, isDarkTheme);
        
        // Refresh WebView content to apply new theme
        initializeSetupWebView();
    }

    private void loadThemeState() {
        // Load theme preference
        boolean isDarkTheme = prefs.getBoolean(DARK_THEME_KEY, false);
        darkThemeCheck.setSelected(isDarkTheme);
        
        if (isDarkTheme) {
            rootPane.getStyleClass().add("dark-theme");
        }
    }

    private void showMainView() {
        viewManager.showMainView();
    }

    private void initializeSetupWebView() {
        if (setupWebView != null) {
            WebEngine webEngine = setupWebView.getEngine();
            String htmlContent = buildSetupContentAsHTML();
            webEngine.loadContent(htmlContent);
        }
    }

    private String buildSetupContentAsHTML() {
        // Check if dark theme is active
        boolean isDarkTheme = darkThemeCheck.isSelected();
        
        String themeStyles;
        if (isDarkTheme) {
            // Dark theme styles
            themeStyles = 
                "body { background-color: #1a1a2e; color: #e0e0e0; }" +
                "h1, h2, h3 { color: #6DC7FF; }" +
                "pre, code { background-color: #2a2a4a; color: #e0e0e0; border: 1px solid #444; }" +
                "li { margin-bottom: 4px; }" +
                "strong { color: #81c784; }" +
                ".warning { background-color: #3e2723; border-left: 4px solid #ff9800; color: #ffcc80; }" +
                ".info { background-color: #0d47a1; border-left: 4px solid #64b5f6; color: #bbdefb; }" +
                "a { color: #64b5f6; }" +
                "a:visited { color: #9575cd; }";
        } else {
            // Light theme styles
            themeStyles = 
                "body { background-color: #ffffff; color: #333333; }" +
                "h1, h2, h3 { color: #1976d2; }" +
                "pre, code { background-color: #f5f5f5; color: #333; border: 1px solid #ddd; }" +
                "li { margin-bottom: 4px; }" +
                "strong { color: #2e7d32; }" +
                ".warning { background-color: #fff3e0; border-left: 4px solid #ff9800; }" +
                ".info { background-color: #e3f2fd; border-left: 4px solid #2196f3; }";
        }
            
        return "<!DOCTYPE html>" +
               "<html><head>" +
               "<style>" +
               "body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; line-height: 1.6; }" +
               "h1 { border-bottom: 2px solid #ddd; padding-bottom: 10px; margin-bottom: 20px; }" +
               "h2 { margin-top: 30px; margin-bottom: 15px; clear: both; }" +
               "h3 { margin-top: 20px; margin-bottom: 10px; clear: both; }" +
               "pre, code { padding: 8px; border-radius: 4px; font-family: 'Consolas', 'Monaco', monospace; display: block; }" +
               "pre { margin: 10px 0 15px 0; white-space: pre-wrap; overflow-wrap: break-word; clear: both; }" +
               "ul, ol { padding-left: 20px; margin: 10px 0; }" +
               "li { margin-bottom: 8px; line-height: 1.5; }" +
               "li ul, li ol { margin: 5px 0; }" +
               ".warning, .info { padding: 12px; margin: 15px 0; border-radius: 4px; clear: both; }" +
               ".command { font-weight: bold; }" +
               themeStyles +
               "</style></head><body>" +
               
               "<h1>Java Tools Setup Guide</h1>" +
               "<p>This guide will help you set up the required Java tools for packaging applications with Packaroo.</p>" +
               
               "<div class='info'>" +
               "<h3>Prerequisites</h3>" +
               "<ul>" +
               "<li><strong>Java 17 or later</strong> (required for jpackage)</li>" +
               "<li><strong>JAVA_HOME</strong> environment variable set correctly</li>" +
               "</ul>" +
               "</div>" +
               
               "<h2>Windows Setup</h2>" +
               "<ol>" +
               "<li><strong>Install JDK 17+</strong> from <a href='https://jdk.java.net/'>Oracle</a> or <a href='https://adoptium.net/'>OpenJDK</a></li>" +
               "<li><strong>Add JDK to PATH:</strong><br/>" +
               "• Open <code>System Properties → Environment Variables</code><br/>" +
               "• Add to PATH: <code>C:\\Program Files\\Java\\jdk-17\\bin</code></li>" +
               "<li><strong>Verify installation:</strong>" +
               "<pre class='command'>java --version\njpackage --version\njlink --version\njdeps --version</pre></li>" +
               "<li><strong>For MSI/EXE packaging:</strong> Install <a href='https://wixtoolset.org/'>WiX Toolset</a><br/>" +
               "• Add WiX bin directory to PATH</li>" +
               "</ol>" +
               
               "<h2>macOS Setup</h2>" +
               "<ol>" +
               "<li><strong>Install JDK 17+ using Homebrew:</strong>" +
               "<pre class='command'>brew install openjdk@17</pre>" +
               "Or download from <a href='https://jdk.java.net/'>Oracle</a>/<a href='https://adoptium.net/'>OpenJDK</a></li>" +
               "<li><strong>Set JAVA_HOME</strong> in <code>~/.zshrc</code> or <code>~/.bash_profile</code>:" +
               "<pre class='command'>export JAVA_HOME=/opt/homebrew/opt/openjdk@17\nexport PATH=$JAVA_HOME/bin:$PATH</pre></li>" +
               "<li><strong>Verify installation:</strong>" +
               "<pre class='command'>java --version\njpackage --version\njlink --version\njdeps --version</pre></li>" +
               "<li><strong>For DMG/PKG packaging:</strong> Install Xcode Command Line Tools:" +
               "<pre class='command'>xcode-select --install</pre></li>" +
               "</ol>" +
               
               "<h2>Linux Setup</h2>" +
               "<ol>" +
               "<li><strong>Install JDK 17+ using package manager:</strong>" +
               "<pre class='command'># Ubuntu/Debian - Update package list first\nsudo apt update && sudo apt install openjdk-17-jdk\n\n# Alternative: Install headless JDK (if you encounter issues)\nsudo apt update && sudo apt install openjdk-17-jdk-headless\n\n# CentOS/RHEL\nsudo yum install java-17-openjdk-devel\n\n# Arch\nsudo pacman -S jdk17-openjdk</pre></li>" +
               "<li><strong>Set JAVA_HOME</strong> in <code>~/.bashrc</code> or <code>~/.zshrc</code>:" +
               "<pre class='command'>export JAVA_HOME=/usr/lib/jvm/java-17-openjdk\nexport PATH=$JAVA_HOME/bin:$PATH</pre></li>" +
               "<li><strong>Verify installation:</strong>" +
               "<pre class='command'>java --version\njpackage --version\njlink --version\njdeps --version</pre></li>" +
               "<li><strong>For DEB/RPM packaging:</strong>" +
               "<pre class='command'># Ubuntu/Debian\nsudo apt install fakeroot\n\n# CentOS/RHEL\nsudo yum install rpm-build</pre></li>" +
               "</ol>" +
               
               "<div class='warning'>" +
               "<h3>Troubleshooting</h3>" +
               "<ul>" +
               "<li>If tools are not found, <strong>restart your terminal/IDE</strong></li>" +
               "<li>Verify <code>JAVA_HOME</code> points to <strong>JDK (not JRE)</strong></li>" +
               "<li>Ensure <strong>JDK version is 17 or later</strong></li>" +
               "<li>Check <code>PATH</code> includes <strong>JDK bin directory</strong></li>" +
               "<li>For packaging issues, ensure <strong>platform-specific tools are installed</strong></li>" +
               "</ul>" +
               "</div>" +
               
               "<h2>Tool Descriptions</h2>" +
               "<ul>" +
               "<li><strong>jpackage:</strong> Creates native installers from JAR files</li>" +
               "<li><strong>jlink:</strong> Creates custom runtime images with required modules</li>" +
               "<li><strong>jdeps:</strong> Analyzes JAR dependencies and module requirements</li>" +
               "</ul>" +
               
               "<div class='info'>" +
               "<p><strong>For more help:</strong> " +
               "<a href='https://docs.oracle.com/en/java/javase/17/docs/specs/man/'>Oracle JDK Documentation</a></p>" +
               "</div>" +
               
               "</body></html>";
    }

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

    private void showAlert(Alert.AlertType type, String title, String message) {
        Alert alert = new Alert(type);
        alert.setTitle(title);
        alert.setHeaderText(null);
        alert.setContentText(message);
        alert.showAndWait();
    }
}
