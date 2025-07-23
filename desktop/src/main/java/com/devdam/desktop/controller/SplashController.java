package com.devdam.desktop.controller;

import javafx.animation.FadeTransition;
import javafx.animation.KeyFrame;
import javafx.animation.KeyValue;
import javafx.animation.RotateTransition;
import javafx.animation.ScaleTransition;
import javafx.animation.Timeline;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.util.Duration;
import lombok.extern.slf4j.Slf4j;
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

    @Override
    public void initialize(URL location, ResourceBundle resources) {
        log.info("Initializing splash screen");
        
        // Set initial values
        titleLabel.setText("Packaroo");
        versionLabel.setText("v1.0.0");
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
            
            log.info("Splash animations started successfully");
        } catch (Exception e) {
            log.error("Error starting animations", e);
        }
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
