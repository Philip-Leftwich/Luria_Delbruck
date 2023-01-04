# libraries ----
suppressPackageStartupMessages({
  library(shiny)
  library(shinydashboard)
  library(shinycssloaders)
#  library(plotly)
#  library(gganimate)
#  library(gifski)
})

# functions ----
source("scripts/LD_function.R")
source("scripts/plot_LD.R")
source("scripts/plot_plates_spreading.R")
# user interface ----


## UI ----
ui <- dashboardPage(
#  skin = "purple",
  dashboardHeader(title = "Luria-Delbruck Fluctuation Assay"),
  dashboardSidebar(disable = FALSE,
                   sliderInput("generations", "Number of generations", min = 5, max = 40, step = 5, value = 30),
                   sliderInput("mu", "Mutation rate", min = 1, max = 10, step = 1, value = 1),
                   checkboxInput("Log", "Log10", value = FALSE, width = NULL),
                   actionButton("reset", "Reset")),
  dashboardBody(
    p("This app simulates data from a Luria-Delbrück Fluctuation assay. 
    In this procedure bacteria are allowed to grow under non-selective conditions and the number of mutants that accumulate in a defined target gene within that time period is determined.
    In this example we are simulating the accumulation of spontaneous Rifampicin resistant mutants.
    You can set the number of generations the bacteria are allowed to grow for, and the mutation rate of the bacteria in the sidebar. 
    The check box allows you to plot growth on a linear or log10 scale."),
    tabsetPanel(
    tabPanel("Luria Delbruck Growth", 
             plotOutput("linebox") %>% withSpinner(color="#0dc5c1"), 
          p("Left) the total number of bacteria growing in liquid culture, Right) the number of spontaneous Rif-resistant mutants")),
      
  tabPanel("LB Plate growth", 
           plotOutput("violinbox") %>% withSpinner(color="#0dc5c1"), 
         p("Left) the expected number of Colony Forming Units from 100ul plated on Rifampicin Antibiotic selective media. Right) the expected number of Colony Forming Units from 100ul plates on non-selective Plates")),
  
  tabPanel("Data",
           DT::dataTableOutput("demo_datatable"))
),
actionButton("rerun", "Re-run Simulation")
)
)


# server ----
server <- function(input, output, session) {
  # reset values
  observeEvent(input$reset, {
    updateSliderInput(session, "mu", value = 1)
    updateSliderInput(session, "generations", value = 30)
   
  })
    data <- reactive({
    input$rerun
    total_cultures(generations = input$generations, mu = input$mu, log = input$Log)
  })

 
 # Line plot
    
  output$linebox <- renderPlot({
    plot_LD(data())
  })
    
 #   renderImage({
      # A temp file to save the output.
      # This file will be removed later by renderImage
 #     outfile <- tempfile(fileext='.gif')
      
#    plot_LD(data())
#    list(src = "new.gif",
#         contentType = 'image/gif',
#          width = "90%",
#          height = "90%"
#         # alt = "This is alternate text"
#    )}, deleteFile = TRUE)

#   LB plates
  
  output$violinbox <- renderPlot({
  plot_plate(data())
  })
  
  # datatable ----
  output$demo_datatable <- DT::renderDataTable({
    data() %>% 
      mutate(`resistant` = n_resistant+n_mutants) %>% 
      mutate(`total` = n_susceptible + `resistant`) %>% 
      filter(generation == max(generation)) %>% 
      select(-generation, -transformation, -n_resistant, -n_mutants, -n_susceptible)
  }, options = list(pageLength = 10),
  rownames = FALSE)
  
} 
 

shinyApp(ui, server)