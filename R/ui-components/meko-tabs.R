library(shiny)

mekoAnalysisTabs <- tags$html(
	tabsetPanel(
		tabPanel('Summary (MVA)',
						 tabsetPanel(
						 	tabPanel('Hierarchical Cluster', 
						 					 selectInput('mekoHcMethod', 'hclust Method',
						 					 						choices = c('Complete', 'Centroid', 'Ward', 'Average',
						 					 												'Single', 'Median')),
						 					 selectInput('mekoDistMethod', 'dist Method',
						 					 						choices = c('Euclidean', 'Maximum', 'Manhattan', 'Canberra',
						 					 												'Binary', 'Minkowski')),
						 					 plotOutput('mekoHCluster')
						 	),
						 	tabPanel('Heat Map',
						 					 selectInput('mekoHcMethod2', 'hclust Method',
						 					 						choices = c('Complete', 'Centroid', 'Ward', 'Average',
						 					 												'Single', 'Median')),
						 					 selectInput('mekoDistMethod2', 'dist Method',
						 					 						choices = c('Euclidean', 'Maximum', 'Manhattan', 'Canberra',
						 					 												'Binary', 'Minkowski')),
						 					 plotOutput('mekoHeatmap')
						 	),
						 	tabPanel('Principal Component Analysis',
						 					selectInput('mekoPcaMethod', 'PCA Method', choices=listPcaMethods(), selected="ppca"),
						 					plotOutput('mekoPCA')
						 	)
						 )
		),
		
		tabPanel('Differential Accumulated Metabolites (UVA)', 
						 tabsetPanel(
						 	tabPanel('Volcano Plot', 
						 					 htmlOutput('mekoMutantList'),
						 					 plotOutput('mekoVolcano')
						 	),
						 	tabPanel('Limma Table', tableOutput('mekoLTable'))
						 )
		)
	)
)
