## Command Line R Usage


Command-line R enables automation, scripting, and integration with system workflows.

**Basic Command Line Operations**

```bash
# Execute R scripts
Rscript analysis.R

# Run R with specific arguments
Rscript --vanilla analysis.R --args input.csv output.csv

# Execute R commands directly
R -e "summary(mtcars); quit(save='no')"

# Batch mode execution
R CMD BATCH --no-save --no-restore analysis.R output.log
```

**Advanced Scripting Patterns**

```r
#!/usr/bin/env Rscript

# Command line argument parsing
library(optparse)

option_list <- list(
  make_option(c("-i", "--input"), type = "character", default = NULL,
              help = "Input data file", metavar = "FILE"),
  make_option(c("-o", "--output"), type = "character", default = "results.csv",
              help = "Output file name", metavar = "FILE"),
  make_option(c("-c", "--cores"), type = "integer", default = 1,
              help = "Number of cores to use", metavar = "NUMBER"),
  make_option(c("-v", "--verbose"), action = "store_true", default = FALSE,
              help = "Enable verbose output")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Validate arguments
if (is.null(opt$input)) {
  print_help(opt_parser)
  stop("Input file must be specified", call. = FALSE)
}

# Main processing with error handling
tryCatch({
  if (opt$verbose) cat("Loading data from:", opt$input, "\n")
  data <- read.csv(opt$input)
  
  if (opt$verbose) cat("Processing with", opt$cores, "cores\n")
  results <- process_data(data, cores = opt$cores)
  
  if (opt$verbose) cat("Writing results to:", opt$output, "\n")
  write.csv(results, opt$output, row.names = FALSE)
  
  cat("Analysis completed successfully\n")
  
}, error = function(e) {
  cat("Error:", e$message, "\n")
  quit(status = 1)
})
```

**System Integration Scripts**

```bash
#!/bin/bash
# process_daily_data.sh

# Set environment variables
export R_LIBS_USER="/opt/R/library"
export OMP_NUM_THREADS=4

# Data processing pipeline
echo "Starting daily data processing: $(date)"

# Download data
Rscript download_data.R --date $(date -d "yesterday" +%Y-%m-%d)

# Process data
Rscript process_data.R \
  --input "raw_data/$(date -d 'yesterday' +%Y-%m-%d).csv" \
  --output "processed_data/$(date -d 'yesterday' +%Y-%m-%d)_processed.csv" \
  --cores 8 \
  --verbose

# Generate reports
Rscript -e "
  rmarkdown::render('daily_report.Rmd', 
    params = list(date = '$(date -d 'yesterday' +%Y-%m-%d)'),
    output_file = 'reports/report_$(date -d 'yesterday' +%Y-%m-%d).html')
"

echo "Daily processing completed: $(date)"
```

**Automated Deployment Scripts**

```bash
# deploy_r_app.sh
#!/bin/bash

# Build and deploy R application
docker build -t r-analytics:$(git rev-parse --short HEAD) .
docker tag r-analytics:$(git rev-parse --short HEAD) r-analytics:latest

# Run tests
docker run --rm r-analytics:latest Rscript tests/run_tests.R

# Deploy if tests pass
if [ $? -eq 0 ]; then
  echo "Tests passed, deploying..."
  docker-compose up -d --scale r-app=3
else
  echo "Tests failed, deployment aborted"
  exit 1
fi
```

These integration capabilities enable R to function as part of larger data ecosystems, leveraging the strengths of different platforms while maintaining R's analytical capabilities. The key is choosing appropriate integration patterns based on specific requirements for data flow, computational resources, and deployment constraints.

