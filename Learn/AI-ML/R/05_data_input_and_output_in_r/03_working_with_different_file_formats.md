## Working with Different File Formats


**JSON Data Handling** JSON (JavaScript Object Notation) files require the jsonlite package for reading and writing. The fromJSON() function converts JSON strings or files to R objects, while toJSON() performs the reverse conversion. The flatten parameter controls whether nested structures are simplified, and pretty parameter formats output for readability.

**XML and HTML Parsing** The xml2 package provides comprehensive XML parsing capabilities through read_xml() and xml_find_all() functions. HTML tables can be extracted using rvest package's html_table() function. These tools support XPath and CSS selectors for precise element selection from complex documents.

**Statistical Software Formats** The haven package reads files from SPSS (.sav), Stata (.dta), and SAS (.sas7bdat) formats, preserving variable labels and value labels as attributes. The foreign package provides similar capabilities for older format versions. These packages maintain statistical software-specific metadata that standard formats cannot preserve.

**Geospatial Data Formats** Spatial data requires specialized packages like sf for modern spatial formats (GeoJSON, Shapefile, KML) and sp for legacy formats. The rgdal package provides broader format support through GDAL libraries, handling dozens of geospatial formats including raster and vector data.

**Image and Media Files** The jpeg, png, and tiff packages enable reading image files as arrays. The tuneR package handles audio files, while av package provides video processing capabilities. These packages convert media files to R data structures for analysis and processing.

**Binary and Custom Formats** The readBin() and writeBin() functions handle arbitrary binary file formats, useful for proprietary data formats or memory dumps. Custom format support often requires understanding file specifications and implementing custom parsing functions.

**Format Conversion Tools** R excels at converting between formats through import-process-export workflows. Common conversions include Excel to CSV, JSON to data frames, and statistical software formats to R native formats. The rio package provides unified import/export interface that automatically detects formats based on file extensions.

