library(shiny)

##########
# MeKO APs
##########
apAtMet <- tags$html(
	tags$p('We integrated multiple metabolome datasets in Arabidopsis 
				  and constructed our database, called 
				 AtMetExpress, to store the information. The integrated data 
				 analyses showed that Arabidopsis has ~1,200 metabolites, which 
				 we can detect using mass spectrometry-based metabolite 
				 profiling.'),
	tags$hr(),
	selectInput('atMetFile', 'Dataset', choices = atMetFileList)
)

##########
# MeKO APs
##########
apMeKO <- tags$html(
	tags$p('MeKO collects information and 
				 maintains a database of metabolomic data 
				 for Arabidopsis thaliana, a widely used 
				 model plant. Data are based on gas 
				 chromatography-time-of-flight/mass 
				 spectrometry (GC-TOF/MS). MeKO contains 
				 50 mutant lines.'),
	tags$hr(),
	selectInput('mekoFile', 'Dataset', choices = mekoFileList),
	selectInput('norm', 'Normalization Method', choices = c('CRMN', 'One'))
	)


##########
# GCMS APs
##########
apGCMS <- tags$html(
	fileInput('gcmsRawFile', 'Raw data (TSV):'), #accept=c('text/plain')),
	fileInput('gcmsPhenoFile', 'Phenodata (CSV):'), #accept=c('text/csv', 'text/comma-separated-values', 'text/plain')),
	textInput('gcmsStd', 'Internal standard', 'Hexadecanoate_13C4'),
	selectInput('gcmsFactor', 'Factors (to select multiple factors, hold Ctrl while clicking selections)', choices=c(''), multiple=TRUE),
	numericInput('gcmsNcomp', 'No. of components', 2, min=1)
)

#############
# Generic APs
#############
apGeneric <- tags$html(
	div(class='ui-state-highlight ui-corner-all',
			p(span(class='ui-icon ui-icon-info'),
				strong('Note: '),
				span('MeKO assumes generic data to be normalized prior to upload.
						 Please check your data to ensure accurate results.')
				)
			),
	tabsetPanel(
		tabPanel('Dataset 1',
						 fileInput('genericRawFile1', 'Raw data (TSV):'), #accept=c('text/plain')),
						 fileInput('genericPhenoFile1', 'Phenodata (CSV):'), #accept=c('text/csv', 'text/comma-separated-values', 'text/plain')),
						 selectInput('genericId1', 'ID', choices=c('')),
						 selectInput('genericSyn1', 'Synonym is under', choices=c(''))
		),
		tabPanel('Dataset 2',
						 fileInput('genericRawFile2', 'Raw data (TSV):'), #accept=c('text/plain')),
						 fileInput('genericPhenoFile2', 'Phenodata (CSV):'), #accept=c('text/csv', 'text/comma-separated-values', 'text/plain')),
						 selectInput('genericId2', 'ID', choices=c('')),
						 selectInput('genericSyn2', 'Synonym is under', choices=c(''))
		)
	)
	)

################################
# Editor for analysis parameters
################################
renderApDialog <- function() {
	renderUI({
		tags$html(
			h4('Select data source'),
			div(id='apErrorBox',
					class='errorbox hidden ui-state-error ui-corner-all',
					p(span(class='ui-icon ui-icon-alert'),
						strong('Alert: '),
						span(id='message', 'Error message')
					)
			),
			tabsetPanel(id='apTabset',
									tabPanel('AtMetExpress',
													 apAtMet
									),
									tabPanel('MeKO',
													 apMeKO
									),
									tabPanel('GC-MS (RIKEN format)',
													 apGCMS
									),
									tabPanel('Generic',
													 apGeneric
									)
			)
		)
	})
}


##############################################
# Hidden form elements for analysis parameters
##############################################
renderApHiddenVars <- function() {
	renderUI({
		tags$html(
			div(class='hidden',
					textInput('apConfig', 'Config')
			)
		)
	})
}
