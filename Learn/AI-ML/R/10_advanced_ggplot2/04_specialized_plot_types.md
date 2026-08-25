## Specialized Plot Types


### Density and Contour Plots

Advanced density visualizations reveal data distributions:

```r
# 2D density plots
ggplot(faithful, aes(waiting, eruptions)) +
  geom_density_2d_filled(alpha = 0.8) +
  geom_point(size = 0.5, alpha = 0.5) +
  scale_fill_viridis_d() +
  theme_minimal()

# Hexagonal binning for large datasets
ggplot(diamonds, aes(carat, price)) +
  geom_hex() +
  scale_fill_continuous(type = "viridis") +
  theme_minimal()

# Ridge plots for distribution comparison
library(ggridges)
ggplot(mpg, aes(x = hwy, y = class, fill = class)) +
  geom_density_ridges(alpha = 0.7) +
  theme_minimal() +
  theme(legend.position = "none")
```

### Network and Tree Visualizations [Inference]

```r
# Network plots with ggraph
library(ggraph)
library(igraph)

# Create sample network
network <- graph_from_data_frame(
  data.frame(from = c("A", "B", "C", "A"), 
             to = c("B", "C", "D", "D"))
)

ggraph(network, layout = "kk") +
  geom_edge_link(alpha = 0.6) +
  geom_node_point(size = 5, color = "steelblue") +
  geom_node_text(aes(label = name), vjust = 1.8) +
  theme_void()
```

### Heatmaps and Matrix Visualizations

```r
# Correlation heatmap
library(reshape2)
cor_matrix <- cor(mtcars)
cor_melted <- melt(cor_matrix)

ggplot(cor_melted, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                      midpoint = 0, limit = c(-1,1)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
  coord_fixed()
```

### Advanced Time Series Plots

```r
# Multi-layer time series with annotations
library(lubridate)

# Sample time series data
dates <- seq(as.Date("2020-01-01"), as.Date("2023-12-31"), by = "month")
values <- cumsum(rnorm(length(dates), mean = 5, sd = 10))
ts_data <- data.frame(date = dates, value = values)

ggplot(ts_data, aes(date, value)) +
  geom_line(size = 1.2, color = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, alpha = 0.3) +
  geom_point(size = 2, alpha = 0.7) +
  annotate("rect", xmin = as.Date("2020-03-01"), xmax = as.Date("2020-05-31"), 
           ymin = -Inf, ymax = Inf, alpha = 0.2, fill = "red") +
  annotate("text", x = as.Date("2020-04-15"), y = max(ts_data$value) * 0.9, 
           label = "COVID-19 Period", size = 3) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

