package com.devdam.desktop.ui.panels;

import lombok.extern.slf4j.Slf4j;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import java.awt.*;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Slf4j
public class ConsolePanel extends JPanel {
    
    private JTextArea consoleArea;
    private JButton clearButton;
    private JButton exportButton;
    private JCheckBox autoScrollCheck;
    
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm:ss");
    
    public ConsolePanel() {
        initializeComponents();
        layoutComponents();
        setupEventHandlers();
    }
    
    private void initializeComponents() {
        setBorder(new TitledBorder("Console Output"));
        
        // Console text area
        consoleArea = new JTextArea();
        consoleArea.setEditable(false);
        consoleArea.setFont(new Font(Font.MONOSPACED, Font.PLAIN, 12));
        consoleArea.setBackground(new Color(40, 44, 52));
        consoleArea.setForeground(new Color(171, 178, 191));
        consoleArea.setCaretColor(Color.WHITE);
        
        // Control buttons
        clearButton = new JButton("Clear");
        exportButton = new JButton("Export Logs");
        autoScrollCheck = new JCheckBox("Auto Scroll", true);
    }
    
    private void layoutComponents() {
        setLayout(new BorderLayout());
        
        // Console area with scroll pane
        JScrollPane scrollPane = new JScrollPane(consoleArea);
        scrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        scrollPane.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        add(scrollPane, BorderLayout.CENTER);
        
        // Control panel
        JPanel controlPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        controlPanel.add(autoScrollCheck);
        controlPanel.add(clearButton);
        controlPanel.add(exportButton);
        
        add(controlPanel, BorderLayout.SOUTH);
    }
    
    private void setupEventHandlers() {
        clearButton.addActionListener(e -> clear());
        exportButton.addActionListener(e -> exportLogs());
    }
    
    public void appendMessage(String level, String category, String message) {
        SwingUtilities.invokeLater(() -> {
            String timestamp = LocalDateTime.now().format(TIME_FORMATTER);
            String formattedMessage = String.format("[%s] %s - %s: %s%n", 
                timestamp, level, category, message);
            
            consoleArea.append(formattedMessage);
            
            // Auto scroll to bottom if enabled
            if (autoScrollCheck.isSelected()) {
                consoleArea.setCaretPosition(consoleArea.getDocument().getLength());
            }
        });
    }
    
    public void info(String category, String message) {
        appendMessage("INFO", category, message);
    }
    
    public void warn(String category, String message) {
        appendMessage("WARN", category, message);
    }
    
    public void error(String category, String message) {
        appendMessage("ERROR", category, message);
    }
    
    public void success(String category, String message) {
        appendMessage("SUCCESS", category, message);
    }
    
    public void debug(String category, String message) {
        appendMessage("DEBUG", category, message);
    }
    
    public void clear() {
        consoleArea.setText("");
        info("SYSTEM", "Console cleared");
    }
    
    private void exportLogs() {
        JFileChooser fileChooser = new JFileChooser();
        fileChooser.setSelectedFile(new java.io.File("packaroo-logs.txt"));
        fileChooser.setFileFilter(new javax.swing.filechooser.FileNameExtensionFilter(
            "Text Files", "txt"));
        
        int result = fileChooser.showSaveDialog(this);
        if (result == JFileChooser.APPROVE_OPTION) {
            try {
                String content = consoleArea.getText();
                try (FileWriter writer = new FileWriter(fileChooser.getSelectedFile())) {
                    writer.write(content);
                }
                
                JOptionPane.showMessageDialog(this, 
                    "Logs exported successfully!", 
                    "Export Complete", 
                    JOptionPane.INFORMATION_MESSAGE);
                    
                info("SYSTEM", "Logs exported to: " + fileChooser.getSelectedFile().getName());
                
            } catch (IOException e) {
                log.error("Failed to export logs", e);
                JOptionPane.showMessageDialog(this, 
                    "Failed to export logs: " + e.getMessage(), 
                    "Export Error", 
                    JOptionPane.ERROR_MESSAGE);
            }
        }
    }
    
    public String getText() {
        return consoleArea.getText();
    }
    
    public void setText(String text) {
        consoleArea.setText(text);
    }
    
    public JTextArea getConsoleArea() {
        return consoleArea;
    }
}
