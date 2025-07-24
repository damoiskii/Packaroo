package com.devdam.desktop.ui.panels;

import com.devdam.desktop.ui.theme.PackarooTheme;
import com.devdam.desktop.ui.components.ModernButton;
import com.devdam.desktop.ui.components.ModernPanel;
import lombok.extern.slf4j.Slf4j;

import javax.swing.*;
import java.awt.*;
import java.io.File;

@Slf4j
public class FileSelectionPanel extends ModernPanel {
    
    private JTextField jarFileField;
    private JButton browseJarButton;
    private JTextField iconFileField;
    private JButton browseIconButton;
    private JTextField outputDirField;
    private JButton browseOutputButton;
    
    public FileSelectionPanel() {
        super("File Selection");
        initializeComponents();
        layoutComponents();
        setupEventHandlers();
    }
    
    private void initializeComponents() {
        // JAR file selection
        jarFileField = new JTextField();
        jarFileField.setPreferredSize(new Dimension(400, 28));
        jarFileField.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        browseJarButton = new ModernButton("Browse...");
        
        // Icon file selection
        iconFileField = new JTextField();
        iconFileField.setPreferredSize(new Dimension(400, 28));
        iconFileField.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        browseIconButton = new ModernButton("Browse...");
        
        // Output directory selection
        outputDirField = new JTextField();
        outputDirField.setPreferredSize(new Dimension(400, 28));
        outputDirField.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        browseOutputButton = new ModernButton("Browse...");
    }
    
    private void layoutComponents() {
        setLayout(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.anchor = GridBagConstraints.WEST;
        
        // JAR file row
        gbc.gridx = 0; gbc.gridy = 0;
        add(new JLabel("JAR File:"), gbc);
        
        gbc.gridx = 1; gbc.fill = GridBagConstraints.HORIZONTAL; gbc.weightx = 1.0;
        add(jarFileField, gbc);
        
        gbc.gridx = 2; gbc.fill = GridBagConstraints.NONE; gbc.weightx = 0;
        add(browseJarButton, gbc);
        
        // Icon file row
        gbc.gridx = 0; gbc.gridy = 1;
        add(new JLabel("Icon File:"), gbc);
        
        gbc.gridx = 1; gbc.fill = GridBagConstraints.HORIZONTAL; gbc.weightx = 1.0;
        add(iconFileField, gbc);
        
        gbc.gridx = 2; gbc.fill = GridBagConstraints.NONE; gbc.weightx = 0;
        add(browseIconButton, gbc);
        
        // Output directory row
        gbc.gridx = 0; gbc.gridy = 2;
        add(new JLabel("Output Directory:"), gbc);
        
        gbc.gridx = 1; gbc.fill = GridBagConstraints.HORIZONTAL; gbc.weightx = 1.0;
        add(outputDirField, gbc);
        
        gbc.gridx = 2; gbc.fill = GridBagConstraints.NONE; gbc.weightx = 0;
        add(browseOutputButton, gbc);
    }
    
    private void setupEventHandlers() {
        browseJarButton.addActionListener(e -> browseJarFile());
        browseIconButton.addActionListener(e -> browseIconFile());
        browseOutputButton.addActionListener(e -> browseOutputDirectory());
    }
    
    private void browseJarFile() {
        JFileChooser fileChooser = new JFileChooser();
        fileChooser.setFileFilter(new javax.swing.filechooser.FileNameExtensionFilter(
            "JAR Files", "jar"));
        
        int result = fileChooser.showOpenDialog(this);
        if (result == JFileChooser.APPROVE_OPTION) {
            File selectedFile = fileChooser.getSelectedFile();
            jarFileField.setText(selectedFile.getAbsolutePath());
            
            // Auto-populate output directory based on JAR file location
            if (outputDirField.getText().trim().isEmpty()) {
                File parentDir = selectedFile.getParentFile();
                if (parentDir != null) {
                    outputDirField.setText(new File(parentDir, "output").getAbsolutePath());
                }
            }
        }
    }
    
    private void browseIconFile() {
        JFileChooser fileChooser = new JFileChooser();
        fileChooser.setFileFilter(new javax.swing.filechooser.FileNameExtensionFilter(
            "Image Files", "png", "jpg", "jpeg", "gif", "ico"));
        
        int result = fileChooser.showOpenDialog(this);
        if (result == JFileChooser.APPROVE_OPTION) {
            iconFileField.setText(fileChooser.getSelectedFile().getAbsolutePath());
        }
    }
    
    private void browseOutputDirectory() {
        JFileChooser fileChooser = new JFileChooser();
        fileChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
        
        int result = fileChooser.showOpenDialog(this);
        if (result == JFileChooser.APPROVE_OPTION) {
            outputDirField.setText(fileChooser.getSelectedFile().getAbsolutePath());
        }
    }
    
    // Getters for field values
    public String getJarFilePath() {
        return jarFileField.getText().trim();
    }
    
    public String getIconFilePath() {
        return iconFileField.getText().trim();
    }
    
    public String getOutputDirectoryPath() {
        return outputDirField.getText().trim();
    }
    
    // Setters for field values
    public void setJarFilePath(String path) {
        jarFileField.setText(path);
    }
    
    public void setIconFilePath(String path) {
        iconFileField.setText(path);
    }
    
    public void setOutputDirectoryPath(String path) {
        outputDirField.setText(path);
    }
    
    // Reset all fields
    public void reset() {
        jarFileField.setText("");
        iconFileField.setText("");
        outputDirField.setText("");
    }
}
