## Saving and Exporting Plots


**ggsave() Function** The ggsave() function provides the primary method for exporting ggplot2 graphics to files. Basic syntax includes ggsave("filename.ext") to save the last created plot, or ggsave("filename.ext", plot_object) for specific plots. The function automatically detects output format from file extensions and applies appropriate settings.

**File Format Options** Supported output formats include vector formats (PDF, SVG, EPS) for scalable graphics ideal for publications, and raster formats (PNG, JPEG, TIFF) for web use and presentations. Vector formats maintain quality at any size but may have larger file sizes for complex plots, while raster formats have fixed resolutions but smaller file sizes.

**Resolution and Size Control** The width, height, and units parameters control output dimensions using units like inches, centimeters, or pixels. The dpi parameter sets resolution for raster formats, with 300 DPI recommended for print publications and 72-150 DPI sufficient for web use. The scale parameter proportionally adjusts all plot elements.

**Plot Quality Optimization** High-quality output requires attention to text sizing, line weights, and color choices. Text should remain readable at target sizes, line weights should be consistent with publication standards, and colors should reproduce accurately across different media. The family parameter in theme elements specifies fonts available in output formats.

**Batch Export Workflows** Multiple plot export often requires programmatic approaches combining plot creation loops with systematic file naming. The here package provides robust file path construction, while sprintf() creates consistent file names with variable components. Version control considerations include timestamping and parameter documentation.

**Publication-Ready Outputs** Publication requirements typically specify exact dimensions, resolutions, fonts, and file formats. Common journal specifications include 300 DPI TIFF files with specific width limits, embedded fonts for PDF submissions, and color mode specifications. Always verify output appearance at target sizes before final submission.

**Interactive Plot Export** Interactive plots created with plotly require different export approaches through plotly::export() function or screenshot methods. These plots may lose interactivity when exported to static formats, requiring consideration of which features are essential for the intended use.

**Memory and Performance** Large or complex plots may require significant memory for high-resolution export. Monitor memory usage during export processes, consider reducing plot complexity for very high resolutions, and use appropriate file formats for intended use. Batch processing may require memory management strategies to prevent system overload.

**Key Points**

- ggplot2 implements the Grammar of Graphics, providing systematic approaches to data visualization through layered components
- Basic plot types (scatter, line, bar, histogram) form the foundation for more complex visualizations and can be extensively customized
- Aesthetic mappings connect data variables to visual properties, while scales control how these mappings translate to actual visual elements
- Faceting enables small multiples approaches for comparing patterns across different data subsets
- Theme systems provide complete control over non-data visual elements, enabling consistent styling and publication-ready outputs
- Color palette selection requires consideration of data types, accessibility, and reproduction across different media
- Annotations and labels provide essential context and explanation for complex visualizations
- Export functions offer flexibility for different output requirements while maintaining quality across formats

Related topics include advanced statistical graphics, interactive visualization with plotly and shiny, specialized visualization packages for specific domains (maps, networks, time series), and integration with other visualization frameworks for comprehensive data storytelling workflows.

---

