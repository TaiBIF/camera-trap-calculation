assign("nop_ignore_id_action_counter", 0, envir = .GlobalEnv)
assign("nop_action_counter", 0, envir = .GlobalEnv)
assign("poa_action_counter", 0, envir = .GlobalEnv)
assign("fcs_action_counter", 0, envir = .GlobalEnv)
assign("saveFilteredData_action_counter", 0, envir = .GlobalEnv)

server <- shinyServer(function(input, output, session) {
  
  observe({
    input$Project
    #input$Station
    input$since
    input$until
    d_ui = data_filtering(input, context_only = T)
    updateSelectInput(session, "Station", choices = c(unique(d_ui$Station)))
    updateSelectInput(session, "Camera", choices = c(unique(d_ui$Camera)), selected = input$Camera)
    updateSelectInput(session, "Species", choices = c(unique(d_ui$Species)), selected = input$Species)
    updateSelectInput(session, "Sex", choices = c(unique(d_ui$Sex)), selected = input$Sex)
    updateSelectInput(session, "Age", choices = c(unique(d_ui$Age)), selected = input$Age)
    updateSelectInput(session, "ID", choices = c(unique(d_ui$ID)), selected = input$ID)
  })
  
  data_filtered = reactive({
    d_ui = data_filtering(input)
    metaValue = list()
    metaValue$Project = ifelse(is.null(input$Project), NA, input$Project)
    metaValue$Station = ifelse(is.null(input$Station), NA, input$Station)
    metaValue$Camera = ifelse(is.null(input$Camera), NA, input$Camera)
    metaValue$Species = ifelse(is.null(input$Species), NA, input$Species)
    metaValue$since = ifelse(is.null(input$since), NA, input$since)
    metaValue$until = ifelse(is.null(input$until), NA, input$until)
    metaValue$Sex = ifelse(is.null(input$Sex), NA, input$Sex)
    metaValue$Age = ifelse(is.null(input$Age), NA, input$Age)
    metaValue$ID = ifelse(is.null(input$ID), NA, input$ID)
    metaValue$timeLag = ifelse(is.null(input$timeLag), NA, input$timeLag)

    outputXlsx = function (prefix, sheetName, d, inputData) {
      ofn = paste0(prefix, format(Sys.time(), format = '%Y-%m-%d-%H%M%S', tz = 'Asia/Taipei'), ".xlsx")
      dir = "./output"
      # fwrite(x = output_nop_ignore_id, file = paste0(dir, "/", ofn), sep = "\t", row.names = F)
      write.xlsx2(x = d, file = paste0(dir, "/", ofn), sheetName = sheetName, row.names = F)
      # print(inputData)
      write.xlsx2(x = inputData, file = paste0(dir, "/", ofn), sheetName = "Meta", row.names = F, append = T)
      write.xlsx2(x = d_ui, file = paste0(dir, "/", ofn), sheetName = "Data", row.names = F, append = T)      
    }
    
    # number of photos, group by species, id ignored
    if (!is.null(input$nop_ignore_id)) {
      if (input$nop_ignore_id > 0 & input$nop_ignore_id != nop_ignore_id_action_counter) {
        assign("nop_ignore_id_action_counter", input$nop_ignore_id, envir = .GlobalEnv)
        d_ui_nop_ignore_id_tmp = d_ui[order(Project, Station, Camera, Species, unix_datetime)]
        output_nop_ignore_id = d_ui_nop_ignore_id_tmp[, nop(.SD, NMinute = 30, ignoreIdv = T), by=c('Project', 'Station', 'Camera', 'Species')]
        print(output_nop_ignore_id)
        outputXlsx(prefix = "NOP_ID_IGNORED_", sheetName = "NumberOfPhotosIgnoreID", output_nop_ignore_id, as.data.frame(metaValue))
      }
    }

    # number of photos, group by individual
    if (!is.null(input$nop)) {
      if (input$nop > 0 & input$nop != nop_action_counter) {
        assign("nop_action_counter", input$nop, envir = .GlobalEnv)
        d_ui_nop_tmp = d_ui[order(Project, Station, Camera, Species, unix_datetime)]
        output_nop = d_ui_nop_tmp[, nop(.SD, NMinute = 30, ignoreIdv = F), by=c('Project', 'Station', 'Camera', 'Species', 'ID')]
        print(output_nop)
        outputXlsx(prefix = "NOP_GROUP_BY_ID_", sheetName = "NumberOfPhotosWithID", output_nop, as.data.frame(metaValue))
      }
    }
    
    if (!is.null(input$poa)) {
      if (input$poa > 0 & input$poa != poa_action_counter) {
        assign("poa_action_counter", input$poa, envir = .GlobalEnv)
        d_ui_poa_tmp = d_ui[order(Project, Station, Camera, Species, unix_datetime)]
        output_poa = d_ui_poa_tmp[, poa(.SD), by=c('Project', 'Station', 'Camera', 'Species')]
        print(output_poa)
        outputXlsx(prefix = "PRESENCE_OR_ABSENCE_", sheetName = "PresenceOrAbsence", output_poa, as.data.frame(metaValue))
      }
    }

    if (!is.null(input$fcs)) {
      if (input$fcs > 0 & input$fcs != fcs_action_counter) {
        assign("fcs_action_counter", input$fcs, envir = .GlobalEnv)
        d_ui_fcs_tmp = d_ui[order(Project, Station, Camera, Species, unix_datetime)]
        output_fcs = d_ui_fcs_tmp[, fcs(.SD, input$since), by=c('Project', 'Station', 'Camera', 'Species')]
        print(output_fcs)
        outputXlsx(prefix = "FIRST_CAPTURE_SINCE_", sheetName = "FirstCapture", output_fcs, as.data.frame(metaValue))
      }
    }
    
    if (!is.null(input$saveFilteredData)) {
      if (input$saveFilteredData > 0 & input$saveFilteredData != saveFilteredData_action_counter) {
        assign("saveFilteredData_action_counter", input$saveFilteredData, envir = .GlobalEnv)
        fwrite(x = d_ui, file = "./output/filtered_data.csv", sep = "\t", row.names = F)
      }
    }

    d_ui
  })
  
  output$tbl <- renderDataTable(data_filtered(), options = list(server = T, lengthMenu = c(10, 50, 100), pageLength = 10))
  
  
})
