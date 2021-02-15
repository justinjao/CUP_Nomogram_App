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
css <- HTML(
".html-widget.gauge svg {
  height: 200px;
  width: 300px;
  }",
".main-sidebar { font-size: 20px; }",
".irs-grid-text { font-size: 20px; }")
# Defining UI (Front-End) -------------------------------------------------

# Define UI for application. This uses the dashboard layout with a black skin
ui <-dashboardPage(skin = "blue", 
                   
                   # set the title
                   dashboardHeader(title = "Cancers of Unknown Primary Nomogram", titleWidth = 450),
                   
                   # set the input widgets for the sidebar
                   dashboardSidebar(width = 450,
                                    radioButtons(inputId = "sex", label = "Sex",
                                                 choices = c("Female" = "Female",
                                                             "Male" = "Male")),
                                    sliderTextInput(inputId = "ecog", label = "ECOG Status", hide_min_max = TRUE,
                                                    choices = c("0", "1", "2", "> 2"), selected = "0", grid = TRUE, width = 400),
                                    radioButtons(inputId = "histology", label = "Histology",
                                                 choices = c("Non-Adenocarcinoma" = "Non-Adenoca",
                                                             "Adenocarcinoma" = "Adenoca")),
                                    radioButtons(inputId = "numsites", label = "Number of Metastatic Sites",
                                              choiceNames = c("<3", "≥3"),  choiceValues = c("< 3",">= 3")), ##going to have to fix this
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
                              # commented out as no longer necessary for now
                            #  valueBoxOutput("vbox", width = NULL),
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
  
  # reads user data and stores it in a dataframe
  
  userData <- reactive({
    df <- NULL
    df$gender = input$sex
        df$ecog.cat = as.character(input$ecog)
        df$hist.cat = input$histology
        # set max value to 50 for the model
        df$nlr = min(input$nlr, 50.0)
          
        df$number.of.sites.bin = input$numsites
    df <- as.data.frame(df)
  })
  
  # render the value box based on totalSum - no longer necessary but kept for now in
  # case we may want to bring it back
  # output$vbox <- renderValueBox({
   # valueBox(totalSum(), subtitle = "Patient Score", icon = icon("notes-medical"))
  ## })
  
  # calculates the different survival rates and converts to a percentage
  oneYrSurv <- reactive(survest(model, newdata=userData(), time=1)$surv * 100)
  twoYrSurv <- reactive(survest(model, newdata=userData(), time=2)$surv * 100)
  
  # output gauge for one year survival. Rounds values and ensures minimum value is 10
  output$oneYrSurv <- renderGauge({
    gauge(min = 0, max = 100, 
          value = round(ifelse(oneYrSurv() < 1,
                               1,
                               oneYrSurv())), 
          symbol = "%", label = "One Year Survival")
  })
  
  # output gauge for two year survival. Rounds values and ensures minimum value is 10
  output$twoYrSurv <- renderGauge({
    
    gauge(min = 0, max = 100, value = round(ifelse(twoYrSurv() < 1,
                                                   1,
                                                   twoYrSurv())), 
          symbol = "%", label = "Two Year Survival", gaugeSectors(warning = c(0,100)))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
