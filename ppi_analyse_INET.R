function(){
	library(shiny)
	library(shinythemes)
	library(shinyjs)
	library(RLumShiny)

	ui <- fluidPage(theme = shinytheme("united"),  useShinyjs(), 
	  sidebarLayout(
	    sidebarPanel(
	      tabsetPanel(id = "tabset",
		tabPanel("PPIN3",
			actionButton("filter!","Go!")
		),
		tabPanel("Piriformospora",
			actionButton("filter!","Go!")
		)
	      )
	    ),
	    mainPanel(
	    	useShinyjs(),
	    	plotOutput(outputId = "plot", width = "100%")
	    )
	  )
	)

	server <- function(input, output, session){
	  v <- reactiveValues(doPlot = FALSE, A=0)
	}
	shinyApp(ui, server)
}
