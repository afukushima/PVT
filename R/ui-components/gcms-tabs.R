library(shiny)

gcmsAnalysisTabs <- tags$html(
	tabsetPanel(
		tabPanel('Principal Component Analysis',
			selectInput('gcmsPcaNorm', 'Normalization',
				c('None', 'CRMN', 'One')),
			conditionalPanel(
				condition = 'input.gcmsPcaNorm == "CRMN" || input.gcmsPcaNorm == "One"',
				sliderInput('gcmsThresh', 'Threshold', 
					0, 1, 0, step = 0.01)
				),
			selectInput('gcmsPcaMethod', 'PCA Method', choices=listPcaMethods(), selected="ppca"),
			plotOutput('gcmsPCA')
			),
		tabPanel('Data (expressionSet)',
			tabsetPanel(
				tabPanel('Feature data', tableOutput('gcmsFData')),
				tabPanel('Phenotypical data', tableOutput('gcmsPData'))
				)
			)
		)
	)