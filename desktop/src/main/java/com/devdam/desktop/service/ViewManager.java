package com.devdam.desktop.service;

import com.devdam.desktop.ui.SetupGuideDialog;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;

import javax.swing.*;

@Service
public class ViewManager {
    
    private final ApplicationContext applicationContext;
    private JFrame mainFrame;
    
    public ViewManager(ApplicationContext applicationContext) {
        this.applicationContext = applicationContext;
    }
    
    public void setMainFrame(JFrame mainFrame) {
        this.mainFrame = mainFrame;
    }
    
    public void showSetupGuide() {
        if (mainFrame != null) {
            SetupGuideDialog setupDialog = new SetupGuideDialog(mainFrame);
            setupDialog.showDialog();
        }
    }
}
