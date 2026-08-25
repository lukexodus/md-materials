## Extensions and Additional Packages


### ggtext for Rich Text Formatting [Inference]

```r
library(ggtext)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  labs(
    title = "Fuel Efficiency Analysis",
    subtitle = "Relationship between <span style='color:red'>**engine size**</span> and <span style='color:blue'>**highway MPG**</span>",
    caption = "Data source: EPA fuel economy data"
  ) +
  theme_minimal() +
  theme(
    plot.subtitle = element_markdown(),
    plot.title = element_text(size = 16, face = "bold")
  )
```

### gghighlight for Emphasis [Inference]

```r
library(gghighlight)

# Highlight specific data points
ggplot(mpg, aes(displ, hwy, color = class)) +
  geom_point() +
  gghighlight(class == "compact") +
  theme_minimal()

# Highlight with custom conditions
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  gghighlight(hwy > 35, use_direct_label = FALSE) +
  facet_wrap(~class) +
  theme_minimal()
```

### ggrepel for Smart Label Placement [Inference]

```r
library(ggrepel)

# Avoid overlapping labels
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class), size = 3) +
  geom_text_repel(aes(label = ifelse(hwy > 35, as.character(model), "")),
                  box.padding = 0.5, point.padding = 0.3, 
                  segment.color = "grey50") +
  theme_minimal()
```

### Extension Ecosystem [Inference]

```r
# Statistical extensions
library(ggstats)      # Additional statistical geoms
library(GGally)       # Matrix plots and correlation plots
library(corrplot)     # Specialized correlation visualizations

# Specialized domains
library(ggmap)        # Geographic visualizations
library(ggtree)       # Phylogenetic trees
library(ggalluvial)   # Alluvial/Sankey diagrams
library(ggforce)      # Additional geoms and utilities
library(ggdist)       # Uncertainty visualization
```

