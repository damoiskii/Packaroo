package com.devdam.desktop.ui.panels;

import com.devdam.desktop.model.PackageConfiguration;
import com.devdam.desktop.ui.components.ModernPanel;
import lombok.extern.slf4j.Slf4j;

import javax.swing.*;
import java.awt.*;

@Slf4j
public class PackageConfigPanel extends ModernPanel {
    
    private JTextField appNameField;
    private JTextField versionField;
    private JTextField mainClassField;
    private JTextField vendorField;
    private JTextArea descriptionArea;
    private JTextField copyrightField;
    private JComboBox<PackageConfiguration.TargetPlatform> targetPlatformCombo;
    private JComboBox<PackageConfiguration.OutputFormat> outputFormatCombo;
    
    public PackageConfigPanel() {
        super("Package Configuration");
        initializeComponents();
        layoutComponents();
    }
    
    private void initializeComponents() {
        // Text fields
        appNameField = new JTextField();
        appNameField.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        versionField = new JTextField();
        versionField.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        mainClassField = new JTextField();
        mainClassField.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        vendorField = new JTextField();
        vendorField.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        copyrightField = new JTextField();
        copyrightField.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        
        // Description area
        descriptionArea = new JTextArea(3, 30);
        descriptionArea.setLineWrap(true);
        descriptionArea.setWrapStyleWord(true);
        
        // Combo boxes
        targetPlatformCombo = new JComboBox<>(PackageConfiguration.TargetPlatform.values());
        targetPlatformCombo.setSelectedItem(PackageConfiguration.TargetPlatform.CURRENT);
        
        outputFormatCombo = new JComboBox<>(PackageConfiguration.OutputFormat.values());
        outputFormatCombo.setSelectedItem(PackageConfiguration.OutputFormat.APP_IMAGE);
    }
    
    private void layoutComponents() {
        setLayout(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.anchor = GridBagConstraints.WEST;
        
        // Row 0: App Name and Version
        gbc.gridx = 0; gbc.gridy = 0;
        add(new JLabel("App Name:"), gbc);
        
        gbc.gridx = 1; gbc.fill = GridBagConstraints.HORIZONTAL; gbc.weightx = 0.5;
        add(appNameField, gbc);
        
        gbc.gridx = 2; gbc.fill = GridBagConstraints.NONE; gbc.weightx = 0;
        add(new JLabel("Version:"), gbc);
        
        gbc.gridx = 3; gbc.fill = GridBagConstraints.HORIZONTAL; gbc.weightx = 0.5;
        add(versionField, gbc);
        
        // Row 1: Main Class
        gbc.gridx = 0; gbc.gridy = 1; gbc.weightx = 0;
        add(new JLabel("Main Class:"), gbc);
        
        gbc.gridx = 1; gbc.gridwidth = 3; gbc.fill = GridBagConstraints.HORIZONTAL; gbc.weightx = 1.0;
        add(mainClassField, gbc);
        
        // Row 2: Vendor and Copyright
        gbc.gridx = 0; gbc.gridy = 2; gbc.gridwidth = 1; gbc.weightx = 0;
        add(new JLabel("Vendor:"), gbc);
        
        gbc.gridx = 1; gbc.fill = GridBagConstraints.HORIZONTAL; gbc.weightx = 0.5;
        add(vendorField, gbc);
        
        gbc.gridx = 2; gbc.fill = GridBagConstraints.NONE; gbc.weightx = 0;
        add(new JLabel("Copyright:"), gbc);
        
        gbc.gridx = 3; gbc.fill = GridBagConstraints.HORIZONTAL; gbc.weightx = 0.5;
        add(copyrightField, gbc);
        
        // Row 3: Description
        gbc.gridx = 0; gbc.gridy = 3; gbc.weightx = 0; gbc.anchor = GridBagConstraints.NORTHWEST;
        add(new JLabel("Description:"), gbc);
        
        gbc.gridx = 1; gbc.gridwidth = 3; gbc.fill = GridBagConstraints.BOTH; gbc.weightx = 1.0; gbc.weighty = 1.0;
        add(new JScrollPane(descriptionArea), gbc);
        
        // Row 4: Platform and Format
        gbc.gridx = 0; gbc.gridy = 4; gbc.gridwidth = 1; gbc.fill = GridBagConstraints.NONE; 
        gbc.weightx = 0; gbc.weighty = 0; gbc.anchor = GridBagConstraints.WEST;
        add(new JLabel("Target Platform:"), gbc);
        
        gbc.gridx = 1; gbc.fill = GridBagConstraints.HORIZONTAL; gbc.weightx = 0.5;
        add(targetPlatformCombo, gbc);
        
        gbc.gridx = 2; gbc.fill = GridBagConstraints.NONE; gbc.weightx = 0;
        add(new JLabel("Output Format:"), gbc);
        
        gbc.gridx = 3; gbc.fill = GridBagConstraints.HORIZONTAL; gbc.weightx = 0.5;
        add(outputFormatCombo, gbc);
    }
    
    // Getters for field values
    public String getAppName() {
        return appNameField.getText().trim();
    }
    
    public String getVersion() {
        return versionField.getText().trim();
    }
    
    public String getMainClass() {
        return mainClassField.getText().trim();
    }
    
    public String getVendor() {
        return vendorField.getText().trim();
    }
    
    public String getDescription() {
        return descriptionArea.getText().trim();
    }
    
    public String getCopyright() {
        return copyrightField.getText().trim();
    }
    
    public PackageConfiguration.TargetPlatform getTargetPlatform() {
        return (PackageConfiguration.TargetPlatform) targetPlatformCombo.getSelectedItem();
    }
    
    public PackageConfiguration.OutputFormat getOutputFormat() {
        return (PackageConfiguration.OutputFormat) outputFormatCombo.getSelectedItem();
    }
    
    // Setters for field values
    public void setAppName(String appName) {
        appNameField.setText(appName);
    }
    
    public void setVersion(String version) {
        versionField.setText(version);
    }
    
    public void setMainClass(String mainClass) {
        mainClassField.setText(mainClass);
    }
    
    public void setVendor(String vendor) {
        vendorField.setText(vendor);
    }
    
    public void setDescription(String description) {
        descriptionArea.setText(description);
    }
    
    public void setCopyright(String copyright) {
        copyrightField.setText(copyright);
    }
    
    public void setTargetPlatform(PackageConfiguration.TargetPlatform platform) {
        targetPlatformCombo.setSelectedItem(platform);
    }
    
    public void setOutputFormat(PackageConfiguration.OutputFormat format) {
        outputFormatCombo.setSelectedItem(format);
    }
    
    // Reset all fields
    public void reset() {
        appNameField.setText("");
        versionField.setText("");
        mainClassField.setText("");
        vendorField.setText("");
        descriptionArea.setText("");
        copyrightField.setText("");
        targetPlatformCombo.setSelectedItem(PackageConfiguration.TargetPlatform.CURRENT);
        outputFormatCombo.setSelectedItem(PackageConfiguration.OutputFormat.APP_IMAGE);
    }
}
