
library(shiny)
library(shinyWidgets)
library(flexdashboard)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Cancers of Unknown Primary (CUP) Nomogram"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            radioButtons(inputId = "sex", label = "Sex",
                         choices = c("Male" = "male",
                                     "Female" = "female")),
            sliderTextInput(inputId = "ECOG", label = "ECOG Status",
                        choices = c("0", "1", "2", ">2"), selected = "0", grid = TRUE),
            radioButtons(inputId = "histology", label = "Histology",
                         choices = c("Non-Adenocarcinoma" = "nonadeno",
                                     "Adenocarcinoma" = "adeno")),
            sliderTextInput(inputId = "numsites", label = "Number of Metastatic Sites",
                            choices = c("0","1","2","≥3"), selected = 0, grid = TRUE),
            sliderTextInput(inputId = "nlr", label = "Neutrophil-Lymphocite Ratio (NLR)",
                            choices = c("<5", "≥5"), selected = "<5", grid = TRUE)
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
            gaugeOutput("oneYearSurv"),
            gaugeOutput("twoYearSurv"),
            textOutput("totalPoints")
           
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {


         
  
}

# Run the application 
shinyApp(ui = ui, server = server)
