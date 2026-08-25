## Multiple Plot Arrangements


### The patchwork Package [Inference]

The patchwork package provides intuitive syntax for combining plots:

```r
library(patchwork)

# Create individual plots
p1 <- ggplot(mpg, aes(displ, hwy)) + geom_point() + labs(title = "Plot 1")
p2 <- ggplot(mpg, aes(class, hwy)) + geom_boxplot() + labs(title = "Plot 2")
p3 <- ggplot(mpg, aes(hwy)) + geom_histogram() + labs(title = "Plot 3")
p4 <- ggplot(mpg, aes(cyl, fill = factor(cyl))) + geom_bar() + labs(title = "Plot 4")

# Simple combinations
p1 + p2                    # Side by side
p1 / p2                    # Stacked vertically
(p1 + p2) / (p3 + p4)      # 2x2 grid

# Complex layouts
p1 + p2 + p3 + plot_layout(ncol = 2, nrow = 2)

# Different sizing
p1 + p2 + plot_layout(widths = c(2, 1))  # First plot twice as wide
p1 / p2 + plot_layout(heights = c(1, 2))  # Second plot twice as tall
```

### Advanced Patchwork Layouts [Inference]

```r
# Complex arrangements with nested layouts
layout <- "
  AAB
  CCB
  CDD
"
p1 + p2 + p3 + p4 + plot_layout(design = layout)

# Collecting legends and titles
(p1 + p2) / (p3 + p4) + 
  plot_layout(guides = "collect") +
  plot_annotation(
    title = "Combined Analysis",
    subtitle = "Multiple perspectives on automotive data",
    caption = "Data: mpg dataset"
  )
```

### Base R and gridExtra Alternatives [Inference]

For environments without patchwork:

```r
library(gridExtra)

# Using gridExtra
grid.arrange(p1, p2, p3, p4, ncol = 2, nrow = 2)

# With custom layout matrix
layout_matrix <- rbind(c(1, 2),
                      c(3, 3))
grid.arrange(p1, p2, p3, layout_matrix = layout_matrix)
```

