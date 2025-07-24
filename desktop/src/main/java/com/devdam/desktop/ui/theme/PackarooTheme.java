package com.devdam.desktop.ui.theme;

import java.awt.*;

/**
 * Modern color theme for Packaroo application
 * Based on the logo colors and modern UI design principles
 */
public class PackarooTheme {
    
    // Primary brand colors (from logo)
    public static final Color PRIMARY_BLUE = new Color(26, 109, 255);
    public static final Color PRIMARY_BLUE_DARK = new Color(20, 85, 200);
    public static final Color PRIMARY_BLUE_LIGHT = new Color(64, 149, 255);
    public static final Color ACCENT_PURPLE = new Color(123, 31, 162);
    public static final Color ACCENT_TEAL = new Color(0, 172, 193);
    
    // Neutral colors
    public static final Color BACKGROUND_LIGHT = new Color(248, 250, 252);
    public static final Color BACKGROUND_CARD = new Color(255, 255, 255);
    public static final Color BACKGROUND_DARK = new Color(30, 32, 37);
    public static final Color BACKGROUND_CARD_DARK = new Color(42, 45, 51);
    
    // Text colors
    public static final Color TEXT_PRIMARY = new Color(33, 37, 41);
    public static final Color TEXT_SECONDARY = new Color(108, 117, 125);
    public static final Color TEXT_MUTED = new Color(134, 142, 150);
    public static final Color TEXT_PRIMARY_DARK = new Color(233, 236, 239);
    public static final Color TEXT_SECONDARY_DARK = new Color(173, 181, 189);
    
    // Status colors
    public static final Color SUCCESS = new Color(40, 167, 69);
    public static final Color WARNING = new Color(255, 193, 7);
    public static final Color ERROR = new Color(220, 53, 69);
    public static final Color INFO = PRIMARY_BLUE;
    
    // UI element colors
    public static final Color BORDER_LIGHT = new Color(222, 226, 230);
    public static final Color BORDER_DARK = new Color(73, 80, 87);
    public static final Color HOVER_LIGHT = new Color(233, 236, 239);
    public static final Color HOVER_DARK = new Color(52, 58, 64);
    
    // Gradients
    public static final Color GRADIENT_START = PRIMARY_BLUE;
    public static final Color GRADIENT_END = ACCENT_PURPLE;
    
    /**
     * Creates a subtle gradient paint for modern UI elements
     */
    public static LinearGradientPaint createGradient(int width, int height) {
        return new LinearGradientPaint(
            0, 0, width, height,
            new float[]{0f, 1f},
            new Color[]{GRADIENT_START, GRADIENT_END}
        );
    }
    
    /**
     * Creates a button gradient
     */
    public static LinearGradientPaint createButtonGradient(int width, int height) {
        return new LinearGradientPaint(
            0, 0, 0, height,
            new float[]{0f, 1f},
            new Color[]{PRIMARY_BLUE_LIGHT, PRIMARY_BLUE}
        );
    }
    
    /**
     * Get appropriate text color for given background
     */
    public static Color getTextColor(Color background) {
        // Calculate luminance
        double luminance = (0.299 * background.getRed() + 
                           0.587 * background.getGreen() + 
                           0.114 * background.getBlue()) / 255;
        
        return luminance > 0.5 ? TEXT_PRIMARY : TEXT_PRIMARY_DARK;
    }
    
    /**
     * Creates a modern rounded border
     */
    public static javax.swing.border.Border createModernBorder() {
        return javax.swing.BorderFactory.createCompoundBorder(
            javax.swing.BorderFactory.createLineBorder(BORDER_LIGHT, 1, true),
            javax.swing.BorderFactory.createEmptyBorder(8, 12, 8, 12)
        );
    }
    
    /**
     * Creates a card-like border with shadow effect
     */
    public static javax.swing.border.Border createCardBorder() {
        return javax.swing.BorderFactory.createCompoundBorder(
            new ShadowBorder(),
            javax.swing.BorderFactory.createEmptyBorder(16, 16, 16, 16)
        );
    }
    
    /**
     * Custom shadow border for card effect
     */
    public static class ShadowBorder implements javax.swing.border.Border {
        private final Color shadowColor = new Color(0, 0, 0, 30);
        private final int shadowSize = 3;
        
        @Override
        public void paintBorder(Component c, Graphics g, int x, int y, int width, int height) {
            Graphics2D g2d = (Graphics2D) g.create();
            g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            
            // Draw shadow
            g2d.setColor(shadowColor);
            for (int i = 0; i < shadowSize; i++) {
                g2d.drawRoundRect(x + i, y + i, width - 2 * i - 1, height - 2 * i - 1, 8, 8);
            }
            
            // Draw main border
            g2d.setColor(BORDER_LIGHT);
            g2d.drawRoundRect(x, y, width - 1, height - 1, 8, 8);
            
            g2d.dispose();
        }
        
        @Override
        public Insets getBorderInsets(Component c) {
            return new Insets(shadowSize, shadowSize, shadowSize, shadowSize);
        }
        
        @Override
        public boolean isBorderOpaque() {
            return false;
        }
    }
}
