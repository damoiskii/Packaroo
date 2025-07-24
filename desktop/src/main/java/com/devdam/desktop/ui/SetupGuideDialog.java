package com.devdam.desktop.ui;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

@Slf4j
@Component
public class SetupGuideDialog extends JDialog {
    
    private JTextArea contentArea;
    private JButton closeButton;
    
    public SetupGuideDialog(Frame parent) {
        super(parent, "Setup Guide", true);
        initializeComponents();
        layoutComponents();
        setupEventHandlers();
        loadContent();
        setLocationRelativeTo(parent);
    }
    
    private void initializeComponents() {
        setDefaultCloseOperation(DISPOSE_ON_CLOSE);
        setSize(800, 600);
        
        // Content area
        contentArea = new JTextArea();
        contentArea.setEditable(false);
        contentArea.setFont(new Font(Font.MONOSPACED, Font.PLAIN, 12));
        contentArea.setLineWrap(true);
        contentArea.setWrapStyleWord(true);
        contentArea.setBackground(new Color(248, 249, 250));
        contentArea.setBorder(new EmptyBorder(15, 15, 15, 15));
        
        // Close button
        closeButton = new JButton("Close");
    }
    
    private void layoutComponents() {
        setLayout(new BorderLayout());
        
        // Title panel
        JPanel titlePanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
        JLabel titleLabel = new JLabel("Java Tools Setup Guide");
        titleLabel.setFont(new Font(Font.SANS_SERIF, Font.BOLD, 18));
        titleLabel.setForeground(new Color(26, 109, 255));
        titlePanel.add(titleLabel);
        titlePanel.setBorder(new EmptyBorder(10, 10, 10, 10));
        
        // Content scroll pane
        JScrollPane scrollPane = new JScrollPane(contentArea);
        scrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        
        // Button panel
        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        buttonPanel.add(closeButton);
        buttonPanel.setBorder(new EmptyBorder(10, 10, 10, 10));
        
        add(titlePanel, BorderLayout.NORTH);
        add(scrollPane, BorderLayout.CENTER);
        add(buttonPanel, BorderLayout.SOUTH);
    }
    
    private void setupEventHandlers() {
        closeButton.addActionListener(e -> dispose());
        
        // Close on Escape key
        getRootPane().registerKeyboardAction(
            e -> dispose(),
            KeyStroke.getKeyStroke("ESCAPE"),
            JComponent.WHEN_IN_FOCUSED_WINDOW
        );
    }
    
    private void loadContent() {
        String content = buildSetupContent();
        contentArea.setText(content);
        contentArea.setCaretPosition(0);
    }
    
    private String buildSetupContent() {
        return """
                JAVA TOOLS SETUP GUIDE
                ====================
                
                This guide will help you set up the required Java tools for packaging applications with Packaroo.
                
                PREREQUISITES
                -------------
                
                To package Java applications, you need:
                • JDK 17 or higher with jpackage tool
                • jlink tool (included with JDK 9+)
                • jdeps tool (included with JDK 8+)
                • Platform-specific packaging tools (optional)
                
                
                WINDOWS SETUP
                =============
                
                1. Install JDK 17+ from Oracle or OpenJDK:
                   • Download from https://jdk.java.net/ or https://adoptium.net/
                   • Run the installer and follow the setup wizard
                
                2. Set JAVA_HOME environment variable:
                   • Open System Properties → Advanced → Environment Variables
                   • Add new system variable: JAVA_HOME = C:\\Program Files\\Java\\jdk-17
                   • Update PATH to include %JAVA_HOME%\\bin
                
                3. Verify installation:
                   Open Command Prompt and run:
                   java --version
                   jpackage --version
                   jlink --version
                   jdeps --version
                
                4. For MSI/EXE packaging (optional):
                   Install WiX Toolset v3.11+ from https://wixtoolset.org/
                
                
                MACOS SETUP
                ===========
                
                1. Install JDK 17+ using Homebrew or direct download:
                   
                   Using Homebrew:
                   brew install openjdk@17
                   
                   Or download from Oracle/OpenJDK
                
                2. Set JAVA_HOME in ~/.zshrc or ~/.bash_profile:
                   export JAVA_HOME=/opt/homebrew/opt/openjdk@17
                   export PATH=$JAVA_HOME/bin:$PATH
                
                3. Verify installation:
                   java --version
                   jpackage --version
                   jlink --version
                   jdeps --version
                
                4. For DMG/PKG packaging: Install Xcode Command Line Tools:
                   xcode-select --install
                
                
                LINUX SETUP
                ===========
                
                1. Install JDK 17+ using package manager:
                   
                   Ubuntu/Debian:
                   sudo apt update && sudo apt install openjdk-17-jdk
                   
                   Alternative (if you encounter issues):
                   sudo apt update && sudo apt install openjdk-17-jdk-headless
                   
                   CentOS/RHEL:
                   sudo yum install java-17-openjdk-devel
                   
                   Arch:
                   sudo pacman -S jdk17-openjdk
                
                2. Set JAVA_HOME (if not set automatically):
                   Add to ~/.bashrc or ~/.zshrc:
                   export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
                   export PATH=$JAVA_HOME/bin:$PATH
                
                3. Verify installation:
                   java --version
                   jpackage --version
                   jlink --version
                   jdeps --version
                
                4. For DEB/RPM packaging: Install fakeroot (usually pre-installed):
                   sudo apt install fakeroot  # Ubuntu/Debian
                   sudo yum install fakeroot   # CentOS/RHEL
                
                
                TROUBLESHOOTING
                ===============
                
                Common Issues:
                
                • "jpackage command not found":
                  - Ensure you have JDK 14+ (jpackage was added in JDK 14)
                  - Check that JAVA_HOME is set correctly
                  - Verify that $JAVA_HOME/bin is in your PATH
                
                • "No application image directory specified":
                  - This occurs when jpackage can't find the required files
                  - Make sure your JAR file path is correct
                  - Verify that the output directory exists and is writable
                
                • "Module not found" errors:
                  - Use the JAR analysis feature to identify required modules
                  - Add missing modules to the JLink configuration
                  - Consider using --add-modules ALL-SYSTEM for simple applications
                
                • Platform-specific packaging fails:
                  - Ensure platform tools are installed (WiX on Windows, Xcode tools on macOS)
                  - Try creating an app-image first, then package it
                  - Check file permissions and available disk space
                
                
                GETTING STARTED
                ===============
                
                Once your tools are set up:
                
                1. Select your JAR file using the "Browse" button
                2. Use "Analyze JAR" to automatically detect dependencies and modules
                3. Configure your application details (name, version, etc.)
                4. Choose your target platform and output format
                5. Set up JLink options if needed for a custom runtime
                6. Click "Package Application" to create your distributable
                
                For more help, check the console output for detailed logging and error messages.
                
                
                ADDITIONAL RESOURCES
                ====================
                
                • Oracle JPackage Documentation: https://docs.oracle.com/en/java/javase/17/docs/specs/man/jpackage.html
                • OpenJDK JLink Guide: https://docs.oracle.com/en/java/javase/17/docs/specs/man/jlink.html
                • Java Module System: https://docs.oracle.com/javase/9/docs/api/java.base/module-summary.html
                
                """;
    }
    
    public void showDialog() {
        setVisible(true);
    }
}
