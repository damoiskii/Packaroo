package com.devdam.desktop.controller;

import javafx.animation.FadeTransition;
import javafx.animation.RotateTransition;
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
        
        // Try to load icon, create a placeholder if not available
        setupLogo();
        
        // Start animations
        startAnimations();
        
        // Simulate loading progress
        simulateLoading();
    }

    private void setupLogo() {
        try {
            var iconStream = getClass().getResourceAsStream("/images/packaroo-icon.png");
            if (iconStream != null) {
                logoImageView.setImage(new Image(iconStream));
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
        // Fade in animation for the logo
        FadeTransition logoFade = new FadeTransition(Duration.seconds(1.5), logoImageView);
        logoFade.setFromValue(0.0);
        logoFade.setToValue(1.0);
        
        // Rotate animation for the logo
        RotateTransition logoRotate = new RotateTransition(Duration.seconds(2), logoImageView);
        logoRotate.setFromAngle(0);
        logoRotate.setToAngle(360);
        logoRotate.setCycleCount(1);
        
        // Fade in animation for title
        FadeTransition titleFade = new FadeTransition(Duration.seconds(1), titleLabel);
        titleFade.setFromValue(0.0);
        titleFade.setToValue(1.0);
        titleFade.setDelay(Duration.seconds(0.5));
        
        // Fade in animation for version
        FadeTransition versionFade = new FadeTransition(Duration.seconds(1), versionLabel);
        versionFade.setFromValue(0.0);
        versionFade.setToValue(1.0);
        versionFade.setDelay(Duration.seconds(1));
        
        // Start all animations
        logoFade.play();
        logoRotate.play();
        titleFade.play();
        versionFade.play();
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
