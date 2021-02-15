# Script Comments ---------------------------------------------------------
# Script for the Cancer of Unknown Primary Nomogram Shiny Application.
# The app takes in input from the users and calculates a total score based on
# the 5 factors, which is used to calculate 1 and 2 year survival.

# Load Necessary Packages & Data -------------------------------------------------

library(shiny)
library(shinyWidgets)
library(flexdashboard)
library(shinydashboard)
library(rms)
library(survival)

# read in model
model <- readRDS("mymodel.rds")

#defining the CSS settings for the Gauge widget
css <- HTML("
.html-widget.gauge svg {
  height: 200px;
  width: 300px;
  
}")
# Defining UI (Front-End) -------------------------------------------------

# Define UI for application. This uses the dashboard layout with a black skin
ui <-dashboardPage(skin = "blue", 
                   
                   # set the title
                   dashboardHeader(title = "Cancers of Unknown Primary Nomogram", titleWidth = 450),
                   
                   # set the input widgets for the sidebar
                   dashboardSidebar(width = 450,
                                    radioButtons(inputId = "sex", label = "Sex",
                                                 choices = c("Female" = "female",
                                                             "Male" = "male")),
                                    sliderTextInput(inputId = "ecog", label = "ECOG Status",
                                                    choices = c("0", "1", "2", ">2"), selected = "0", grid = TRUE, width = 400),
                                    radioButtons(inputId = "histology", label = "Histology",
                                                 choices = c("Non-Adenocarcinoma" = "nonadeno",
                                                             "Adenocarcinoma" = "adeno")),
                                    radioButtons(inputId = "numsites", label = "Number of Metastatic Sites",
                                                 choices = c("<3","≥3")),
                                     numericInput(inputId = "nlr", label = "(NLR) Neutrophil-Lymphocite Ratio  (max is ≥50)", min = 0.0, max = 50.0, value = 1.0, step = 0.1, width = 400)),
                   
                   # set the UI for the main panel 
                   dashboardBody(
                     #use the CSS styling defined above
                     tags$head(tags$style(css)),
                     # intro paragraph
                     h4("Survival estimates can often be challenging for clinicians to provide when 
 seeing patients with cancers of unknown primary.  Here we provide a simple application 
 to estimate 1 and 2 year overall survival rates for patients with cancers of unknown 
 primary, based on 5 well-known and validated prognostic factors."),
                    
                     #line breaks 
                     br(), 
                     br(),
                     
                     # use the fluidrows mechanism to structure outputs
                     # width of screen is 12, so offset & width of 4 is perfectly center
                     # sets UI for the value box and the 2 gauges
                     fluidRow(
                       column(width = 4, offset = 4, 
                              valueBoxOutput("vbox", width = NULL),
                      gaugeOutput("oneYrSurv", width = "100%", height = "100%"), 
                     gaugeOutput("twoYrSurv", width = "100%", height = "100%") 
                     )),
                     
                     # closing paragraph
                     strong("Acknowledgements"),
                     h4("The CUP App is constructed based on a novel nomogram 
                     devised by a team of clinicians and researchers across three 
                     institutions (the MD Anderson Cancer Center, BC Cancer, and 
                     Sarah Cannon Cancer Center). More information about how the 
                     factors were chosen, and performance of the nomogram can be 
                     found here:"),
                     
                     br(),
                    strong("(reference will be inserted when available)"),
                    br(),
                     
                     # logos 
                     img(src = "mdanderson.svg", height = 240, width = 240),
                     img(src = "bccancer.png", height = 120, width = 120),
                     img(src = "sarahcannon.svg", height = 300, width = 300)
                   )
)

# Defining Server (Back-End) ----------------------------------------------

# Define server logic 
server <- function(input, output) {
  
  # sum the inputs from the user
  # switch is used to change the value of each variable depending on user input
  totalSum <- reactive({
    sum(sex <- switch(input$sex,
                      "female" = 0,
                      "male" = 25),
        ECOG <- switch(as.character(input$ecog),
                       "0"  = 0,
                       "1"  = 41,
                       "2"  = 69,
                       ">2" = 100),
        histology <- switch(input$histology,
                            "nonadeno" = 0,
                            "adeno" = 27),
        
        numsites <- switch(input$numsites,
                           "<3" = 0,
                           "≥3" = 31),
        # set max value to 50 for the model
        nlr <- min(input$nlr, 50.0))
  })
  
  # render the value box based on totalSum
  output$vbox <- renderValueBox({
    valueBox(totalSum(), subtitle = "Patient Score", icon = icon("notes-medical"))
  })
  
  # calculates the different survival rates and converts to a percentage
  oneYrSurv <- reactive(exp(-exp(0.0123 * totalSum() - 1.95)) * 100)
  twoYrSurv <- reactive(exp(-exp(0.0123 * totalSum() - 1.09)) * 100)
  
  # output gauge for one year survival. Rounds values and ensures minimum value is 10
  output$oneYrSurv <- renderGauge({
    gauge(min = 0, max = 100, 
          value = round(ifelse(oneYrSurv() < 10,
                               10,
                               oneYrSurv())), 
          symbol = "%", label = "One Year Survival")
  })
  
  # output gauge for two year survival. Rounds values and ensures minimum value is 10
  output$twoYrSurv <- renderGauge({
    
    gauge(min = 0, max = 100, value = round(ifelse(twoYrSurv() < 10,
                                                   10,
                                                   twoYrSurv())), 
          symbol = "%", label = "Two Year Survival")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
