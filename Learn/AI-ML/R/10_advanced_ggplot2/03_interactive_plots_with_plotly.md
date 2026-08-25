## Interactive Plots with plotly


### Converting ggplot to plotly [Inference]

The plotly package seamlessly converts ggplot objects to interactive visualizations:

```r
library(plotly)

# Basic conversion
p <- ggplot(mpg, aes(displ, hwy, color = class)) +
  geom_point(size = 3, alpha = 0.7) +
  theme_minimal()

# Convert to interactive
ggplotly(p)

# With custom tooltip
p_tooltip <- ggplot(mpg, aes(displ, hwy, color = class, 
                            text = paste("Model:", model,
                                       "<br>Year:", year,
                                       "<br>MPG:", hwy))) +
  geom_point(size = 3, alpha = 0.7) +
  theme_minimal()

ggplotly(p_tooltip, tooltip = "text")
```

### Advanced plotly Features [Inference]

```r
# Custom hover information and styling
p_advanced <- ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class, size = cyl,
                text = paste0("Model: ", model, "\n",
                            "Class: ", class, "\n", 
                            "Engine: ", displ, "L\n",
                            "Highway MPG: ", hwy, "\n",
                            "Cylinders: ", cyl)), alpha = 0.7) +
  scale_size_continuous(range = c(2, 8)) +
  theme_minimal()

# Convert with custom configuration
ggplotly(p_advanced, tooltip = "text") %>%
  layout(
    title = list(text = "Interactive Car Efficiency Analysis", x = 0.5),
    hovermode = "closest",
    showlegend = TRUE
  ) %>%
  config(
    displayModeBar = TRUE,
    modeBarButtons = list(list("zoom2d", "pan2d", "select2d", "lasso2d", 
                              "zoomIn2d", "zoomOut2d", "autoScale2d", 
                              "resetScale2d"))
  )
```

### Native plotly Syntax [Inference]

For maximum control, use native plotly syntax:

```r
# Pure plotly approach
plot_ly(mpg, x = ~displ, y = ~hwy, color = ~class, size = ~cyl,
        text = ~paste("Model:", model), hovertemplate = "%{text}<br>MPG: %{y}") %>%
  add_markers(alpha = 0.7) %>%
  layout(
    title = "Fuel Efficiency by Engine Size",
    xaxis = list(title = "Engine Displacement (L)"),
    yaxis = list(title = "Highway MPG"),
    showlegend = TRUE
  )
```

