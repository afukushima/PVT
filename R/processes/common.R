

#####################################
## Prefixed listing of AtMetExpress files
#####################################
atMetFileList <- c(
	'Kusano07BMC_Syst_Biol',
  'Kusano10AminoAcids',
  'Kusano11TPJ',
  'Fukushima11BMC_Syst_Biol',
  'Fukushima_unpublished_mto1xtt4')


#####################################
## Prefixed listing of MeKO files
#####################################
mekoFileList <- c(
	'All', 
	'Batch01', 
	'Batch02', 
	'Batch03', 
	'Batch04', 
	'Batch05')

#####################################
## Filtering missing values from data
#####################################
filter.missing.values <- function(eset, ratio) {
	if(ratio == 0.0) eset
	else {
	  # Vector of column NA counts
	  xx <- apply(exprs(eset), 1, function(row) length(which(is.na(row))))  
	  thr <- dim(eset)[2] * ratio   # missing values threshold (0.5 means 50% cutoff)
	  xx.ind <- ifelse(xx>=thr, TRUE, FALSE)
	  eset <- eset[!xx.ind,]
	}
}
