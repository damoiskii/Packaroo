package com.devdam.desktop.service;

import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Stage;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
public class ViewManager {
    
    private final ApplicationContext applicationContext;
    private Stage primaryStage;
    
    public ViewManager(ApplicationContext applicationContext) {
        this.applicationContext = applicationContext;
    }
    
    public void setPrimaryStage(Stage primaryStage) {
        this.primaryStage = primaryStage;
    }
    
    public void showView(String fxmlPath, String title) {
        try {
            FXMLLoader loader = new FXMLLoader(getClass().getResource(fxmlPath));
            loader.setControllerFactory(applicationContext::getBean);
            
            Scene scene = new Scene(loader.load());
            scene.getStylesheets().add(getClass().getResource("/css/styles.css").toExternalForm());
            
            primaryStage.setScene(scene);
            primaryStage.setTitle(title);
            primaryStage.show();
            
        } catch (IOException e) {
            throw new RuntimeException("Failed to load view: " + fxmlPath, e);
        }
    }
    
    public void showMainView() {
        showView("/fxml/main.fxml", "Packaroo - Desktop Package Manager");
    }
    
    public void showSetupGuide() {
        showView("/fxml/setup-guide.fxml", "Packaroo - Setup Guide");
    }
}
