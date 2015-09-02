library(crmn)
library(metrik)
library(shiny)
library(graph)

source('processes/common.R', local=TRUE)

genericProcessData <- function(data1, data2) {
	#############################################
	## Summarization of two datasets
	#############################################

	## Create a named list of all the data sets we want to summarize, 
	#  but we cannot summarize hplc data using this ver of the script:
	mylist <- list(Data1 = data1, Data2 = data2)
	
	## Concatinate dataset using the identifier column (here the gcid)
	concat.data <- concat(mylist, "sampleinformation")
	sum.data <- summarize(concat.data, "preferred")
	
	colnames(sum.data) <- sum.data$sampleinformation
	size(sum.data)
	dim(sum.data)
	
	filter.threshhold <- 0.3
	sum.data.f <- filter.missing.values(sum.data, filter.threshhold)  # filtering by NA

	results = list(
		mylist = mylist,
		sum.data = sum.data,
		data1 = data1,
		data2 = data2
	)
	return(results)
}