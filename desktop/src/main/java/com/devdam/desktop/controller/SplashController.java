package com.devdam.desktop.controller;

// import javafx.animation.FadeTransition;
import javafx.animation.KeyFrame;
// import javafx.animation.KeyValue;
// import javafx.animation.RotateTransition;
import javafx.animation.ScaleTransition;
import javafx.animation.Timeline;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.paint.Color;
import javafx.scene.paint.CycleMethod;
import javafx.scene.paint.LinearGradient;
import javafx.scene.paint.Stop;
import javafx.scene.shape.Rectangle;
import javafx.util.Duration;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.net.URL;
import java.util.ResourceBundle;

@Slf4j
@Component
public class SplashController implements Initializable {

    @FXML private ImageView logoImageView;
    @FXML private Label titleLabel;
    @FXML private Label versionLabel;
    @FXML private ProgressBar loadingProgressBar;
    @FXML private Label statusLabel;

    // Application properties
    @Value("${application.title}")
    private String applicationTitle;
    
    @Value("${application.version}")
    private String applicationVersion;

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        log.info("Initializing splash screen");
        
        // Set dynamic values from application properties - just use "Packaroo" for title
        titleLabel.setText("Packaroo");
        versionLabel.setText("v" + applicationVersion);
        statusLabel.setText("Loading...");
        
        // Ensure all elements are initially visible
        logoImageView.setOpacity(1.0);
        titleLabel.setOpacity(1.0);
        versionLabel.setOpacity(1.0);
        statusLabel.setOpacity(1.0);
        loadingProgressBar.setOpacity(1.0);
        
        // Try to load icon, create a placeholder if not available
        setupLogo();
        
        // Start animations with a slight delay to ensure everything is rendered
        javafx.application.Platform.runLater(() -> {
            startAnimations();
            simulateLoading();
        });
    }

    private void setupLogo() {
        try {
            var iconStream = getClass().getResourceAsStream("/images/icon-512.png");
            if (iconStream != null) {
                logoImageView.setImage(new Image(iconStream));
                log.info("Application icon loaded successfully");
            } else {
                // Create a simple placeholder rectangle
                Rectangle placeholder = new Rectangle(120, 120);
                placeholder.setFill(Color.LIGHTBLUE);
                placeholder.setStroke(Color.DARKBLUE);
                placeholder.setStrokeWidth(2);
                placeholder.setArcWidth(10);
                placeholder.setArcHeight(10);
                // Note: We can't easily replace ImageView with Rectangle in FXML
                // So we'll just leave the ImageView empty for now
                log.info("Application icon not found, using default styling");
            }
        } catch (Exception e) {
            log.warn("Could not load application icon", e);
        }
    }

    private void startAnimations() {
        log.info("Starting splash animations");
        
        try {
            // Start elements with full opacity (remove fade-in for now)
            logoImageView.setOpacity(1.0);
            titleLabel.setOpacity(1.0);
            versionLabel.setOpacity(1.0);
            statusLabel.setOpacity(1.0);
            loadingProgressBar.setOpacity(1.0);
            
            // Simple pulse animation for the logo
            ScaleTransition logoScale = new ScaleTransition(Duration.seconds(1.5), logoImageView);
            logoScale.setFromX(0.8);
            logoScale.setFromY(0.8);
            logoScale.setToX(1.0);
            logoScale.setToY(1.0);
            logoScale.setCycleCount(Timeline.INDEFINITE);
            logoScale.setAutoReverse(true);
            logoScale.play();
            
            // Start gradient animations for title and version
            startGradientAnimations();
            
            log.info("Splash animations started successfully");
        } catch (Exception e) {
            log.error("Error starting animations", e);
        }
    }

    private void startGradientAnimations() {
        // Create animated gradient effects for the splash labels
        Timeline titleAnimation = new Timeline();
        Timeline versionAnimation = new Timeline();
        
        // Create gradient colors for animation - darker colors for light background
        Color[] gradientColors = {
            Color.web("#1A6DFF"), // Dark blue
            Color.web("#0052CC"), // Darker blue
            Color.web("#C822FF"), // Purple  
            Color.web("#9A1ACC"), // Darker purple
            Color.web("#FF6B6B")  // Red accent
        };
        
        // Title animation - cycles through gradient positions
        for (int i = 0; i <= 100; i += 10) {
            final int step = i;
            KeyFrame keyFrame = new KeyFrame(Duration.millis(i * 40), e -> {
                // Calculate gradient colors based on animation position
                Color color1 = gradientColors[(step / 20) % gradientColors.length];
                Color color2 = gradientColors[((step / 20) + 1) % gradientColors.length];
                Color color3 = gradientColors[((step / 20) + 2) % gradientColors.length];
                
                LinearGradient gradient = new LinearGradient(
                    0, 0, 1, 0, true, CycleMethod.NO_CYCLE,
                    new Stop(0, color1),
                    new Stop(0.5, color2), 
                    new Stop(1.0, color3)
                );
                
                titleLabel.setTextFill(gradient);
            });
            titleAnimation.getKeyFrames().add(keyFrame);
        }
        
        // Version animation - slightly different timing and colors
        for (int i = 0; i <= 100; i += 10) {
            final int step = i;
            KeyFrame keyFrame = new KeyFrame(Duration.millis(i * 50), e -> {
                // Offset the color selection for version label
                Color color1 = gradientColors[((step / 25) + 2) % gradientColors.length];
                Color color2 = gradientColors[((step / 25) + 3) % gradientColors.length];
                
                LinearGradient gradient = new LinearGradient(
                    0, 0, 1, 0, true, CycleMethod.NO_CYCLE,
                    new Stop(0, color1),
                    new Stop(1.0, color2)
                );
                
                versionLabel.setTextFill(gradient);
            });
            versionAnimation.getKeyFrames().add(keyFrame);
        }
        
        // Set animations to repeat indefinitely
        titleAnimation.setCycleCount(Timeline.INDEFINITE);
        versionAnimation.setCycleCount(Timeline.INDEFINITE);
        
        // Start animations
        titleAnimation.play();
        versionAnimation.play();
    }

    private void simulateLoading() {
        Timeline timeline = new Timeline();
        
        // Simulate loading progress
        javafx.animation.KeyFrame keyFrame1 = new javafx.animation.KeyFrame(
            Duration.seconds(0.5), 
            e -> {
                loadingProgressBar.setProgress(0.2);
                statusLabel.setText("Initializing components...");
            }
        );
        
        javafx.animation.KeyFrame keyFrame2 = new javafx.animation.KeyFrame(
            Duration.seconds(1.0), 
            e -> {
                loadingProgressBar.setProgress(0.5);
                statusLabel.setText("Loading services...");
            }
        );
        
        javafx.animation.KeyFrame keyFrame3 = new javafx.animation.KeyFrame(
            Duration.seconds(1.5), 
            e -> {
                loadingProgressBar.setProgress(0.8);
                statusLabel.setText("Preparing UI...");
            }
        );
        
        javafx.animation.KeyFrame keyFrame4 = new javafx.animation.KeyFrame(
            Duration.seconds(2.0), 
            e -> {
                loadingProgressBar.setProgress(1.0);
                statusLabel.setText("Ready!");
            }
        );
        
        timeline.getKeyFrames().addAll(keyFrame1, keyFrame2, keyFrame3, keyFrame4);
        timeline.play();
    }
}
