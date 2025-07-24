package com.devdam.desktop.ui.components;

import com.devdam.desktop.ui.theme.PackarooTheme;

import javax.swing.*;
import javax.swing.border.TitledBorder;
import java.awt.*;

/**
 * Modern styled panel with card-like appearance
 */
public class ModernPanel extends JPanel {
    
    private String title;
    private boolean isDark = false;
    
    public ModernPanel() {
        initializePanel();
    }
    
    public ModernPanel(String title) {
        this.title = title;
        initializePanel();
    }
    
    public ModernPanel(LayoutManager layout) {
        super(layout);
        initializePanel();
    }
    
    public ModernPanel(String title, LayoutManager layout) {
        super(layout);
        this.title = title;
        initializePanel();
    }
    
    private void initializePanel() {
        setOpaque(true);
        setBackground(PackarooTheme.BACKGROUND_CARD);
        
        if (title != null && !title.isEmpty()) {
            setBorder(createModernTitledBorder(title));
        } else {
            setBorder(BorderFactory.createEmptyBorder(16, 16, 16, 16));
        }
    }
    
    private javax.swing.border.Border createModernTitledBorder(String title) {
        TitledBorder titledBorder = BorderFactory.createTitledBorder(
            BorderFactory.createLineBorder(PackarooTheme.BORDER_LIGHT, 1, true),
            title
        );
        
        // Style the title
        titledBorder.setTitleFont(new Font(Font.SANS_SERIF, Font.BOLD, 14));
        titledBorder.setTitleColor(PackarooTheme.PRIMARY_BLUE);
        titledBorder.setTitlePosition(TitledBorder.TOP);
        titledBorder.setTitleJustification(TitledBorder.LEADING);
        
        return BorderFactory.createCompoundBorder(
            titledBorder,
            BorderFactory.createEmptyBorder(12, 16, 16, 16)
        );
    }
    
    @Override
    protected void paintComponent(Graphics g) {
        Graphics2D g2d = (Graphics2D) g.create();
        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        
        int width = getWidth();
        int height = getHeight();
        
        // Paint background with rounded corners
        g2d.setColor(getBackground());
        g2d.fillRoundRect(0, 0, width, height, 12, 12);
        
        // Add subtle shadow effect
        g2d.setColor(new Color(0, 0, 0, 10));
        g2d.drawRoundRect(1, 1, width - 2, height - 2, 12, 12);
        
        g2d.dispose();
    }
    
    public void setDarkMode(boolean dark) {
        this.isDark = dark;
        if (dark) {
            setBackground(PackarooTheme.BACKGROUND_CARD_DARK);
        } else {
            setBackground(PackarooTheme.BACKGROUND_CARD);
        }
        repaint();
    }
}
