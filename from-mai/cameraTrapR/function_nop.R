#### 定義計算公式 ####
nop = function (orig_dt, NMinute = 30, ignoreIdv = F) {
  
  if (!(nrow(orig_dt) > 0)) return (NA)
  
  dt = copy(orig_dt)
  dt[, dt_diff := c(0, diff(dt$unix_datetime))]

  dt[, file_id := paste0(FileName, "-", unix_datetime)]
  perFileSpeciesIdvCount = dt[, list(sumIdvCount = sum(IdvCount)), by=c('file_id')]
  # print(perFileSpeciesIdvCount)
  
  SecOfNMinute = NMinute * 60
  
  agg_lt_SecOfNMinute = 0
  n_mins_id_pool = NULL
  n_mins_max_idv_count = 1
  prev_file_id = ""
  
  file_idv_pool = NULL
  nop_ = 0

  print(dt$DateTime[1])
    
  for (di in 1:length(dt$dt_diff)) {
    
    d = dt$dt_diff[di]
    agg_lt_SecOfNMinute = agg_lt_SecOfNMinute + d

    if (agg_lt_SecOfNMinute > SecOfNMinute) {
      # reset and output
      print(n_mins_id_pool)
      print(n_mins_max_idv_count)
      print(dt$DateTime[di])
            
      if (!ignoreIdv) {
        nop_ = nop_ + length(n_mins_id_pool)
      } else {
        nop_ = nop_ + n_mins_max_idv_count
      }
      
      n_mins_max_idv_count = 1
      agg_lt_SecOfNMinute = 0
      n_mins_id_pool = NULL
    }
    
    file_id_ = dt$file_id[di]
    if (file_id_ != prev_file_id) {
      n_mins_max_idv_count = max(perFileSpeciesIdvCount[file_id == file_id_, 'sumIdvCount'], n_mins_max_idv_count)
      file_idv_pool = NULL
      sno = 1
    }
    prev_file_id = file_id_
    
    # 設定個體判斷依據
    if (!"ID" %in% colnames(dt)) {
      # 不計個體
      id = "Ignored"
    }
    else if (!is.na(dt$ID[di])) {
      # default 用 ID 辨識個體
      id = dt$ID[di]
    } else {
      # 用其他特徵辨識個體
      # 按照檔案中每一隻特徵給id，如果特徵相同則給流水號
      id_tmp = paste(c("Anonymous", dt$Sex[di], dt$Age[di]), collapse = '-')
      if (is.null(file_idv_pool)) {
        file_idv_pool = c(id_tmp)
      } else {
        file_idv_pool = c(file_idv_pool, id_tmp)
      }
      num_of_id = length(file_idv_pool[file_idv_pool == id_tmp])
      id = paste0(id_tmp, "-", num_of_id)
    }
    
    if (ignoreIdv) {
      id = "Ignored"
    }
    
    # 判斷 N mins 中的個體
    if (is.null(n_mins_id_pool)) {
      # 個體池為空，建立第一筆
      n_mins_id_pool = c(id)
    } else {
      # 個體池有東西
      if (id %in% n_mins_id_pool) {
        # 如果 id 已存在於個體池，就沒事幹
      } else {
        # 如果 id 不在個體池 => 新個體出現，加入個體池，然後重新計算時間區間
        agg_lt_SecOfNMinute = 0
        n_mins_id_pool = c(n_mins_id_pool, id)
      }
      
    }
      

  }
  
  print(n_mins_id_pool)
  print(n_mins_max_idv_count)
  #print(dt$DateTime[di])
  if (!ignoreIdv) {
    nop_ = nop_ + length(n_mins_id_pool)
  } else {
    nop_ = nop_ + n_mins_max_idv_count
  }
  
  n_mins_max_idv_count = 1
  agg_lt_SecOfNMinute = 0
  n_mins_id_pool = NULL

  list('NumberOfPhotos' = nop_)
  
}
