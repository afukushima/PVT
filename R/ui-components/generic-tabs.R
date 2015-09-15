library(shiny)

genericAnalysisTabs <- tags$html(
	tabsetPanel(
		tabPanel('Summary (MVA)',
			sliderInput('genericThresh', 'Threshold', 
				0, 1, 0.50, step = 0.01),
			tabsetPanel(
				tabPanel('Hierarchical Cluster',
					selectInput('genericHCMethod', 'hclust Method',
					 	choices = c('Complete', 'Centroid', 'Ward', 'Average',
					 		'Single', 'Median')),
					selectInput('genericDistMethod', 'dist Method',
					 	choices = c('Euclidean', 'Maximum', 'Manhattan', 'Canberra',
					 		'Binary', 'Minkowski')),
					plotOutput('genericHCluster')
					),
				tabPanel('Heat Map',
					selectInput('genericHCMethod2', 'hclust Method',
						choices = c('Complete', 'Centroid', 'Ward', 'Average',
					 		'Single', 'Median')),
					 selectInput('genericDistMethod2', 'dist Method',
					 	choices = c('Euclidean', 'Maximum', 'Manhattan', 'Canberra',
					 		'Binary', 'Minkowski')),
					 plotOutput('genericHeatmap')
					),
				tabPanel('Principal Component Analysis', 
					selectInput('genericPcaMethod', 'PCA Method', choices=listPcaMethods(), selected="ppca"),
					plotOutput('genericPCA')
					)
				)
			),
		tabPanel('Data (expressionSet)',
			selectInput('genericExprSet', '', choices = c('Dataset 1', 'Dataset 2')),
			tabsetPanel(
				tabPanel('Feature data', tableOutput('genericFData')),
				tabPanel('Phenotypical data', tableOutput('genericPData'))
				)
			)
		)
	)

