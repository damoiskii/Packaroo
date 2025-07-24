package com.devdam.desktop.service;

import com.devdam.desktop.model.PackageConfiguration;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
public class ConfigurationService {
    
    private final ObjectMapper objectMapper;
    private final Path configDirectory;
    
    public ConfigurationService() {
        this.objectMapper = new ObjectMapper();
        this.objectMapper.registerModule(new JavaTimeModule());
        this.configDirectory = Paths.get(System.getProperty("user.home"), ".packaroo", "presets");
        
        try {
            Files.createDirectories(configDirectory);
        } catch (IOException e) {
            log.warn("Could not create configuration directory", e);
        }
    }
    
    public void savePreset(String name, PackageConfiguration config) throws IOException {
        Path presetFile = configDirectory.resolve(name + ".json");
        objectMapper.writeValue(presetFile.toFile(), config);
        log.info("Saved preset: {}", name);
    }
    
    public PackageConfiguration loadPreset(String name) throws IOException {
        Path presetFile = configDirectory.resolve(name + ".json");
        if (!Files.exists(presetFile)) {
            throw new IOException("Preset not found: " + name);
        }
        
        PackageConfiguration config = objectMapper.readValue(presetFile.toFile(), PackageConfiguration.class);
        log.info("Loaded preset: {}", name);
        return config;
    }
    
    public List<String> getAvailablePresets() {
        List<String> presets = new ArrayList<>();
        
        try {
            if (Files.exists(configDirectory)) {
                Files.list(configDirectory)
                        .filter(path -> path.toString().endsWith(".json"))
                        .forEach(path -> {
                            String filename = path.getFileName().toString();
                            String presetName = filename.substring(0, filename.lastIndexOf('.'));
                            presets.add(presetName);
                        });
            }
        } catch (IOException e) {
            log.warn("Could not list presets", e);
        }
        
        return presets;
    }
    
    public void deletePreset(String name) throws IOException {
        Path presetFile = configDirectory.resolve(name + ".json");
        if (Files.exists(presetFile)) {
            Files.delete(presetFile);
            log.info("Deleted preset: {}", name);
        }
    }
    
    public PackageConfiguration getDefaultConfiguration() {
        return PackageConfiguration.builder()
                .targetPlatform(PackageConfiguration.TargetPlatform.CURRENT)
                .outputFormat(PackageConfiguration.OutputFormat.APP_IMAGE)
                .enableJLink(false)
                .build();
    }

    public void saveConfigurationToFile(PackageConfiguration config, String filePath) throws IOException {
        objectMapper.writeValue(new java.io.File(filePath), config);
        log.info("Saved configuration to file: {}", filePath);
    }

    public PackageConfiguration loadConfigurationFromFile(String filePath) throws IOException {
        java.io.File file = new java.io.File(filePath);
        if (!file.exists()) {
            throw new IOException("Configuration file not found: " + filePath);
        }
        
        PackageConfiguration config = objectMapper.readValue(file, PackageConfiguration.class);
        log.info("Loaded configuration from file: {}", filePath);
        return config;
    }
}
