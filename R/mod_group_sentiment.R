#'  group_sentiment UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_group_sentiment_ui <- function(id){
  ns <- NS(id)
  tagList(
    shiny::fluidRow(
      shiny::sidebarLayout(
      shiny::sidebarPanel(
        width = 2,
        shiny::sliderInput(
          inputId = ns("height"),
          "Height",
          min = 100, max = 800,
          value = 400,
          step = 50
        ),
        shiny::sliderInput(
          inputId = ns("width"),
          "Width",
          min = 100,
          max = 800,
          value = 400,
          step = 50
        ),
        shiny::selectInput(
          inputId = ns("groupVarSent"),
          label = "Select your grouping variable",
          choices = NULL
        ),
        shiny::selectInput(
          inputId = ns("chartType"),
          label = "Select chart type",
          choices = c("volume", "percent"),
          selected = "percent",
          multiple = FALSE
        ),
        shiny::selectInput(
          inputId = ns("labelsType"),
          label = "Select bar labels type",
          choices = c("none", "volume", "percent"),
          selected = "none",
          multiple = FALSE
        ),
        mod_reactive_labels_ui(ns("groupSentimentTitles")),
        shiny::downloadButton(
          outputId = ns("saveGroupSentiment"),
          class = "btn btn-warning"
        ),
      ),
      shiny::mainPanel(
        width = 6,
        shinycssloaders::withSpinner(
          shiny::plotOutput(
            outputId = ns("groupSentimentPlot"),
            height = "450px",
            width = "450px"))
      )
    )
    )
    )
}

#' group_sentiment Server Functions
#' @param id The module id
#' @param highlighted_dataframe The highlighted dataframe in app.server
#'
#' @noRd
mod_group_sentiment_server <- function(id, highlighted_dataframe){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    observe({
      shiny::updateSelectInput(session,
                               inputId = "groupVarSent",
                               choices = colnames(highlighted_dataframe()),
                               selected = colnames(highlighted_dataframe())[3]
      )
    })

    group_sentiment_titles <- mod_reactive_labels_server("groupSentimentTitles")

    group_sent_reactive <- reactive({
       if(nrow(highlighted_dataframe()) < 1){
        validate("You must select data first to view a grouped sentiment plot")}

        group_sent_plot <- highlighted_dataframe() %>%
        LandscapeR::ls_plot_group_sent(
          # group_var = cluster,
          group_var = input$groupVarSent,
          # group_var = .data[[input$groupVarSent]],
                                       sentiment_var = sentiment,
                                       type = input$chartType,
                                       bar_labels = input$labelsType)

        group_sent_plot <- group_sent_plot +
          group_sentiment_titles$labels()

        return(group_sent_plot)
    })

    # now create the server's output for display in app
    output$groupSentimentPlot <-
      shiny::renderPlot({
        group_sent_reactive()
      },
      res = 100,
      width = function() input$width,
      height = function() input$height
    )

    # Download button
    output$saveGroupSentiment <- LandscapeR::download_box(
      plot = group_sent_reactive(),
      exportname = "group_sentiment_plot",
      width = input$width,
      height = input$height
      )

  })
}

## To be copied in the UI
# mod_group_sentiment_ui("group_sentiment_1")

## To be copied in the server
# mod_group_sentiment_server("group_sentiment_1")
