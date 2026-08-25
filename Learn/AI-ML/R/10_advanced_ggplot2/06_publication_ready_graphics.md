## Publication-Ready Graphics


### High-Resolution Output

```r
# Save high-quality plots
ggsave("publication_plot.png", plot = p, 
       width = 8, height = 6, dpi = 300, 
       bg = "white")

# Multiple formats
ggsave("publication_plot.pdf", plot = p, 
       width = 8, height = 6, device = "pdf")

# Specific dimensions for journals
ggsave("nature_figure.eps", plot = p,
       width = 183, height = 120, units = "mm", 
       dpi = 300, device = "eps")
```

### Professional Styling Standards

```r
# Publication theme
publication_theme <- theme_classic() +
  theme(
    # Text sizing for readability
    text = element_text(size = 12, family = "Arial"),
    plot.title = element_text(size = 14, face = "bold"),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10, color = "black"),
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 12, face = "bold"),
    
    # Clean appearance
    panel.border = element_rect(color = "black", fill = NA, size = 0.5),
    axis.line = element_blank(),
    axis.ticks = element_line(color = "black", size = 0.3),
    
    # Legend positioning
    legend.position = "bottom",
    legend.key.size = unit(0.4, "cm"),
    
    # Margins for publication
    plot.margin = margin(0.5, 0.5, 0.5, 0.5, "cm")
  )

# Color schemes suitable for print and colorblind accessibility
colorblind_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", 
                       "#0072B2", "#D55E00", "#CC79A7", "#999999")

# Apply publication standards
publication_plot <- ggplot(mpg, aes(displ, hwy, color = class)) +
  geom_point(size = 2, alpha = 0.8) +
  scale_color_manual(values = colorblind_palette) +
  labs(
    title = "Highway Fuel Efficiency by Engine Displacement",
    x = "Engine Displacement (L)",
    y = "Highway Fuel Economy (MPG)",
    color = "Vehicle Class",
    caption = "Data: EPA fuel economy dataset (n = 234 vehicles)"
  ) +
  publication_theme
```

### Figure Panels and Complex Layouts

```r
# Multi-panel figures with shared legends
library(patchwork)

p1 <- ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  labs(title = "A", x = "Engine Displacement (L)", y = "Highway MPG") +
  publication_theme

p2 <- ggplot(mpg, aes(class, hwy)) + 
  geom_boxplot() + 
  labs(title = "B", x = "Vehicle Class", y = "Highway MPG") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  publication_theme

p3 <- ggplot(mpg, aes(hwy, fill = class)) + 
  geom_histogram(bins = 20, alpha = 0.7) +
  scale_fill_manual(values = colorblind_palette) +
  labs(title = "C", x = "Highway MPG", y = "Frequency", fill = "Class") +
  publication_theme

# Combine with proper labeling
figure_combined <- (p1 + p2) / p3 + 
  plot_layout(guides = "collect", heights = c(1, 1)) +
  plot_annotation(
    title = "Automotive Fuel Efficiency Analysis",
    caption = "Figure 1. Comprehensive analysis of highway fuel efficiency across vehicle characteristics.",
    theme = theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5))
  ) & 
  theme(legend.position = "bottom")
```

