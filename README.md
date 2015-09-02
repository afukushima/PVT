PVT (PRIMe Visualization Tools)
========
RIKEN PRIMe provides web-based data analysis and visualization tools for public access. Users may analyze datasets from both AtMetExpress and MeKO, as well as upload custom datasets.

Installation & Run
------------
```R
install.packages("devtools")
source("http://bioconductor.org/biocLite.R")
biocLite("pcaMethods")

library(devtools)
install_github("afukushima/PVT")

## NOT RUN
library(shiny)
library(pcaMethods)
runApp('./R')
```
