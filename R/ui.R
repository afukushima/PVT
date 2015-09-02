library(shiny)

source('ui-components/atmet-tabs.R', local=TRUE)
source('ui-components/meko-tabs.R', local=TRUE)
source('ui-components/gcms-tabs.R', local=TRUE)
source('ui-components/generic-tabs.R', local=TRUE)

shinyUI(
	pageWithSidebar(
		headerPanel('PRIMe Visualization Tools', 'PRIMe Visualizer'),
		
		sidebarPanel(
			tagList(
				singleton(
					tags$head(
						includeCSS("www/css/smoothness/jquery-ui-1.10.3.custom.min.css"),
						includeCSS("www/css/custom.css"),
						
						includeScript("www/js/jquery-ui-1.10.3.custom.min.js"),
						includeScript("www/js/scripts.js")
					)
				)
			),
			tags$p(id='about',
						 'RIKEN PRIMe provides web-based data analysis and visualization 
						 tools for public access. Users may analyze datasets from both 
						 AtMetExpress and MeKO, as well as upload custom datasets.'),
			tags$hr(),
			h5('Analysis parameters'),
			uiOutput('apParamsSummary'),
			h5('Downloads'),
			conditionalPanel(
				condition = 'input.apConfig !== "MeKO" & input.apConfig !== "GC-MS (RIKEN format)" & input.apConfig !== "Generic"',
				p('None')
				),
			conditionalPanel(
				condition = 'input.apConfig === "MeKO"',
				uiOutput('mekoDownloads')
				),
			conditionalPanel(
				condition = 'input.apConfig === "GC-MS (RIKEN format)"',
				uiOutput('gcmsDownloads')
				),
			conditionalPanel(
				condition = 'input.apConfig === "Generic"',
				uiOutput('genericDownloads')
				),
			tags$hr(),
			actionButton('openApEditor', 'Edit parameters')
		),
		
		mainPanel(
			uiOutput('apHiddenVars'),
			uiOutput('apDialog'),
			
			conditionalPanel(
				condition = 'input.apConfig !== "AtMetExpress" & input.apConfig !== "MeKO" & input.apConfig !== "GC-MS (RIKEN format)" & input.apConfig !== "Generic"',
				class='ui-state-highlight',
				tags$p('To begin, edit the analysis parameters by clicking the button on the left')
			),
			conditionalPanel(
				condition = 'input.apConfig === "AtMetExpress"',
				atMetAnalysisTabs
			),
			conditionalPanel(
				condition = 'input.apConfig === "MeKO"',
				mekoAnalysisTabs
			),
			conditionalPanel(
				condition = 'input.apConfig === "GC-MS (RIKEN format)"',
				gcmsAnalysisTabs
			),
			conditionalPanel(
				condition = 'input.apConfig === "Generic"',
				genericAnalysisTabs
			)
		)
	)
)
