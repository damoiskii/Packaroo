package com.devdam.desktop;

import com.devdam.desktop.service.ViewManager;
import javafx.animation.Timeline;
import javafx.application.Application;
import javafx.application.Platform;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;

@Slf4j
@SpringBootApplication
public class DesktopApplication extends Application {

    private static ConfigurableApplicationContext context;
    private static String[] args;

    public static void main(String[] args) {
        DesktopApplication.args = args;
        System.setProperty("java.awt.headless", "false");
        System.setProperty("prism.lcdtext", "false");
        
        // Launch JavaFX application
        launch(args);
    }

    @Override
    public void init() throws Exception {
        // Initialize Spring Boot context
        context = SpringApplication.run(DesktopApplication.class, args);
        context.getAutowireCapableBeanFactory().autowireBean(this);
    }

    @Override
    public void start(Stage primaryStage) throws Exception {
        log.info("Starting Packaroo application...");
        
        // Show splash screen first
        Stage splashStage = showSplashScreen();
        
        // Load main application after splash with proper timing
        Timeline timeline = new Timeline();
        timeline.getKeyFrames().add(new javafx.animation.KeyFrame(
            javafx.util.Duration.seconds(4.0), // Give splash 4 seconds to display
            e -> {
                try {
                    splashStage.close();
                    showMainApplication(primaryStage);
                } catch (Exception ex) {
                    log.error("Error loading main application", ex);
                    Platform.exit();
                }
            }
        ));
        timeline.play();
    }

    private Stage showSplashScreen() {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/fxml/splash.fxml"));
            loader.setControllerFactory(context::getBean);
            Parent splashRoot = loader.load();
            
            Stage splashStage = new Stage();
            splashStage.setTitle("Packaroo");
            
            // Create scene with proper styling
            Scene splashScene = new Scene(splashRoot, 600, 400);
            splashScene.getStylesheets().add(getClass().getResource("/css/styles.css").toExternalForm());
            splashStage.setScene(splashScene);
            
            // Try to load icon, but don't fail if it's missing
            try {
                var iconStream = getClass().getResourceAsStream("/images/icon-512.png");
                if (iconStream != null) {
                    splashStage.getIcons().add(new Image(iconStream));
                }
            } catch (Exception e) {
                log.warn("Could not load application icon", e);
            }
            
            splashStage.setResizable(false);
            splashStage.centerOnScreen();
            splashStage.show();
            
            log.info("Splash screen displayed successfully");
            return splashStage;
            
        } catch (Exception e) {
            log.error("Could not load splash screen", e);
            throw new RuntimeException("Failed to show splash screen", e);
        }
    }

    private void showMainApplication(Stage primaryStage) throws Exception {
        // Initialize ViewManager with the primary stage
        ViewManager viewManager = context.getBean(ViewManager.class);
        viewManager.setPrimaryStage(primaryStage);
        
        FXMLLoader loader = new FXMLLoader(getClass().getResource("/fxml/main.fxml"));
        loader.setControllerFactory(context::getBean);
        Parent root = loader.load();

        Scene scene = new Scene(root, 1200, 800);
        scene.getStylesheets().add(getClass().getResource("/css/styles.css").toExternalForm());

        primaryStage.setTitle("Packaroo - Java Application Packager");
        primaryStage.setScene(scene);
        
        // Try to load icon, but don't fail if it's missing
        try {
            var iconStream = getClass().getResourceAsStream("/images/icon.png");
            if (iconStream != null) {
                primaryStage.getIcons().add(new Image(iconStream));
            }
        } catch (Exception e) {
            log.warn("Could not load application icon", e);
        }
        
        primaryStage.setMinWidth(800);
        primaryStage.setMinHeight(600);
        primaryStage.centerOnScreen();
        primaryStage.show();

        // Handle window close event
        primaryStage.setOnCloseRequest(event -> {
            Platform.exit();
            System.exit(0);
        });
    }

    @Override
    public void stop() throws Exception {
        if (context != null) {
            context.close();
        }
        Platform.exit();
    }
}
