package com.devdam.desktop.ui;

import com.devdam.desktop.ui.theme.PackarooTheme;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

@Slf4j
@Component
public class SplashScreen {
    
    private JWindow splashWindow;
    private JProgressBar progressBar;
    private JLabel statusLabel;
    private Timer progressTimer;
    
    @Value("${application.version:1.0.0}")
    private String applicationVersion;
    
    public void showSplash() {
        SwingUtilities.invokeLater(() -> {
            createSplashWindow();
            showWindow();
            startProgressAnimation();
        });
    }
    
    public void hideSplash() {
        SwingUtilities.invokeLater(() -> {
            if (progressTimer != null) {
                progressTimer.stop();
            }
            if (splashWindow != null) {
                splashWindow.setVisible(false);
                splashWindow.dispose();
            }
        });
    }
    
    private void createSplashWindow() {
        splashWindow = new JWindow();
        splashWindow.setSize(600, 400);
        
        // Create main panel with modern styling
        JPanel mainPanel = new JPanel(new BorderLayout()) {
            @Override
            protected void paintComponent(Graphics g) {
                Graphics2D g2d = (Graphics2D) g.create();
                g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
                
                // Paint gradient background
                LinearGradientPaint gradient = new LinearGradientPaint(
                    0, 0, 0, getHeight(),
                    new float[]{0f, 1f},
                    new Color[]{PackarooTheme.BACKGROUND_LIGHT, Color.WHITE}
                );
                g2d.setPaint(gradient);
                g2d.fillRect(0, 0, getWidth(), getHeight());
                
                g2d.dispose();
            }
        };
        
        mainPanel.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(PackarooTheme.PRIMARY_BLUE, 2, true),
            BorderFactory.createEmptyBorder(20, 20, 20, 20)
        ));
        
        // Create logo panel
        JPanel logoPanel = createLogoPanel();
        
        // Create progress panel
        JPanel progressPanel = createProgressPanel();
        
        mainPanel.add(logoPanel, BorderLayout.CENTER);
        mainPanel.add(progressPanel, BorderLayout.SOUTH);
        
        splashWindow.add(mainPanel);
        splashWindow.setLocationRelativeTo(null);
    }
    
    private JPanel createLogoPanel() {
        JPanel logoPanel = new JPanel(new BorderLayout());
        logoPanel.setOpaque(false);
        
        // Title with gradient text effect
        JLabel titleLabel = new JLabel("Packaroo", SwingConstants.CENTER) {
            @Override
            protected void paintComponent(Graphics g) {
                Graphics2D g2d = (Graphics2D) g.create();
                g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
                g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
                
                // Create gradient paint for text
                LinearGradientPaint textGradient = new LinearGradientPaint(
                    0, 0, getWidth(), 0,
                    new float[]{0f, 1f},
                    new Color[]{PackarooTheme.PRIMARY_BLUE, PackarooTheme.PRIMARY_BLUE_LIGHT}
                );
                g2d.setPaint(textGradient);
                
                FontMetrics fm = g2d.getFontMetrics();
                int x = (getWidth() - fm.stringWidth(getText())) / 2;
                int y = ((getHeight() - fm.getHeight()) / 2) + fm.getAscent();
                g2d.drawString(getText(), x, y);
                
                g2d.dispose();
            }
        };
        titleLabel.setFont(new Font("Segoe UI", Font.BOLD, 48));
        titleLabel.setPreferredSize(new Dimension(400, 80));
        
        // Subtitle
        JLabel subtitleLabel = new JLabel("Desktop Application Packager", SwingConstants.CENTER);
        subtitleLabel.setFont(new Font("Segoe UI", Font.PLAIN, 16));
        subtitleLabel.setForeground(PackarooTheme.TEXT_SECONDARY);
        
        // Version label
        JLabel versionLabel = new JLabel("Version 1.0.0", SwingConstants.CENTER);
        versionLabel.setFont(new Font("Segoe UI", Font.PLAIN, 12));
        versionLabel.setForeground(PackarooTheme.TEXT_MUTED);
        
        logoPanel.add(titleLabel, BorderLayout.CENTER);
        
        JPanel textPanel = new JPanel(new GridLayout(2, 1, 0, 5));
        textPanel.setOpaque(false);
        textPanel.add(subtitleLabel);
        textPanel.add(versionLabel);
        
        logoPanel.add(textPanel, BorderLayout.SOUTH);
        
        return logoPanel;
    }
    
    private JPanel createProgressPanel() {
        JPanel progressPanel = new JPanel(new BorderLayout());
        progressPanel.setOpaque(false);
        progressPanel.setBorder(BorderFactory.createEmptyBorder(20, 0, 0, 0));
        
        // Status label
        statusLabel = new JLabel("Loading...", SwingConstants.CENTER);
        statusLabel.setFont(new Font("Segoe UI", Font.PLAIN, 14));
        statusLabel.setForeground(PackarooTheme.TEXT_SECONDARY);
        statusLabel.setBorder(BorderFactory.createEmptyBorder(0, 0, 10, 0));
        
        // Progress bar with modern styling
        progressBar = new JProgressBar(0, 100) {
            @Override
            protected void paintComponent(Graphics g) {
                Graphics2D g2d = (Graphics2D) g.create();
                g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
                
                // Background
                g2d.setColor(PackarooTheme.BACKGROUND_LIGHT);
                g2d.fillRoundRect(0, 0, getWidth(), getHeight(), 12, 12);
                
                // Progress fill
                if (getValue() > 0) {
                    int progressWidth = (int) ((double) getValue() / getMaximum() * getWidth());
                    LinearGradientPaint progressGradient = new LinearGradientPaint(
                        0, 0, progressWidth, 0,
                        new float[]{0f, 1f},
                        new Color[]{PackarooTheme.PRIMARY_BLUE, PackarooTheme.PRIMARY_BLUE_LIGHT}
                    );
                    g2d.setPaint(progressGradient);
                    g2d.fillRoundRect(0, 0, progressWidth, getHeight(), 12, 12);
                }
                
                g2d.dispose();
            }
        };
        progressBar.setValue(0);
        progressBar.setStringPainted(false);
        progressBar.setBorderPainted(false);
        progressBar.setOpaque(false);
        progressBar.setPreferredSize(new Dimension(400, 8));
        
        progressPanel.add(statusLabel, BorderLayout.NORTH);
        progressPanel.add(progressBar, BorderLayout.SOUTH);
        
        return progressPanel;
    }
    
    private void showWindow() {
        splashWindow.setVisible(true);
        splashWindow.toFront();
    }
    
    private void startProgressAnimation() {
        final String[] statusMessages = {
            "Loading...",
            "Initializing components...",
            "Loading services...", 
            "Preparing UI...",
            "Ready!"
        };
        
        progressTimer = new Timer(600, new ActionListener() {
            private int step = 0;
            
            @Override
            public void actionPerformed(ActionEvent e) {
                if (step < statusMessages.length) {
                    int progress = (step + 1) * 20;
                    progressBar.setValue(progress);
                    statusLabel.setText(statusMessages[step]);
                    step++;
                } else {
                    progressTimer.stop();
                }
            }
        });
        
        progressTimer.start();
    }
}
