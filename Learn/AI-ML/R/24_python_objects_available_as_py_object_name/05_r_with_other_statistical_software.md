## R with Other Statistical Software


R's interoperability extends to other statistical platforms, enabling workflows that leverage specialized capabilities.

**STATA Integration**

```r
library(RStata)

# Configure Stata path
options("RStata.StataPath" = "/usr/local/stata/stata")
options("RStata.StataVersion" = 17)

# Execute Stata commands
stata_results <- stata("
  use dataset.dta
  regress dependent_var independent_var1 independent_var2
  predict residuals, residuals
  export delimited residuals.csv, replace
")

# Read Stata results back to R
residuals <- read.csv("residuals.csv")
```

**SAS Integration**

```r
library(haven)
library(SASxport)

# Read SAS datasets
sas_data <- read_sas("data.sas7bdat")
xpt_data <- read_xpt("transport.xpt")

# Write to SAS formats
write_sas(r_data, "output.sas7bdat")
write_xpt(r_data, "output.xpt")

# Execute SAS code via system calls [Inference]
system('sas -sysin analysis.sas -log analysis.log -print analysis.lst')
```

**SPSS Integration**

```r
library(haven)
library(foreign)

# Read SPSS files
spss_data <- read_spss("survey_data.sav")
spss_portable <- read.spss("data.por")

# Handle SPSS variable labels and value labels
attributes(spss_data$variable_name)$label
attributes(spss_data$categorical_var)$labels

# Write SPSS format
write_sav(processed_data, "results.sav")
```

**Matlab Integration**

```r
library(R.matlab)

# Read Matlab files
matlab_data <- readMat("data.mat")

# Write Matlab files
writeMat("results.mat", 
  matrix_data = as.matrix(results),
  vector_data = numeric_vector,
  metadata = list(created = Sys.time()))

# Execute Matlab scripts [Inference]
system("matlab -nodisplay -r 'run analysis.m; exit'")
```

