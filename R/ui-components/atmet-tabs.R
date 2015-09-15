library(shiny)

atMetAnalysisTabs <- tags$html(
#atMetAnalysisTabs <- #mainPanel(
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
						  ),
						 	tabPanel('Correlation Network Analysis',
						 	         
						 	         # Load d3.js
						 	         tags$head(
						 	           tags$script(src = 'http://d3js.org/d3.v3.min.js')
						 	         ),
						 	         
						 	         # Sidebar with a slider input for node opacity
						 	         fixedRow(
						 	           fixedRow(
						 	             column(3, offset=1,
						 	                    selectInput(inputId='corrMethod', label = 'Correlation method',
						 	                                choices = c('pearson', 'spearman', 'kendall'),
						 	                                width = "40%"
						 	                    )
						 	             ),
						 	             column(3,
						 	                    selectInput(inputId='sel_fontsize', label = 'Font size',
						 	                                choices = c(8,10,12,14,16,18,20,24),
						 	                                selected= 12,
						 	                                width = "25%"
						 	                    )
						 	             ),
						 	             column(3,
						 	                    sliderInput(inputId='sld_corr', label = 'Correlation coefficient',
						 	                                min = -1, max = 1, step = 0.05, value = 0.5
						 	                    )
						 	             ),
						 	             column(3, offset=1,
						 	                    sliderInput(inputId='sld_opc', label = 'Node opacity',
						 	                                min = 0, max = 1, step = 0.01, value = 0.9
						 	                    ) 
						 	             ),
						 	             column(3,
						 	                    sliderInput(inputId='sld_charge', label = 'Link charge',
						 	                                min = -500, max = -10, step = 10, value = -200
						 	                    )
						 	             )
						 	           ),
						 	           hr(),
						 	           # Show network graph
						 	           #fixedRow(
						 	             #column(12,
						 	                    htmlOutput('atMetNetworkPlot')
						 	             #)
						 	           #)
						 	         )
              )
	)
)
