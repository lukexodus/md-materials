## Color Palettes and Legends


**Color Theory Principles** Effective color use in data visualization requires understanding color theory fundamentals including hue, saturation, and brightness. Sequential color palettes work best for continuous data with natural ordering, diverging palettes highlight deviations from central values, and qualitative palettes distinguish categorical data without implying order.

**Built-in Color Palettes** ggplot2's default color palettes provide reasonable starting points but may require customization for specific needs. The scale_color_hue() function controls default categorical colors through hue, chroma, and luminance parameters. Continuous data uses scale_color_gradient() family functions with customizable start and end colors.

**ColorBrewer Integration** The RColorBrewer package provides ColorBrewer palettes designed specifically for maps and statistical graphics. These palettes undergo extensive testing for colorblind accessibility and printing compatibility. Access through scale_color_brewer() and scale_fill_brewer() functions with palette names like "Set1", "Blues", or "RdYlBu".

**Viridis Color Scales** The viridis package offers perceptually uniform color scales that maintain consistency across different viewing conditions and color vision types. These scales work particularly well for continuous data and heatmaps. Integration through scale_color_viridis() and scale_fill_viridis() functions with options including "viridis", "plasma", "inferno", and "cividis".

**Manual Color Specification** Manual color scales provide complete control over color assignments through scale_color_manual() and scale_fill_manual() functions. Colors can be specified using hexadecimal codes, R color names, or RGB values. This approach ensures brand consistency and precise color matching requirements.

**Legend Customization** Legend appearance controls include title modification, label formatting, position adjustment, and visual styling. The guides() function provides detailed legend control, while guide_legend() and guide_colorbar() offer specific customization for discrete and continuous legends respectively.

**Legend Positioning and Layout** Legend positioning uses legend.position theme element with coordinate specifications or predefined positions. Multiple legends can be arranged through legend arrangement parameters, while legend.box controls overall legend layout direction. Complex legend arrangements may require custom guide functions.

**Accessibility Considerations** Color palette selection must consider accessibility for colorblind viewers, representing approximately 8% of males and 0.5% of females. Tools like the dichromat package simulate colorblind vision, while packages like viridis and RColorBrewer provide accessibility-tested palettes. Always combine color with other aesthetics (shape, line type) for critical distinctions.

