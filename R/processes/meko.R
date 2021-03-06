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
mekoProcessData <- function(mydata, dataname) {
  print(dataname)

  # Creating labels (Target) from pData
  targets <- pData(mydata)
  comparison <- factor(targets$genotype)
  levels(comparison)

  # Experiment design matrix
  design <- model.matrix(~-1 + comparison)

  # Set colnames for design, Targets must be identical for replicates, unique summarizes this
  # Otherwise we would need another column with Names for replicates
  colnames(design) <- gsub("comparison", "", colnames(design))

  if (grepl("^All", dataname) == TRUE) {
  #### for All data
  # Create a contrast matrix to get p-values and fold-changes
    contrast.matrix <- makeContrasts(
                                        # Comparisons in control (normal condition)
                                        # genotype comparison
                                        # n = 7
                                     aat22 - col0,
                                     aba15 - col0,
                                     aba16 - col0,
                                     aba21 - col0,
                                     aba23 - col0,
                                     aba31 - col0,
                                     amt11 - col0,
                                     ## n = 9
                                     cim10 - col0,
                                     cim11 - col0,
                                     cim13 - col0,
                                     cim14 - col0,
                                     cim6 - col0,
                                     cim7 - col0,
                                     cim9 - col0,
                                     cla1S - col0,
                                     cob2 - col0,
                                     ## n = 7
                                     eto11 - col0,
                                     eto3 - col0,
                                     fad51 - col0,
                                     fad61 - col0,
                                     fah12 - col0,
                                     fur11 - col0,
                                     fus61S - col0,
                                     ## n = 3
                                     gsr11 - col0,
                                     ixr11 - col0,
                                     ixr12 - col0,
                                     ## n = 11
                                     mur11 - col0,
                                     mur111 - col0,
                                     mur12 - col0,
                                     mur21 - col0,
                                     mur32 - col0,
                                     mur42 - col0,
                                     mur51 - col0,
                                     mur61 - col0,
                                     mur71 - col0,
                                     mur81 - col0,
                                     mur91 - col0,
                                     ## n = 8
                                     pac1S - col0,
                                     pad21 - col0,
                                     pad31 - col0,
                                     pad41 - col0,
                                     pap1D - col0,
                                     phyB9 - col0,
                                     prc11 - col0,
                                     rsw11 - col0,
                                     ## n = 5
                                     rsw21 - col0,
                                     rsw31 - col0,
                                     sng11 - col0,
                                     tbr1 - col0,
                                     vtc11 - col0,                                     
                                     ##
                                     levels=colnames(design)
                                     )
  } else if (grepl("^Batch01", dataname) == TRUE) {
  #### for Batch01 (9 mutants)
  # Create a contrast matrix to get p-values and fold-changes
    contrast.matrix <- makeContrasts(
                                        # Comparisons in control (normal condition)
                                        # genotype comparison
                                     aba15 - col0,
                                     aba23 - col0,
                                     cim6 - col0,
                                     cim7 - col0,
                                     eto11 - col0,
                                     eto3 - col0,
                                     gsr11 - col0,
                                     ixr12 - col0,
                                     rsw21 - col0,
                                     ##
                                     levels=colnames(design)
                                     )
  } else if (grepl("^Batch02", dataname) == TRUE) {
  #### for Batch02 (12 mutants)
  # Create a contrast matrix to get p-values and fold-changes
    contrast.matrix <- makeContrasts(
                                        # Comparisons in control (normal condition)
                                        # genotype comparison
                                     aba21 - col0,
                                     aba31 - col0,
                                     cim11 - col0,
                                     cim13 - col0,
                                     cim9 - col0,
                                     fad51 - col0,
                                     fad61 - col0,
                                     mur91 - col0,
                                     pad21 - col0,
                                     pad41 - col0,
                                     pap1D - col0,
                                     prc11 - col0,
                                     ##
                                     levels=colnames(design)
                                     )
  } else if (grepl("^Batch03", dataname) == TRUE) {
  #### for Batch03 (9 mutants)
  # Create a contrast matrix to get p-values and fold-changes
    contrast.matrix <- makeContrasts(
                                        # Comparisons in control (normal condition)
                                        # genotype comparison
                                     cim14 - col0,
                                     cla1S - col0,
                                     cob2 - col0,
                                     fus61S - col0,
                                     mur21 - col0,
                                     mur42 - col0,
                                     mur51 - col0,
                                     mur61 - col0,
                                     pac1S - col0,
                                     ##
                                     levels=colnames(design)
                                     )
  } else if (grepl("^Batch04", dataname) == TRUE) {
  #### for Batch04 (11 mutants)
  # Create a contrast matrix to get p-values and fold-changes
    contrast.matrix <- makeContrasts(
                                        # Comparisons in control (normal condition)
                                        # genotype comparison
                                     aba16 - col0,
                                     amt11 - col0,
                                     cim10 - col0,
                                     fah12 - col0,
                                     mur111 - col0,
                                     mur71 - col0,
                                     mur81 - col0,
                                     pad31 - col0,
                                     sng11 - col0,
                                     tbr1 - col0,
                                     vtc11 - col0,
                                     ##
                                     levels=colnames(design)
                                     )
  } else if (grepl("^Batch05", dataname) == TRUE) {
  #### for Batch05 (9 mutants)
  # Create a contrast matrix to get p-values and fold-changes
    contrast.matrix <- makeContrasts(
                                        # Comparisons in control (normal condition)
                                        # genotype comparison
                                     aat22 - col0,
                                     fur11 - col0,
                                     ixr11 - col0,
                                     mur11 - col0,
                                     mur12 - col0,
                                     mur32 - col0,
                                     phyB9 - col0,
                                     rsw11 - col0,
                                     rsw31 - col0,
                                     ##
                                     levels=colnames(design)
                                     )
  }
  
	# log transformation
	x <- log2(exprs(mydata))
	mydata.f <- ifelse(is.nan(x), NA, x)

	# Fit a linear model to that
	fit <- lmFit(mydata.f, design)

	# Fit the data
	fit2 <- contrasts.fit(fit, contrast.matrix)
	fit2 <- eBayes(fit2)

	# output of sumgaba2
	pVal <- apply(fit2$p.value, 2, function(x) p.adjust(t(x), method="BH"))
	colnames(pVal) <- paste(colnames(fit2), " (BH Adj.p)", sep="")
	tmp <- cbind(coef(fit2), pVal)
	tmp2 <- tmp[, order(colnames(tmp))]
	mat <- exprs(mydata)
	res <- cbind(fData(mydata), mat, tmp2) 

	# For HCA
	x <- coef(fit2)
	rownames(x) <- fData(mydata)$preferred
	colnames(x) <- gsub(" - col0", "", colnames(x))
	out <- apply(x, 1, allNA)
	x.f <- x[out,]

	# Save variables used for viewers/plots
	results = list(
	   mydata = mydata,
	   targets = targets,
	   res = res,
	   fit2 = fit2,
	   x.f = x.f
    )
	return(results)
}
