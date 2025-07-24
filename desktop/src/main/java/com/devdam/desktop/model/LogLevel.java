package com.devdam.desktop.model;

public enum LogLevel {
    INFO("INFO", "ℹ️", "#2196F3"),
    SUCCESS("SUCCESS", "✅", "#4CAF50"),
    WARNING("WARNING", "⚠️", "#FF9800"),
    ERROR("ERROR", "❌", "#F44336"),
    DEBUG("DEBUG", "🔍", "#9C27B0"),
    PROGRESS("PROGRESS", "⏳", "#607D8B");
    
    private final String name;
    private final String icon;
    private final String color;
    
    LogLevel(String name, String icon, String color) {
        this.name = name;
        this.icon = icon;
        this.color = color;
    }
    
    public String getName() { return name; }
    public String getIcon() { return icon; }
    public String getColor() { return color; }
    
    @Override
    public String toString() { return name; }
}
