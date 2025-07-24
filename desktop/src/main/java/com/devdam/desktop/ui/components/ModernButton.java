package com.devdam.desktop.ui.components;

import com.devdam.desktop.ui.theme.PackarooTheme;

import javax.swing.*;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.geom.RoundRectangle2D;

/**
 * Modern styled button with gradient background and hover effects
 */
public class ModernButton extends JButton {
    
    private boolean isHovered = false;
    private boolean isPrimary = false;
    private Color baseColor = PackarooTheme.PRIMARY_BLUE;
    private Color hoverColor = PackarooTheme.PRIMARY_BLUE_DARK;
    
    public ModernButton(String text) {
        super(text);
        initializeButton();
    }
    
    public ModernButton(String text, boolean isPrimary) {
        super(text);
        this.isPrimary = isPrimary;
        initializeButton();
    }
    
    private void initializeButton() {
        setFocusPainted(false);
        setBorderPainted(false);
        setContentAreaFilled(false);
        setOpaque(false);
        
        // Set font
        setFont(new Font(Font.SANS_SERIF, Font.BOLD, 12));
        
        // Set colors based on button type
        if (isPrimary) {
            setForeground(Color.WHITE);
            baseColor = PackarooTheme.PRIMARY_BLUE;
            hoverColor = PackarooTheme.PRIMARY_BLUE_DARK;
        } else {
            setForeground(PackarooTheme.TEXT_PRIMARY);
            baseColor = PackarooTheme.BACKGROUND_CARD;
            hoverColor = PackarooTheme.HOVER_LIGHT;
        }
        
        // Add mouse listeners for hover effects
        addMouseListener(new MouseAdapter() {
            @Override
            public void mouseEntered(MouseEvent e) {
                isHovered = true;
                repaint();
            }
            
            @Override
            public void mouseExited(MouseEvent e) {
                isHovered = false;
                repaint();
            }
        });
        
        // Set preferred size
        setPreferredSize(new Dimension(120, 36));
    }
    
    @Override
    protected void paintComponent(Graphics g) {
        Graphics2D g2d = (Graphics2D) g.create();
        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        
        int width = getWidth();
        int height = getHeight();
        
        // Create rounded rectangle
        RoundRectangle2D.Float roundRect = new RoundRectangle2D.Float(0, 0, width - 1, height - 1, 8, 8);
        
        // Paint background
        if (isPrimary) {
            // Gradient background for primary buttons
            Color startColor = isHovered ? hoverColor : baseColor;
            Color endColor = isHovered ? PackarooTheme.ACCENT_PURPLE : PackarooTheme.PRIMARY_BLUE_LIGHT;
            
            LinearGradientPaint gradient = new LinearGradientPaint(
                0, 0, 0, height,
                new float[]{0f, 1f},
                new Color[]{startColor, endColor}
            );
            g2d.setPaint(gradient);
        } else {
            // Solid background for secondary buttons
            g2d.setColor(isHovered ? hoverColor : baseColor);
        }
        
        g2d.fill(roundRect);
        
        // Paint border
        if (!isPrimary) {
            g2d.setColor(PackarooTheme.BORDER_LIGHT);
            g2d.draw(roundRect);
        }
        
        g2d.dispose();
        
        // Paint text
        super.paintComponent(g);
    }
    
    public void setPrimary(boolean primary) {
        this.isPrimary = primary;
        if (isPrimary) {
            setForeground(Color.WHITE);
            baseColor = PackarooTheme.PRIMARY_BLUE;
            hoverColor = PackarooTheme.PRIMARY_BLUE_DARK;
        } else {
            setForeground(PackarooTheme.TEXT_PRIMARY);
            baseColor = PackarooTheme.BACKGROUND_CARD;
            hoverColor = PackarooTheme.HOVER_LIGHT;
        }
        repaint();
    }
}
