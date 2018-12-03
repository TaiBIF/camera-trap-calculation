fcs = function (orig_dt, since) {
  hour_seconds = 60 * 60
  day_seconds = hour_seconds * 24
  if (!(nrow(orig_dt) > 0)) return (NA)
  dt = copy(orig_dt)
  since = as.numeric(as.POSIXct(paste0(since, " 00:00:00")))
  min_unix_datetime = min(dt$unix_datetime)
  list(seconds = min_unix_datetime - since, hours = (min_unix_datetime - since) %/% hour_seconds, days = (min_unix_datetime - since) %/% day_seconds)
}