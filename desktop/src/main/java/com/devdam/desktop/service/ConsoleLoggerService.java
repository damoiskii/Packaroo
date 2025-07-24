package com.devdam.desktop.service;

import com.devdam.desktop.model.LogLevel;
import javafx.application.Platform;
import javafx.scene.control.TextArea;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class ConsoleLoggerService {
    
    private TextArea consoleArea;
    private final List<String> logHistory = new ArrayList<>();
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm:ss");
    private static final DateTimeFormatter FULL_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    public void setConsoleArea(TextArea consoleArea) {
        this.consoleArea = consoleArea;
    }
    
    public void log(LogLevel level, String message) {
        log(level, null, message);
    }
    
    public void log(LogLevel level, String category, String message) {
        if (consoleArea == null) return;
        
        LocalDateTime now = LocalDateTime.now();
        String timestamp = now.format(TIME_FORMATTER);
        String fullTimestamp = now.format(FULL_FORMATTER);
        
        // Build formatted message
        StringBuilder formattedMessage = new StringBuilder();
        formattedMessage.append("[").append(timestamp).append("] ");
        formattedMessage.append(level.getIcon()).append(" ");
        formattedMessage.append(String.format("%-8s", level.getName()));
        
        if (category != null && !category.trim().isEmpty()) {
            formattedMessage.append(" [").append(category.toUpperCase()).append("] ");
        } else {
            formattedMessage.append(" ");
        }
        
        formattedMessage.append(message);
        
        String logEntry = formattedMessage.toString();
        String historyEntry = "[" + fullTimestamp + "] " + level.getName() + 
                             (category != null ? " [" + category + "]" : "") + " " + message;
        
        Platform.runLater(() -> {
            consoleArea.appendText(logEntry + "\n");
            consoleArea.setScrollTop(Double.MAX_VALUE);
        });
        
        // Store in history for export
        synchronized (logHistory) {
            logHistory.add(historyEntry);
        }
    }
    
    // Convenience methods for different log levels
    public void info(String message) {
        log(LogLevel.INFO, null, message);
    }
    
    public void info(String category, String message) {
        log(LogLevel.INFO, category, message);
    }
    
    public void success(String message) {
        log(LogLevel.SUCCESS, null, message);
    }
    
    public void success(String category, String message) {
        log(LogLevel.SUCCESS, category, message);
    }
    
    public void warning(String message) {
        log(LogLevel.WARNING, null, message);
    }
    
    public void warning(String category, String message) {
        log(LogLevel.WARNING, category, message);
    }
    
    public void error(String message) {
        log(LogLevel.ERROR, null, message);
    }
    
    public void error(String category, String message) {
        log(LogLevel.ERROR, category, message);
    }
    
    public void debug(String message) {
        log(LogLevel.DEBUG, null, message);
    }
    
    public void debug(String category, String message) {
        log(LogLevel.DEBUG, category, message);
    }
    
    public void progress(String message) {
        log(LogLevel.PROGRESS, null, message);
    }
    
    public void progress(String category, String message) {
        log(LogLevel.PROGRESS, category, message);
    }
    
    // Structured logging for operations
    public void startOperation(String operation) {
        log(LogLevel.INFO, "OPERATION", "Starting: " + operation);
    }
    
    public void completeOperation(String operation, long duration) {
        log(LogLevel.SUCCESS, "OPERATION", "Completed: " + operation + " (took " + duration + "ms)");
    }
    
    public void failOperation(String operation, String reason) {
        log(LogLevel.ERROR, "OPERATION", "Failed: " + operation + " - " + reason);
    }
    
    public void clear() {
        if (consoleArea != null) {
            Platform.runLater(() -> consoleArea.clear());
        }
        synchronized (logHistory) {
            logHistory.clear();
        }
    }
    
    public List<String> getLogHistory() {
        synchronized (logHistory) {
            return new ArrayList<>(logHistory);
        }
    }
    
    // Separator for visual organization
    public void separator() {
        if (consoleArea != null) {
            Platform.runLater(() -> {
                consoleArea.appendText("─".repeat(80) + "\n");
                consoleArea.setScrollTop(Double.MAX_VALUE);
            });
        }
    }
    
    public void section(String title) {
        if (consoleArea != null) {
            Platform.runLater(() -> {
                String separator = "─".repeat(80);
                consoleArea.appendText("\n" + separator + "\n");
                consoleArea.appendText("  " + title.toUpperCase() + "\n");
                consoleArea.appendText(separator + "\n");
                consoleArea.setScrollTop(Double.MAX_VALUE);
            });
        }
    }
}
