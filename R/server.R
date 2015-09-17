library(shiny)

source('processes/common.R', local=TRUE)
source('ui-components/apDialog.R', local=TRUE)
source('processes/atmet.R', local=TRUE)
source('processes/meko.R', local=TRUE)
source('processes/gcms.R', local=TRUE)
source('processes/generic.R', local=TRUE)

getDataFile <- function(file) { return (paste("..", "data", file, sep = "/")) }
getAtMetDataFile <- function(file) { getDataFile(paste("atMet", file, sep = "/")) }
getMekoDataFile <- function(file) { getDataFile(paste("meko", file, sep = "/")) }
printf <- function(...) invisible(print(sprintf(...)))

# Work-arounds

Sys.setlocale(locale="C") # Set opening files independent of system's locale setting
#options(shiny.transcode.json=FALSE) # For encoding issues in 'render*' calls, where server sends "NA" and crashes client

shinyServer(function(input, output, session) {
	clientAp <- reactiveValues(config=NULL)
	
	######################
	## Reactive conductors
	
	hasValidAnalysisParams <- reactive({
		!is.null(clientAp$values) & length(clientAp$values) > 0
	})
	
	##################################
	### Load data based on config type
	##################################
	target <- reactive({
		if(!hasValidAnalysisParams()) return(NULL)
		
		conf <- clientAp$values
		result <- NULL
		
		if(input$apConfig == 'AtMetExpress') {
			rawdata <- getAtMetDataFile(
				paste(conf$filePrefix, "Data.txt", sep="_"))
			pheno <- getAtMetDataFile(
				paste(conf$filePrefix, "phenodata.csv", sep="_"))
			
			if (grepl("Kusano07BMC", rawdata) == TRUE) {
				result <- readGENERIC(rawdata, pheno)
			} else if (grepl("Fukushima11BMC", rawdata) == TRUE) {
				result <- readGENERIC(rawdata, pheno)
			} else {
				result <- readGCMS(rawdata, pheno)
			}
		}
		else if(input$apConfig == 'MeKO') {
			rawdata <- getMekoDataFile(
				paste(conf$filePrefix, conf$norm, "normalized.txt", sep="_"))
			pheno <- getMekoDataFile(
				paste(conf$filePrefix, "phenodata.csv", sep="_"))
			print(rawdata)
			print(pheno)
			result <- readGCMS(rawdata, pheno)
		}
		else if(input$apConfig == 'GC-MS (RIKEN format)') {
			## We used two methods to detect metabolite peaks in a typical GC-MS analysis in RIKEN.
			#  If we have some redundant peaks, we should do peak summarization.
			#  This "summarize" function replaces redundant peaks in a matrix with a univariate
			#  representative of them.
			rawdata <- conf$rawFile$datapath
			pheno <- conf$phenoFile$datapath
			gcdata_before <- readGCMS(rawdata, pheno,standards=TRUE, tables=c("cas", "preferred"))
			result <- summarize(gcdata_before, ids="preferred", dogcpeak=TRUE)
		}
		else if(input$apConfig == 'Generic') {
			## Read Horomone data
			d1 <- conf$dataset1
			d2 <- conf$dataset2
			
			rawdata1 <- d1$rawFile$datapath
			pheno1 <- d1$phenoFile$datapath
			
			rawdata2 <- d2$rawFile$datapath
			pheno2 <- d2$phenoFile$datapath
			
			print('Loading generic data 1...')
			data1 <- readGENERIC(rawdata1, pheno1, id=d1$id, synonymIsUnder=d1$synonym, tables="preferred")
			print('Loaded generic data 1 successfully')
			print('Loading generic data 2...')
			data2 <- readGENERIC(rawdata2, pheno2, id=d2$id, synonymIsUnder=d2$synonym, tables="preferred")
			print('Loaded generic data 2 successfully')
			
			result = list(
				data1 = data1,
				data2 = data2
			)
		}
		result
	})
	
	###########################################
	###  Compute variables based on config type
	###########################################
	vars <- reactive({
		if(!hasValidAnalysisParams()) return(NULL)
		
		conf <- clientAp$values
		result <- NULL
		
		if(input$apConfig == 'AtMetExpress') {
			result <- atMetProcessData(target(), clientAp$values$filePrefix)
		}
		else if(input$apConfig == 'MeKO') {
			result <- mekoProcessData(target(), clientAp$values$filePrefix)
		}
		else if(input$apConfig == 'GC-MS (RIKEN format)') {
			result <- gcmsProcessData(target(), conf$std, conf$factor, conf$ncomp)
		}
		else if(input$apConfig == 'Generic') {
			result <- genericProcessData(target()$data1, target()$data2)
		}
		result
	})
	
	######################################
	###  List mutants based on config type
	######################################
	mutants <- reactive({
		allTargets <- gsub(" - col0", "", colnames(coef(vars()$fit2)))
		c(allTargets)
	})
	
	filteredGenericData <- reactive({
		filter.missing.values(vars()$sum.data, input$genericThresh)  # filtering by NA
	})
	
	
	#####################
	## Reactive endpoints
	# Prints a list of mutants in an HTML select form control
	output$mekoMutantList <- renderUI({
		if(!hasValidAnalysisParams()) return(NULL)
		selectInput('volcano.id', 'Mutant', mutants())
	})
	
	
	######################################
	###  Download listings
	######################################
	formatDLLink <- function(title, handler, formatLabel) {
		div(class='entry', 
				span(p(title)),
				span(downloadLink(handler, formatLabel))
		)
	}
	
	output$mekoDownloads <- renderUI({
		if(!hasValidAnalysisParams()) return(NULL)
		
		div(class = 'downloadList',
				formatDLLink('Limma table', 'mekoDownloadLimma', 'TSV')
		)
	})
	
	output$gcmsDownloads <- renderUI({
		if(!hasValidAnalysisParams()) return(NULL)
		
		div(class = 'downloadList',
				formatDLLink('Normalized data (One)', 'gcmsDownloadOne', 'TSV'),
				formatDLLink('Normalized data (CRMN)', 'gcmsDownloadCrmn', 'TSV')
		)
	})
	
	output$genericDownloads <- renderUI({
		if(!hasValidAnalysisParams()) return(NULL)
		
		div(class = 'downloadList',
				formatDLLink('Summarized data', 'genericDownloadSummary', 'TSV')
		)
	})
	
	######################################
	###  Download handlers
	######################################
	output$mekoDownloadLimma <- downloadHandler(
		filename = 'meko_limma_diff_res.tsv',
		content = function(outfile) {
			write.table(data.frame(vars()$res), file=outfile, row.names=FALSE, sep = "\t")
		}
	)
	
	output$gcmsDownloadOne <- downloadHandler(
		filename = 'gcms_one_normalized.tsv',
		content = function(outfile) {
			writeGCMS(vars()$gcdata.1, outfile)
		}
	)
	
	output$gcmsDownloadCrmn <- downloadHandler(
		filename = 'gcms_crmn_normalized.tsv',
		content = function(outfile) {
			writeGCMS(vars()$gcdata2.crmn, outfile)
		}
	)
	
	output$genericDownloadSummary <- downloadHandler(
		filename = 'generic_summarized.tsv',
		content = function(outfile) {
			writeGCMS(vars()$sum.data, outfile)
		}
	)
	
	##############################
	# Principal component analysis
	##############################
	

	output$atMetPCA <- renderPlot({
		if(!hasValidAnalysisParams()) return(NULL)
		pc <- pcaMethods::pca(t(log10((exprs(target())*10000+1)/10000)) , method=input$atMetPcaMethod)
		slplot(pc)
	})
	
	output$mekoPCA <- renderPlot({ 
		if(!hasValidAnalysisParams()) return(NULL)
		pc <- pcaMethods::pca(t(log10(exprs(target()))), method=input$mekoPcaMethod)
		slplot(pc)
	})
	
	output$gcmsPCA <- renderPlot({
		if(!hasValidAnalysisParams()) return(NULL)
		
		if(input$gcmsPcaNorm == 'None') {
			pc <- pcaMethods::pca(t(log10(exprs(vars()$gcdata2))), method=input$gcmsPcaMethod)  ## Users can select "method" for PCA in MeKO.
			slplot(pc)
		}
		else if(input$gcmsPcaNorm == 'One') {
			filtered <- filter.missing.values(vars()$gcdata.1, input$gcmsThresh)  # filtering by NA
			pc <- pcaMethods::pca(t(log10(exprs(filtered))), method=input$gcmsPcaMethod)
			slplot(pc)#, scol=as.integer(vars()$gcdata.1$"genotype")+1)
		}
		else if(input$gcmsPcaNorm == 'CRMN') {
			filtered <- filter.missing.values(vars()$gcdata2.crmn, input$gcmsThresh)  # filtering by NA
			pc <- pcaMethods::pca(t(log10(exprs(filtered))), method=input$gcmsPcaMethod)
			slplot(pc)#, scol=as.integer(vars()$gcdata2$"genotype")+1)
		}
	})
	
	output$genericPCA <- renderPlot({ 
		if(!hasValidAnalysisParams()) return(NULL)
		
		#filtered <- filter.missing.values(vars()$sum.data, input$genericThresh)  # filtering by NA
		#pc <- pca(t(log10(exprs(filtered))), method=input$genericPcaMethod)
		pc <- pcaMethods::pca(t(log10(exprs(filteredGenericData()))), method=input$genericPcaMethod)
		slplot(pc)
	})
	
	##############################
	# Data as expressionSet tables
	##############################
	
	# !! Work-around: because output of f/pData may contain NA factors
	# and renderTable cannot handle these, this method converts the 
	# output into a string matrix with UTF-8 encoding, then into a data
	# frame for safe rendering
	cleanNA <- function(x) {
		m <- matrix(unlist(x), ncol=ncol(x), byrow = FALSE)
		m[] <- iconv(m, to="UTF-8")
		result <- data.frame(m, stringsAsFactors=FALSE)
		names(result) <- colnames(x)
		result
	}
	
	output$gcmsFData <- renderTable({ cleanNA(fData(vars()$gcdata)) })
	output$gcmsPData <- renderTable({ cleanNA(pData(vars()$gcdata)) })
	
	output$genericFData <- renderTable({
		if(input$genericExprSet == 'Dataset 1') cleanNA(fData(vars()$data1))
		else if(input$genericExprSet == 'Dataset 2') cleanNA(fData(vars()$data2))
	})
	
	output$genericPData <- renderTable({
		if(input$genericExprSet == 'Dataset 1') cleanNA(pData(vars()$data1))
		else if(input$genericExprSet == 'Dataset 2') cleanNA(pData(vars()$data2))
	})
	
	#####################
	# Limma table
	#####################
	output$mekoLTable <- renderTable({
		if(!hasValidAnalysisParams()) return(NULL)
		data.frame(vars()$res)
	})
	
	#####################
	# Volcano plot
	#####################
	output$mekoVolcano <- renderPlot({
		if(!hasValidAnalysisParams()) return(NULL)
		my.max <- 30
		my.names <- fData(vars()$mydata)$preferred
		my.names <- replace(my.names, which(is.na(my.names)), "U") ## replace NA with "U"
		
		allTargets <- gsub(" - col0", "", colnames(coef(vars()$fit2)))
		
		m <- mutants()
		i <- which(m == input$volcano.id, arr.ind=TRUE)
		volcanoplot(vars()$fit2, coef=i, highlight=my.max, 
								names=my.names[as.integer(rownames(vars()$fit2$genes))], main=allTargets[i])
	})
	
	#######################
	# Hierarchical cluster
	#######################
	output$atMetHCluster <- renderPlot({
		if(!hasValidAnalysisParams()) return(NULL)

		hc.method <- tolower(input$atMetHcMethod) # hclust method
		dist.method <- tolower(input$atMetDistMethod) # dist method
		scaling.method <- tolower(input$atMetScalingMethod) # scaling method
		mydata2.d <- dist(t( scalingMethods(vars()$x.f, methods=scaling.method) ), method=dist.method) # Distance
		mydata2.hc <- hclust(mydata2.d, method=hc.method)
		plot(mydata2.hc, hang=-1,  xlab=paste(toupper(hc.method), " & ", toupper(dist.method), sep=""))
	})
	
	output$mekoHCluster <- renderPlot({
		if(!hasValidAnalysisParams()) return(NULL)
		
		hc.method <- tolower(input$mekoHcMethod) # hclust method
		dist.method <- tolower(input$mekoDistMethod) # dist method
		#par(mfrow=c(2,2)) # Plot settings
		mydata2.d <- dist(t(vars()$x.f), method=dist.method) # Distance
		mydata2.hc <- hclust(mydata2.d, method=hc.method)
		plot(mydata2.hc, hang=-1,  xlab=paste(toupper(hc.method), " & ", toupper(dist.method), sep=""))
	})
	
	output$genericHCluster <- renderPlot({
		if(!hasValidAnalysisParams()) return(NULL)
		
		dist.method <- tolower(input$genericDistMethod) # dist method
		hc.method <- tolower(input$genericHCMethod) # hclust method
		
		sum.data.f <- filteredGenericData()
		sum.data.f.d <- dist(t(exprs(sum.data.f)), method=dist.method) # Distance
		sum.data.f.hc <- hclust(sum.data.f.d, method=hc.method)
		
		plot(sum.data.f.hc, hang=-1,  xlab=paste(toupper(hc.method), " & ", toupper(dist.method), sep=""))
	})
	
	#######################
	# Heatmaps
	#######################
	output$atMetHeatmap <- renderPlot({
		if(!hasValidAnalysisParams()) return(NULL)

		hc.method2 <- tolower(input$atMetHcMethod2) # hclust method
		dist.method2 <- tolower(input$atMetDistMethod2) # dist method
		scaling.method2 <- tolower(input$atMetScalingMethod2) # scaling method
		
		d1 <- dist( scalingMethods(vars()$x.f, methods=scaling.method2), method=dist.method2)
		d2 <- dist(t( scalingMethods(vars()$x.f, methods=scaling.method2) ), method=dist.method2)
		
		c1 <- hclust(d1, method=hc.method2)
		c2 <- hclust(d2, method=hc.method2)
		
		heatmap.2(as.matrix( scalingMethods(vars()$x.f, methods=scaling.method2) ),
							Colv=as.dendrogram(c2),Rowv=as.dendrogram(c1),
							scale="none", col=bluered(128), density.info="none",
							trace="none", key=TRUE, symm=FALSE, symkey=TRUE, symbreaks=1,
							cexRow=0.5, cexCol=0.7
		)
	})
	
	output$mekoHeatmap <- renderPlot({
		if(!hasValidAnalysisParams()) return(NULL)
		
		hc.method2 <- tolower(input$mekoHcMethod2) # hclust method
		dist.method2 <- tolower(input$mekoDistMethod2) # dist method
		
		d1 <- dist(vars()$x.f, method=dist.method2)
		d2 <- dist(t(vars()$x.f), method=dist.method2)
		
		c1 <- hclust(d1, method=hc.method2)
		c2 <- hclust(d2, method=hc.method2)
		
		heatmap.2(as.matrix(vars()$x.f),
							Colv=as.dendrogram(c2),Rowv=as.dendrogram(c1),
							# dendrogram="column",
							scale="none", col=bluered(128), density.info="none",
							trace="none", key=TRUE, symm=FALSE, symkey=TRUE, symbreaks=1,
							cexRow=0.5, cexCol=0.7
		)
	})
	
	output$genericHeatmap <- renderPlot({
		if(!hasValidAnalysisParams()) return(NULL)
		
		sum.data.f <- filteredGenericData()
		data <- exprs(sum.data.f)
		rownames(data) <- fData(sum.data.f)$synonym
		
		dist.method2 <- tolower(input$genericDistMethod2) # dist method
		hc.method2 <- tolower(input$genericHCMethod2) # hclust method
		
		d1 <- dist(data, method=dist.method2)
		d2 <- dist(t(data), method=dist.method2)
		
		c1 <- hclust(d1, method=hc.method2)
		c2 <- hclust(d2, method=hc.method2)
		
		heatmap.2(as.matrix(data),
							Colv=as.dendrogram(c2),Rowv=as.dendrogram(c1),
							scale="none", col=bluered(128), density.info="none",
							trace="none", key=TRUE, symm=FALSE, symkey=TRUE, symbreaks=1,
							cexRow=0.5, cexCol=0.7
		)
	})
	
	#################################################
	# Contents - Display contents of selected dataset
	#################################################
	output$dataContents <- renderText({
		if(!hasValidAnalysisParams()) return(NULL)
		
		vars()$mydata
	})
	
	output$apParamsSummary <- renderUI({
		if(!hasValidAnalysisParams()) p('Unconfigured')
		else {
			f <- function(key, value) {
				p(key, em(value))
			}
			
			# TODO Get directly from clientAp$values for extra validation
			if(input$apConfig == 'AtMetExpress') {
				tags$html(
					f('Data source:', input$apConfig),
					div(class='apParamsSummaryDataset',
							f('Dataset:', input$atMetFile)
					)
				)
			} else if(input$apConfig == 'MeKO') {
				tags$html(
					f('Data source:', input$apConfig),
					div(class='apParamsSummaryDataset',
							f('Dataset:', input$mekoFile),
							f('Normalization:', input$norm)
					)
				)
			} else if(input$apConfig == 'GC-MS (RIKEN format)') {
				tags$html(
					f('Data source:', input$apConfig),
					div(class='apParamsSummaryDataset',
							f('Raw file:', input$gcmsRawFile$name),
							f('Phenodata file:', input$gcmsPhenoFile$name),
							f('Normalization:', input$norm),
							f('Internal standard:', input$gcmsStd),
							f('Factor(s):', input$gcmsFactor),
							f('No. of components:', input$gcmsNcomp)
					)
				)
			}
			else if(input$apConfig == 'Generic') {
				tags$html(
					f('Data source:', input$apConfig),
					h6('Dataset 1'),
					div(class='apParamsSummaryDataset',
							f('Raw file:', input$genericRawFile1$name),
							f('Phenodata file:', input$genericPhenoFile1$name),
							f('ID:', input$genericId1),
							f('Synonym is under:', input$genericSyn1)
					),
					h6('Dataset 2'),
					div(class='apParamsSummaryDataset',
							f('Raw file:', input$genericRawFile2$name),
							f('Phenodata file:', input$genericPhenoFile2$name),
							f('ID:', input$genericId2),
							f('Synonym is under:', input$genericSyn2)
					)
				)
			}
		}
	})
	
	##############################################
	# Render UI components for analysis parameters
	##############################################
	output$apHiddenVars <- renderApHiddenVars()
	output$apDialog <- renderApDialog()

	##
	#####################
	
	######################
	## Reactive observers
	
	# Observe if analysis parameters have changed. Validate and run if possible
	observe({
		# Validate and set reactive values
		if(!is.null(input$apConfig) && nchar(input$apConfig) > 0) {
			if(input$apConfig == 'AtMetExpress') {
				clientAp$values = list(
					filePrefix = input$atMetFile
				)
			} else if(input$apConfig == 'MeKO') {
				clientAp$values = list(
					filePrefix = input$mekoFile,
					norm = input$norm
				)
			} else if(input$apConfig == 'GC-MS (RIKEN format)') {
				clientAp$values = list(
					rawFile = input$gcmsRawFile,
					phenoFile = input$gcmsPhenoFile,
					#norm = input$norm,
					std = input$gcmsStd,
					factor = input$gcmsFactor,
					ncomp = input$gcmsNcomp
				)
			}
			else if(input$apConfig == 'Generic') {
				clientAp$values = list(
					dataset1 = list(
						rawFile = input$genericRawFile1,
						phenoFile = input$genericPhenoFile1,
						id = input$genericId1,
						synonym = input$genericSyn1
					),
					dataset2 = list(
						rawFile = input$genericRawFile2,
						phenoFile = input$genericPhenoFile2,
						id = input$genericId2,
						synonym = input$genericSyn2
					)
				)
			}
		}
	})
	
	# Observe if GCMS Phenodata file has changed, parse data, and present headers for factor selection
	observe({
		if(is.null(input$gcmsPhenoFile)) return(NULL)
		headers <- sort(colnames(read.csv(input$gcmsPhenoFile$datapath, header=TRUE, nrows=1, sep=',')))
		updateSelectInput(session, 'gcmsFactor', choices=headers)
	})
	
	# Observe if Generic files have changed, parse data, and present headers for id/synonym selection
	observe({
		if(is.null(input$genericRawFile1)) return(NULL)
		headers <- sort(colnames(read.csv(input$genericRawFile1$datapath, header=TRUE, nrows=1, sep="\t")))
		updateSelectInput(session, 'genericSyn1', choices=headers)
	})
	
	observe({
		if(is.null(input$genericPhenoFile1)) return(NULL)
		headers <- sort(colnames(read.csv(input$genericPhenoFile1$datapath, header=TRUE, nrows=1, sep=',')))
		updateSelectInput(session, 'genericId1', choices=headers)
	})
	
	observe({
		if(is.null(input$genericRawFile2)) return(NULL)
		headers <- sort(colnames(read.csv(input$genericRawFile2$datapath, header=TRUE, nrows=1, sep="\t")))
		updateSelectInput(session, 'genericSyn2', choices=headers)
	})
	
	observe({
		if(is.null(input$genericPhenoFile2)) return(NULL)
		headers <- sort(colnames(read.csv(input$genericPhenoFile2$datapath, header=TRUE, nrows=1, sep=',')))
		updateSelectInput(session, 'genericId2', choices=headers)
	})
})
