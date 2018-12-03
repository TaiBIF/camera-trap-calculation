poa = function (orig_dt) {
  #orig_dt = data_to_analyze
  if (!(nrow(orig_dt) > 0)) return (NA)
  dt = copy(orig_dt)
  dateHour = format(as.POSIXct(dt$DateTime), format="%Y-%m-%d %H")
  dateHour = unique(dateHour)
  dateAndHour = tstrsplit(dateHour, split = ' ')
  date_ = dateAndHour[[1]]
  hours = dateAndHour[[2]]
  hours_count = table(hours)
  
  dateHour.dt = data.table(date = date_, hour = hours)

  full_hours_count_ = rep(0L, 24L)
  full_hours = c("00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23")

  dummy_date = rep("0000-00-00", 24)
  dummy_hour = full_hours
  dummy_dateHour = data.table(date = dummy_date, hour = dummy_hour)
  
  dateHour.dt = rbind(dateHour.dt, dummy_dateHour)
  res_ = dcast(dateHour.dt, formula = date ~ hour, fun.aggregate = length, value.var = c('hour'))
  res_[-1,]
  
}
