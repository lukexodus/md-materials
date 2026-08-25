## Animation with gganimate


### Basic Animation Principles [Inference]

```r
library(gganimate)
library(transformr)  # For smoother transitions

# Create animated scatter plot
animated_plot <- ggplot(gapminder::gapminder, 
                       aes(gdpPercap, lifeExp, size = pop, color = continent)) +
  geom_point(alpha = 0.7) +
  scale_x_log10() +
  scale_size(range = c(2, 12)) +
  theme_minimal() +
  labs(
    title = "Life Expectancy vs GDP per Capita: {closest_state}",
    x = "GDP per Capita (log scale)",
    y = "Life Expectancy (years)",
    size = "Population",
    color = "Continent"
  ) +
  transition_time(year) +
  ease_aes("linear")

# Render animation
animate(animated_plot, duration = 10, fps = 20, width = 800, height = 600, 
        renderer = gifski_renderer("gdp_animation.gif"))
```

### Advanced Animation Techniques [Inference]

```r
# Multiple transition types
reveal_plot <- ggplot(economics, aes(date, unemploy)) +
  geom_line(size = 1, color = "steelblue") +
  theme_minimal() +
  labs(
    title = "US Unemployment Over Time",
    subtitle = "Data revealed progressively",
    x = "Year", 
    y = "Unemployment (thousands)"
  ) +
  transition_reveal(date) +
  ease_aes("cubic-in-out")

# State-based transitions for categorical changes
state_plot <- ggplot(mpg, aes(displ, hwy, color = factor(cyl))) +
  geom_point(size = 3, alpha = 0.8) +
  theme_minimal() +
  labs(
    title = "Engine Efficiency by Cylinder Count: {closest_state}",
    x = "Displacement (L)",
    y = "Highway MPG",
    color = "Cylinders"
  ) +
  transition_states(cyl, transition_length = 2, state_length = 3) +
  enter_fade() +
  exit_fade()

# Complex animations with multiple layers
complex_animation <- ggplot(gapminder::gapminder, 
                           aes(gdpPercap, lifeExp)) +
  geom_point(aes(size = pop, color = continent), alpha = 0.7) +
  geom_smooth(se = FALSE, color = "black", size = 0.5) +
  scale_x_log10() +
  scale_size(range = c(1, 10)) +
  theme_minimal() +
  labs(
    title = "Global Development Trends: {closest_state}",
    subtitle = "Relationship between wealth and health over time",
    x = "GDP per Capita (PPP, log scale)",
    y = "Life Expectancy at Birth (years)",
    size = "Population", 
    color = "Continent",
    caption = "Data: Gapminder Foundation"
  ) +
  transition_time(year) +
  ease_aes("cubic-in-out") +
  enter_grow() +
  exit_shrink()
```

### Animation Optimization and Export [Inference]

```r
# High-quality animation settings
anim <- animate(
  complex_animation,
  duration = 15,          # Total duration in seconds
  fps = 30,               # Frames per second
  width = 1200,           # Width in pixels
  height = 800,           # Height in pixels
  res = 150,              # Resolution
  end_pause = 30,         # Pause at end (frames)
  renderer = gifski_renderer(loop = TRUE)
)

# Save with different renderers
# For web use
animate(complex_animation, renderer = gifski_renderer("web_animation.gif"))

# For presentations (MP4)
animate(complex_animation, renderer = av_renderer("presentation.mp4"))

# For high quality (larger files)
animate(complex_animation, 
        renderer = magick_renderer(loop = TRUE),
        width = 1920, height = 1080, res = 200)
```

**Key Points:**

- Custom themes provide consistent visual identity across multiple plots
- The patchwork package offers intuitive syntax for complex plot arrangements [Inference]
- plotly integration enables interactive web-ready visualizations [Inference]
- Specialized extensions expand ggplot2's capabilities for domain-specific needs [Inference]
- Publication-ready graphics require attention to typography, color accessibility, and output specifications
- Animation capabilities transform static visualizations into dynamic storytelling tools [Inference]
- Performance considerations become important with complex layouts and animations [Inference]

**Important Subtopics:**

- Color theory and accessibility in data visualization
- Statistical visualization best practices and misconceptions
- Integration with Shiny for interactive dashboard development
- Performance optimization for large datasets
- Custom geom development for specialized visualization needs

---

