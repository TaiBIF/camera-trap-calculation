# depend on data_to_analyze
data_filtering = function (input, context_only = F) {
  
  d_ui = copy(data_to_analyze)
  
  since = as.numeric(as.POSIXct(paste0(input$since, " 00:00:00")))
  until = as.numeric(as.POSIXct(paste0(input$until, " 23:59:59")))
  d_ui = d_ui[unix_datetime >= since & unix_datetime <= until]  
  
  project = NULL
  if (is.null(input$Project)){
    # do nothing
  } else if ('all' %in% input$Project) {
    # do nothing
  } else {
    project = input$Project
  }
  
  if (!is.null(project)) {
    project[project=='NA'] = NA
    d_ui = d_ui[Project %in% project, ]
  } else {
    # do nothing
  }

  if (context_only) return (d_ui)
    
  station = NULL
  if (is.null(input$Station)){
    # do nothing
  } else if ('all' %in% input$Station) {
    # do nothing
  } else {
    station = input$Station
  }
  if (!is.null(station)) {
    station[station=='NA'] = NA
    d_ui = d_ui[Station %in% station, ]
  } else {
    # do nothing
  }

  camera = NULL
  if (is.null(input$Camera)){
    # do nothing
  } else if ('all' %in% input$Camera) {
    # do nothing
  } else {
    camera = input$Camera
  }
  if (!is.null(camera)) {
    camera[camera=='NA'] = NA
    d_ui = d_ui[Camera %in% camera, ]
  } else {
    # do nothing
  }
  
  species = NULL
  if (is.null(input$Species)){
    # do nothing
  } else if ('all' %in% input$Species) {
    # do nothing
  } else {
    species = input$Species
  }
  if (!is.null(species)) {
    species[species=='NA'] = NA
    d_ui = d_ui[Species %in% species, ]
  } else {
    # do nothing
  }
  
  sex = NULL
  if (is.null(input$Sex)){
    # do nothing
  } else if ('all' %in% input$Sex) {
    # do nothing
  } else {
    sex = input$Sex
  }
  if (!is.null(sex)) {
    sex[sex=='NA'] = NA
    d_ui = d_ui[Sex %in% sex, ]
  } else {
    # do nothing
  }
  
  age = NULL
  if (is.null(input$Age)){
    # do nothing
  } else if ('all' %in% input$Age) {
    # do nothing
  } else {
    age = input$Age
  }
  if (!is.null(age)) {
    age[age=='NA'] = NA
    d_ui = d_ui[Age %in% age, ]
  } else {
    # do nothing
  }
  
  id = NULL
  if (is.null(input$ID)){
    # do nothing
  } else if ('all' %in% input$ID) {
    # do nothing
  } else {
    id = input$ID
  }
  if (!is.null(id)) {
    id[id=='NA'] = NA
    d_ui = d_ui[ID %in% id, ]
  } else {
    # do nothing
  }
  
  return (d_ui)
}
