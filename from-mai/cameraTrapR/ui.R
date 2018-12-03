ui <- shinyUI(fluidPage(
  fluidRow(
    column(3,
          selectInput('Project', 'Project', c(unique(data_to_analyze$Project)), multiple = F),
          fluidRow(
            column(6, selectInput('Station', 'Station', c(unique(data_to_analyze$Station)), multiple = F)),
            column(6, selectInput('Camera', 'Camera', c(unique(data_to_analyze$Camera)), multiple = T)),
            column(6, dateInput("since", "Since", value = min(data_to_analyze$DateTime))),
            column(6, dateInput("until", "Until", value = max(data_to_analyze$DateTime)))
          ),
            selectInput('Species', 'Species', c(unique(data_to_analyze$Species)), multiple = T),
          fluidRow(
            column(6, selectInput('Sex', 'Sex', c(unique(data_to_analyze$Sex)), multiple = T)),
            column(6, selectInput('Age', 'Age', c(unique(data_to_analyze$Age)), multiple = T)),
            column(6, selectInput('ID', 'ID', c(unique(data_to_analyze$ID)), multiple = T)),
            column(6, numericInput('timeLag', 'Time Lag (s)', 30 * 60, min = 30, max = NA, step = 30))
          ),
          fluidRow(
            column(12, actionButton('nop_ignore_id', 'Number Of Photos, IDs ignored')),
            column(12, actionButton('nop', 'Number Of Photos, IDs considered')),
            column(12, actionButton('poa', 'Presence or absence')),
            column(12, actionButton('fcs', 'First capture since')),
            column(12, actionButton('saveFilteredData', 'Save Filtered Data'))
          )
    ),
    column(8,
           fluidRow(
             column(12, dataTableOutput('output_nop')),
             column(12, dataTableOutput('tbl'))
           )
    )
  )
  
))
