package com.devdam.desktop;

import com.devdam.desktop.service.ConfigurationService;
import com.devdam.desktop.service.DependencyAnalysisService;
import com.devdam.desktop.service.PackagingService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

import static org.junit.jupiter.api.Assertions.assertNotNull;

@SpringBootTest
@TestPropertySource(properties = {
    "spring.main.web-application-type=none",
    "java.awt.headless=true"
})
class PackarooApplicationTests {

    @Autowired
    private DependencyAnalysisService dependencyAnalysisService;

    @Autowired
    private PackagingService packagingService;

    @Autowired
    private ConfigurationService configurationService;

    @Test
    void contextLoads() {
        assertNotNull(dependencyAnalysisService);
        assertNotNull(packagingService);
        assertNotNull(configurationService);
    }

    @Test
    void dependencyAnalysisServiceLoads() {
        assertNotNull(dependencyAnalysisService);
        // Test basic functionality
        var suggestedModules = dependencyAnalysisService.getSuggestedModules();
        assertNotNull(suggestedModules);
        org.junit.jupiter.api.Assertions.assertFalse(suggestedModules.isEmpty());
    }

    @Test
    void packagingServiceLoads() {
        assertNotNull(packagingService);
        // We can't easily test jpackage/jlink without actual tools, 
        // but we can test that the service is properly initialized
    }

    @Test
    void configurationServiceLoads() {
        assertNotNull(configurationService);
        // Test default configuration
        var defaultConfig = configurationService.getDefaultConfiguration();
        assertNotNull(defaultConfig);
        assertNotNull(defaultConfig.getAppName());
    }
}
