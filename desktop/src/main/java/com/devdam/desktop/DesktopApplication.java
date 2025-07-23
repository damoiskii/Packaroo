package com.devdam.desktop;

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
        showSplashScreen();
        
        // Load main application after splash
        Platform.runLater(() -> {
            try {
                showMainApplication(primaryStage);
            } catch (Exception e) {
                log.error("Error loading main application", e);
                Platform.exit();
            }
        });
    }

    private void showSplashScreen() {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource("/fxml/splash.fxml"));
            loader.setControllerFactory(context::getBean);
            Parent splashRoot = loader.load();
            
            Stage splashStage = new Stage();
            splashStage.setTitle("Packaroo");
            splashStage.setScene(new Scene(splashRoot));
            
            // Try to load icon, but don't fail if it's missing
            try {
                var iconStream = getClass().getResourceAsStream("/images/packaroo-icon.png");
                if (iconStream != null) {
                    splashStage.getIcons().add(new Image(iconStream));
                }
            } catch (Exception e) {
                log.warn("Could not load application icon", e);
            }
            
            splashStage.setResizable(false);
            splashStage.centerOnScreen();
            splashStage.show();
            
            // Auto close splash after 3 seconds
            Platform.runLater(() -> {
                try {
                    Thread.sleep(3000);
                    splashStage.close();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });
            
        } catch (Exception e) {
            log.warn("Could not load splash screen, proceeding to main application", e);
        }
    }

    private void showMainApplication(Stage primaryStage) throws Exception {
        FXMLLoader loader = new FXMLLoader(getClass().getResource("/fxml/main.fxml"));
        loader.setControllerFactory(context::getBean);
        Parent root = loader.load();

        Scene scene = new Scene(root, 1200, 800);
        scene.getStylesheets().add(getClass().getResource("/css/styles.css").toExternalForm());

        primaryStage.setTitle("Packaroo - Java Application Packager");
        primaryStage.setScene(scene);
        
        // Try to load icon, but don't fail if it's missing
        try {
            var iconStream = getClass().getResourceAsStream("/images/packaroo-icon.png");
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
