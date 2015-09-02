library(amap)
library(crmn)
library(genefilter)
library(gplots)
library(limma)
library(metrik)
library(shiny)


######################################################
###  limma for differential metabolite accumulation
######################################################
atMetProcessData <- function(mydata, dataname) {
  targets <- pData(mydata)
  
  # For HCA
  x.f <- exprs(mydata)
  rownames(x.f) <- fData(mydata)$preferred
  colnames(x.f) <- pData(mydata)$Genotype

  # Save variables used for viewers/plots
  results = list(
    mydata = mydata,
    targets = targets,
    x.f = x.f
  )
  return(results)
}
