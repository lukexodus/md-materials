## Custom Themes and Styling


### Built-in Theme System

ggplot2 provides several complete themes that can be applied globally or to individual plots:

```r
library(ggplot2)

p <- ggplot(mpg, aes(displ, hwy)) + geom_point()

# Built-in themes
p + theme_minimal()     # Clean, minimal design
p + theme_classic()     # Clean axes, no gridlines
p + theme_dark()        # Dark background
p + theme_void()        # Completely blank
p + theme_bw()          # Black and white theme
```

### Creating Custom Themes

Custom themes allow complete control over plot appearance:

```r
# Define a custom theme
custom_theme <- theme(
  # Text elements
  plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
  plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray60"),
  axis.title = element_text(size = 12, face = "bold"),
  axis.text = element_text(size = 10),
  legend.title = element_text(size = 12, face = "bold"),
  legend.text = element_text(size = 10),
  
  # Panel and background
  panel.background = element_rect(fill = "white", color = NA),
  panel.grid.major = element_line(color = "gray90", size = 0.5),
  panel.grid.minor = element_line(color = "gray95", size = 0.25),
  panel.border = element_rect(color = "black", fill = NA, size = 1),
  
  # Legend positioning and styling
  legend.position = "bottom",
  legend.background = element_rect(fill = "gray95", color = "black"),
  legend.key = element_rect(fill = "white"),
  
  # Strip text for facets
  strip.background = element_rect(fill = "gray80", color = "black"),
  strip.text = element_text(size = 10, face = "bold")
)

# Apply custom theme
p + custom_theme
```

### Advanced Theme Modifications

Individual theme elements can be precisely controlled:

```r
# Advanced theme customization
advanced_theme <- theme_minimal() +
  theme(
    # Custom color scheme
    plot.background = element_rect(fill = "#f8f9fa"),
    panel.background = element_rect(fill = "white", color = "#dee2e6", size = 1),
    
    # Typography hierarchy
    plot.title = element_text(
      size = 18, 
      face = "bold", 
      color = "#2c3e50",
      margin = margin(b = 20)
    ),
    plot.subtitle = element_text(
      size = 14, 
      color = "#7f8c8d",
      margin = margin(b = 30)
    ),
    
    # Grid customization
    panel.grid.major.x = element_line(color = "#ecf0f1", size = 0.5),
    panel.grid.major.y = element_line(color = "#ecf0f1", size = 0.5),
    panel.grid.minor = element_blank(),
    
    # Axis styling
    axis.text = element_text(color = "#2c3e50", size = 11),
    axis.title = element_text(color = "#2c3e50", size = 12, face = "bold"),
    axis.ticks = element_line(color = "#bdc3c7"),
    
    # Legend refinements
    legend.position = "right",
    legend.title = element_text(size = 12, face = "bold", color = "#2c3e50"),
    legend.text = element_text(size = 10, color = "#2c3e50"),
    legend.background = element_rect(fill = "white", color = "#dee2e6"),
    legend.key = element_rect(fill = "white", color = NA),
    
    # Margins and spacing
    plot.margin = margin(20, 20, 20, 20)
  )
```

### Theme Inheritance and Modification

Themes can be built upon existing themes and saved for reuse:

```r
# Save theme as a function for reusability
corporate_theme <- function(base_size = 12, base_family = "Arial") {
  theme_bw(base_size = base_size, base_family = base_family) +
    theme(
      plot.title = element_text(size = base_size * 1.4, face = "bold"),
      plot.subtitle = element_text(size = base_size * 1.1, color = "gray60"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      strip.background = element_rect(fill = "#f0f0f0")
    )
}

# Apply with custom parameters
p + corporate_theme(base_size = 14)
```

