package com.devdam.desktop;

import com.devdam.desktop.ui.MainFrame;
import com.devdam.desktop.ui.SplashScreen;
import com.formdev.flatlaf.FlatLightLaf;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

import javax.swing.*;
import java.awt.*;

@Slf4j
@SpringBootApplication
public class DesktopApplication {

    private static ConfigurableApplicationContext context;

    public static void main(String[] args) {
        log.info("Starting Packaroo Desktop Application...");
        
        // Set system properties for better Swing experience
        System.setProperty("awt.useSystemAAFontSettings", "on");
        System.setProperty("swing.aatext", "true");
        System.setProperty("sun.java2d.uiScale", "1.0");
        
        // Set Look and Feel
        try {
            UIManager.setLookAndFeel(new FlatLightLaf());
            log.info("FlatLaf Look and Feel set successfully");
        } catch (Exception e) {
            log.warn("Failed to set FlatLaf Look and Feel", e);
        }

        // Ensure Swing operations run on EDT
        SwingUtilities.invokeLater(() -> {
            try {
                // Initialize Spring Boot context
                context = SpringApplication.run(DesktopApplication.class, args);
                
                // Show splash screen
                SplashScreen splash = context.getBean(SplashScreen.class);
                splash.showSplash();
                
                // Initialize main application after splash
                Timer timer = new Timer(3000, e -> {
                    splash.hideSplash();
                    showMainApplication();
                });
                timer.setRepeats(false);
                timer.start();
                
            } catch (Exception e) {
                log.error("Failed to start application", e);
                System.exit(1);
            }
        });
    }
    
    private static void showMainApplication() {
        try {
            MainFrame mainFrame = context.getBean(MainFrame.class);
            mainFrame.setVisible(true);
            log.info("Main application window displayed successfully");
        } catch (Exception e) {
            log.error("Failed to show main application", e);
            System.exit(1);
        }
    }
    
    public static ConfigurableApplicationContext getContext() {
        return context;
    }
}
