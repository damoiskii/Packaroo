package com.devdam.desktop.ui.panels;

import lombok.extern.slf4j.Slf4j;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import java.awt.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@Slf4j
public class AdvancedOptionsPanel extends JPanel {
    
    private JCheckBox enableJLinkCheck;
    private JList<String> modulesList;
    private DefaultListModel<String> modulesListModel;
    private JTextField customModuleField;
    private JButton addModuleButton;
    private JTextArea jvmArgsArea;
    private JTextArea appArgsArea;
    
    public AdvancedOptionsPanel() {
        initializeComponents();
        layoutComponents();
        setupEventHandlers();
    }
    
    private void initializeComponents() {
        setBorder(new TitledBorder("Advanced Options"));
        
        // JLink options
        enableJLinkCheck = new JCheckBox("Enable JLink Runtime Creation");
        
        // Modules list
        modulesListModel = new DefaultListModel<>();
        populateModulesList();
        modulesList = new JList<>(modulesListModel);
        modulesList.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
        modulesList.setVisibleRowCount(6);
        
        // Custom module input
        customModuleField = new JTextField();
        addModuleButton = new JButton("Add Module");
        
        // JVM and App arguments
        jvmArgsArea = new JTextArea(4, 30);
        jvmArgsArea.setLineWrap(true);
        jvmArgsArea.setWrapStyleWord(true);
        
        appArgsArea = new JTextArea(4, 30);
        appArgsArea.setLineWrap(true);
        appArgsArea.setWrapStyleWord(true);
        
        // Initially disable JLink components
        updateJLinkComponentsState();
    }
    
    private void populateModulesList() {
        // Common Java modules that might be needed
        String[] commonModules = {
            "java.base",
            "java.desktop",
            "java.logging",
            "java.xml",
            "java.prefs",
            "java.net.http",
            "java.management",
            "java.security.sasl",
            "java.naming",
            "java.sql",
            "java.rmi",
            "java.scripting",
            "java.compiler",
            "java.instrument",
            "jdk.unsupported"
        };
        
        for (String module : commonModules) {
            modulesListModel.addElement(module);
        }
    }
    
    private void layoutComponents() {
        setLayout(new BorderLayout());
        
        // Top panel for JLink configuration
        JPanel jlinkPanel = new JPanel(new BorderLayout());
        jlinkPanel.setBorder(new TitledBorder("JLink Configuration"));
        
        jlinkPanel.add(enableJLinkCheck, BorderLayout.NORTH);
        
        // Modules panel
        JPanel modulesPanel = new JPanel(new BorderLayout());
        modulesPanel.add(new JLabel("Required Modules:"), BorderLayout.NORTH);
        modulesPanel.add(new JScrollPane(modulesList), BorderLayout.CENTER);
        
        // Custom module panel
        JPanel customModulePanel = new JPanel(new BorderLayout());
        customModulePanel.add(new JLabel("Add Custom Module:"), BorderLayout.NORTH);
        
        JPanel moduleInputPanel = new JPanel(new BorderLayout());
        moduleInputPanel.add(customModuleField, BorderLayout.CENTER);
        moduleInputPanel.add(addModuleButton, BorderLayout.EAST);
        customModulePanel.add(moduleInputPanel, BorderLayout.CENTER);
        
        modulesPanel.add(customModulePanel, BorderLayout.SOUTH);
        jlinkPanel.add(modulesPanel, BorderLayout.CENTER);
        
        // Arguments panel
        JPanel argsPanel = new JPanel(new GridLayout(1, 2, 10, 0));
        
        // JVM Args
        JPanel jvmPanel = new JPanel(new BorderLayout());
        jvmPanel.setBorder(new TitledBorder("JVM Arguments"));
        jvmPanel.add(new JLabel("One argument per line:"), BorderLayout.NORTH);
        jvmPanel.add(new JScrollPane(jvmArgsArea), BorderLayout.CENTER);
        
        // App Args
        JPanel appPanel = new JPanel(new BorderLayout());
        appPanel.setBorder(new TitledBorder("Application Arguments"));
        appPanel.add(new JLabel("One argument per line:"), BorderLayout.NORTH);
        appPanel.add(new JScrollPane(appArgsArea), BorderLayout.CENTER);
        
        argsPanel.add(jvmPanel);
        argsPanel.add(appPanel);
        
        // Main layout
        add(jlinkPanel, BorderLayout.CENTER);
        add(argsPanel, BorderLayout.SOUTH);
    }
    
    private void setupEventHandlers() {
        enableJLinkCheck.addActionListener(e -> updateJLinkComponentsState());
        
        addModuleButton.addActionListener(e -> addCustomModule());
        
        // Add module on Enter key
        customModuleField.addActionListener(e -> addCustomModule());
    }
    
    private void updateJLinkComponentsState() {
        boolean enabled = enableJLinkCheck.isSelected();
        modulesList.setEnabled(enabled);
        customModuleField.setEnabled(enabled);
        addModuleButton.setEnabled(enabled);
    }
    
    private void addCustomModule() {
        String module = customModuleField.getText().trim();
        if (!module.isEmpty() && !modulesListModel.contains(module)) {
            modulesListModel.addElement(module);
            customModuleField.setText("");
        }
    }
    
    // Getters for values
    public boolean isJLinkEnabled() {
        return enableJLinkCheck.isSelected();
    }
    
    public Set<String> getSelectedModules() {
        List<String> selected = modulesList.getSelectedValuesList();
        return Set.copyOf(selected);
    }
    
    public List<String> getJvmArgs() {
        String text = jvmArgsArea.getText().trim();
        if (text.isEmpty()) {
            return new ArrayList<>();
        }
        return List.of(text.split("\n"));
    }
    
    public List<String> getAppArgs() {
        String text = appArgsArea.getText().trim();
        if (text.isEmpty()) {
            return new ArrayList<>();
        }
        return List.of(text.split("\n"));
    }
    
    // Setters for values
    public void setJLinkEnabled(boolean enabled) {
        enableJLinkCheck.setSelected(enabled);
        updateJLinkComponentsState();
    }
    
    public void setSelectedModules(Set<String> modules) {
        modulesList.clearSelection();
        if (modules != null) {
            for (String module : modules) {
                int index = modulesListModel.indexOf(module);
                if (index >= 0) {
                    modulesList.addSelectionInterval(index, index);
                } else {
                    // Add custom module if not in list
                    modulesListModel.addElement(module);
                    int newIndex = modulesListModel.indexOf(module);
                    modulesList.addSelectionInterval(newIndex, newIndex);
                }
            }
        }
    }
    
    public void setJvmArgs(List<String> args) {
        if (args == null || args.isEmpty()) {
            jvmArgsArea.setText("");
        } else {
            jvmArgsArea.setText(String.join("\n", args));
        }
    }
    
    public void setAppArgs(List<String> args) {
        if (args == null || args.isEmpty()) {
            appArgsArea.setText("");
        } else {
            appArgsArea.setText(String.join("\n", args));
        }
    }
    
    // Reset all fields
    public void reset() {
        enableJLinkCheck.setSelected(false);
        modulesList.clearSelection();
        customModuleField.setText("");
        jvmArgsArea.setText("");
        appArgsArea.setText("");
        updateJLinkComponentsState();
    }
}
