## Faceting and Subplots


**Faceting Concepts** Faceting creates multiple subplots from a single dataset based on categorical variables, enabling comparison across groups while maintaining consistent scales and visual encodings. This approach follows the small multiples principle, where repeated chart structures facilitate pattern recognition across different data subsets.

**facet_wrap() Function** The facet_wrap() function creates subplots arranged in a rectangular grid based on a single categorical variable. Syntax follows facet_wrap(~ variable) or facet_wrap(vars(variable)) in newer ggplot2 versions. Parameters include ncol and nrow for grid dimensions, scales for independent axis scaling, and labeller for custom panel labels.

**facet_grid() Function** The facet_grid() function creates matrix-like arrangements based on two categorical variables, with one variable defining rows and another defining columns. Syntax uses facet_grid(rows ~ cols) or facet_grid(vars(rows), vars(cols)). This approach works best when both variables have relatively few levels to avoid creating too many subplots.

**Scale Independence** The scales parameter controls axis scaling across facets: "fixed" (default) maintains identical scales across all subplots, "free" allows independent scaling for both axes, "free_x" allows independent x-axis scaling, and "free_y" allows independent y-axis scaling. Independent scaling helps when data ranges vary dramatically across groups but can complicate direct comparisons.

**Space Allocation** The space parameter controls subplot sizes based on data density. Options include "fixed" for equal subplot sizes and "free" for sizes proportional to data ranges. This feature proves particularly useful when categories have dramatically different data amounts or ranges.

**Facet Labels and Formatting** Custom labeller functions modify facet panel labels for improved readability. The labeller parameter accepts functions that transform variable values into display labels. Common approaches include label_both() for variable names and values, label_value() for values only, and custom functions for complex formatting needs.

**Complex Faceting Patterns** Advanced faceting includes nested variables through interaction terms, margin plots showing overall patterns alongside group-specific patterns, and custom facet arrangements through manual plot combination using packages like patchwork or cowplot.

**Performance Considerations** Large numbers of facets can impact performance and readability. [Inference] Consider limiting facets to meaningful comparisons, using alternative visualization approaches like animation for temporal data, or implementing interactive filters for large categorical datasets.

