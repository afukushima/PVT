library(crmn)
library(metrik)
library(shiny)

source('processes/common.R', local=TRUE)

######################
## data smmarization and evaluation for GCMS data

gcmsProcessData <- function(gcdata, apStd, apFactor, apNcomp) {
    ######################
    ## remove STD mixtures. If you run the command without STD info, the resulting data matrix will be generated as an enply matrix.
    gcdata2 <- gcdata[, -c(grep("STD", gcdata$gcid), grep("FD", gcdata$gcid), grep("^Cont", gcdata$gcid), grep("Alkane", gcdata$gcid))]


    ## ## remove outliers
    ## outlier <- c("Alkane_2")
    ## gcdata <-  gcdata_after[,-which(gcdata_after$gcid %in% outlier)]


    ######################
    ## Data Normalization
    ######################
    ## One normalization
    gcdata.1 <- normalize(gcdata2, "one", one="Hexadecanoate_13C4") ## Users can select their internal standard (Hexadecanoate_13C4 in this case).

    ## Before CRMN normalization
    ## if we fit the normalization parameters first, we can also do diagnostics: factors=c("")
    crmn.fit <- normFit(gcdata2, "crmn", factors=apFactor)  ## In this case, a factor was selected as "genotype" in the phenodata. Users can choose any factors, for example, "treatment" and "days".

    ## for CRMN, we need an experiment matrix, G, this can be made
    ## automatically by setting the important factors:
    ## choose the factors which we want to protect for making experiment matrix
    gcdata2.crmn <- normalize(gcdata2, "crmn", factors=apFactor, ncomp=apNcomp)  ## Users can also choose the number of component (ncomp=2 in this case) for CRMN normalization.


    ## export
    #user.outfile <- "user.out"  ## Users can specify their own filename of normalized data.
    #writeGCMS(gcdata.1, paste(user.outfile, "_one_normalized.txt", sep=""))
    #writeGCMS(gcdata2.crmn, paste(user.outfile, "_CRMN_normalized.txt", sep=""))

    ## User can filter out peaks with many missing values in the uploaded data.
    ## When set a cutoff value (ex. 30% missing value in a peak across samples)
    # filter.threshhold <- 0.3
    # gcdata2.crmn.f <- filter.missing.values(gcdata2.crmn, filter.threshhold)  # filtering by NA

    results = list(
        gcdata = gcdata,
        gcdata2 = gcdata2,
        gcdata.1 = gcdata.1,
        gcdata2.crmn = gcdata2.crmn
    )
    return(results)
}