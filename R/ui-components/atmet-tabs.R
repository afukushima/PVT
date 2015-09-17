library(shiny)

atMetAnalysisTabs <- tags$html(
	tabsetPanel(
		tabPanel('Summary (MVA)',
						 tabsetPanel(
						 	tabPanel('Hierarchical Cluster', 
						 					 selectInput('atMetHcMethod', 'hclust Method',
						 					 						choices = c('Complete', 'Centroid', 'Ward', 'Average',
						 					 												'Single', 'Median')),
						 					 selectInput('atMetDistMethod', 'dist Method',
						 					 						choices = c('Euclidean', 'Maximum', 'Manhattan', 'Canberra',
						 					 												'Binary', 'Minkowski')),
						 					 selectInput('atMetScalingMethod', 'scaling Method',
						 					 						choices = c('auto', 'range', 'pareto', 'vast',
						 					 												'level', 'power')),
						 					 plotOutput('atMetHCluster')
						 	),
						 	tabPanel('Heat Map',
						 					 selectInput('atMetHcMethod2', 'hclust Method',
						 					 						choices = c('Complete', 'Centroid', 'Ward', 'Average',
						 					 												'Single', 'Median')),
						 					 selectInput('atMetDistMethod2', 'dist Method',
						 					 						choices = c('Euclidean', 'Maximum', 'Manhattan', 'Canberra',
						 					 												'Binary', 'Minkowski')),
						 					 selectInput('atMetScalingMethod2', 'scaling Method',
						 					 						choices = c('auto', 'range', 'pareto', 'vast',
						 					 												'level', 'power')),
						 					 plotOutput('atMetHeatmap')
						 	),
						 	tabPanel('Principal Component Analysis',
						 					 selectInput('atMetPcaMethod', 'PCA Method', choices=listPcaMethods(), selected="ppca"),
						 					 plotOutput('atMetPCA')
						 	)
						 )
		)
	)
)
