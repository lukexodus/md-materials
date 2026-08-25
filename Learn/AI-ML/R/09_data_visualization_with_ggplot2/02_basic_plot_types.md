## Basic Plot Types


**Scatter Plots** Scatter plots visualize relationships between two continuous variables using geom_point(). Basic syntax begins with ggplot(data, aes(x = variable1, y = variable2)) + geom_point(). Additional aesthetics like color, size, and shape can encode additional variables, creating multidimensional visualizations within two-dimensional space.

**Advanced Scatter Plot Features** Scatter plots support extensive customization through point aesthetics. The size aesthetic maps to continuous variables, while shape maps to categorical variables with limited distinct values. Alpha transparency handles overplotting in dense datasets, and position adjustments like jitter add random noise to separate overlapping points.

**Line Plots** Line plots connect data points sequentially using geom_line(), ideal for time series data and trend visualization. The group aesthetic determines which points connect when multiple series exist within the same dataset. Line types (solid, dashed, dotted) and colors distinguish between different series or categories.

**Time Series Considerations** Time series plots require proper date/time formatting on the x-axis. The scale_x_date() and scale_x_datetime() functions provide appropriate axis formatting and break intervals. Multiple time series benefit from color or line type distinctions, while faceting separates series into individual subplots when comparison is less critical.

**Bar Charts** Bar charts display categorical data using geom_col() for pre-computed values or geom_bar() for count data. The position parameter controls bar arrangement: "stack" (default) creates stacked bars, "dodge" places bars side-by-side, and "fill" creates proportional stacked bars totaling 100%.

**Bar Chart Variations** Horizontal bar charts use coord_flip() or specify categorical variables on the y-axis. Error bars add uncertainty information through geom_errorbar(), while text labels provide exact values via geom_text(). Color aesthetics distinguish categories, and manual color scales ensure consistent color assignments across multiple plots.

**Histograms** Histograms visualize continuous variable distributions using geom_histogram(), automatically binning data and counting observations per bin. The bins parameter specifies bin count, while binwidth sets exact bin widths. Appropriate bin selection balances detail with noise, typically following Sturges' rule or Freedman-Diaconis rule for automatic bin selection.

**Distribution Analysis** Histograms reveal distribution shape, central tendency, spread, and potential outliers. Overlaying normal curves using stat_function() enables distribution comparison, while multiple histograms with alpha transparency compare group distributions. Density plots (geom_density()) provide smooth distribution estimates without binning artifacts.

**Box Plots** Box plots summarize continuous variable distributions using geom_boxplot(), displaying median, quartiles, and potential outliers. These plots excel at comparing distributions across categories and identifying outliers that exceed 1.5 times the interquartile range beyond the box boundaries.

**Box Plot Enhancements** Violin plots (geom_violin()) combine box plot information with density estimation, showing distribution shape more clearly than traditional box plots. Notched box plots indicate significant differences between medians, while outlier customization controls outlier point appearance and labeling.

