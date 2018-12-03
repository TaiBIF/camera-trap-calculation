#install.packages("data.table")
library(data.table)
#install.packages("shiny")
library(shiny)
#install.packages("xlsx")
#library(xlsx)
#install.packages("rJava")
#library(rJava)

#### 載入資料 ####
from_old_database = T
data_to_analyze = NULL

if (from_old_database) {
  csv_files = c("./data/photo.csv")

  for (csv in csv_files) {
    data_tmp = fread(csv, encoding="UTF-8", na.strings = c("", "NA"))
    data_to_analyze = rbind(data_to_analyze, data_tmp)
  }
  
  # for data from old database
  data_to_analyze = data_to_analyze[, c('project', 'station', 'camera_id', 'filename', 'p_date', 'note', 'sex', 'age', 'identity', 'num')]
  names(data_to_analyze) = c('Project', 'Station', 'Camera', 'FileName', 'DateTime', 'Species', 'Sex', 'Age', 'ID', 'IdvCount')
  
} else {
  csv_files = list.files(path="./data", pattern = "*.csv|*.txt", ignore.case = T, recursive = T, full.names = T)
  #csv_files = c("./data/aaa.txt")
  csv_files = csv_files[1:2]
  for (csv in csv_files) {
    data_tmp = fread(csv, encoding="UTF-8", na.strings = c("", "NA"))
    data_to_analyze = rbind(data_to_analyze, data_tmp)
  }
}

data_to_analyze[, unix_datetime := as.numeric(as.POSIXct(DateTime))]
data_to_analyze[is.na(IdvCount), IdvCount:=1]

data_to_analyze$IdvCount = as.numeric(data_to_analyze$IdvCount)

source("function_data_filtering.R", encoding = "UTF-8")
source("function_nop.R", encoding = "UTF-8")
source("function_poa.R", encoding = "UTF-8")
source("function_fcs.R", encoding = "UTF-8")
source("ui.R", encoding = "UTF-8")
source("server.R", encoding = "UTF-8")

shinyApp(ui = ui, server = server)

#debug(nop)
