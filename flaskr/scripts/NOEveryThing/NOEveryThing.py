import pandas as pd
#### 定義計算公式 ####
# numnber of photo and event
# 如果只看這個 function 本人，要在只有單一 cameraLocation 單一物種的情況運作
def nopne(dt, NMinute = 30, ignoreIdv = False):
    if dt.empty:
        return None
    dt["idvCount"] = 1
    dt['dt_diff'] = dt['timestamp'].diff().fillna(0)  

    dt['file_id'] = dt['filename']
    perFileSpeciesIdvCount = dt.groupby(['file_id'])['idvCount'].sum().reset_index()
    perFileSpeciesIdvCount.rename(columns={"idvCount": "sumIdvCount"}, inplace=True) 

    # 時間間隔轉換為秒數
    SecOfNMinute = NMinute * 60
  
    agg_lt_SecOfNMinute = 0

    n_mins_id_pool = list()
    n_mins_max_idv_count = 1
    prev_file_id = ""
  
    file_idv_pool = list()
    nop_ = 0
    noe_ = 0
  
    # print(dt["timestamp"][0])

    for di in range(len(dt["dt_diff"])):
        d = dt["dt_diff"].iloc[di]
    
        if di != 0:
            seconds_from_last_photo = d
        else:
            # 要將第一張算入事件，所以將與前一張的時間差設定為大於判定間格
            seconds_from_last_photo = SecOfNMinute + 1
    
        if seconds_from_last_photo > SecOfNMinute:
            noe_ = noe_ + 1
    
        agg_lt_SecOfNMinute = agg_lt_SecOfNMinute + d
    
        if agg_lt_SecOfNMinute > SecOfNMinute:
            # reset and output
            print(n_mins_id_pool)
            print(n_mins_max_idv_count)
            print(dt["timestamp"].iloc[di])
          
            if ~ignoreIdv:
                nop_ = nop_ + len(n_mins_id_pool)
            else:
                nop_ = nop_ + n_mins_max_idv_count
        
            n_mins_max_idv_count = 1
            agg_lt_SecOfNMinute = 0
            n_mins_id_pool = list()
        
        file_id_ = dt["file_id"].iloc[di]
        if file_id_ != prev_file_id:
            n_mins_max_idv_count = max(int(perFileSpeciesIdvCount['sumIdvCount'].loc[perFileSpeciesIdvCount.file_id == file_id_]), n_mins_max_idv_count)
            file_idv_pool = list()
            sno = 1
    
        prev_file_id = file_id_
    
        if "ID" not in dt.columns:
            # 不計個體
            id = "Ignored"
        
        elif dt['ID'].iloc[di] == []:
            # default 用 ID 辨識個體
            id = dt['ID'].iloc[di]
        else:
            # 用其他特徵辨識個體
            # 按照檔案中每一隻特徵給id，如果特徵相同則給流水號
            id_tmp = "Anonymous" + "-" + str(dt['Sex'].iloc[di]) + "-" + str(dt['lifeStage'].iloc[di]) + "-" + str(dt['antler'].iloc[di])
    
            if file_idv_pool == []:
                file_idv_pool.append(id_tmp)
            else: 
                file_idv_pool.append(id_tmp)
                        
            num_of_id = file_idv_pool.count(id_tmp)
            id = id_tmp + "-" + str(num_of_id)
    
        if ignoreIdv:
            id = "Ignored"
    
        # 判斷 N mins 中的個體
        if n_mins_id_pool == []:
            # 個體池為空，建立第一筆
            n_mins_id_pool.extend([id])
        else:
            # 個體池有東西
            if id in n_mins_id_pool:
            # 如果 id 已存在於個體池，就沒事幹
                pass
            else:
                # 如果 id 不在個體池 => 新個體出現，加入個體池，然後重新計算時間區間
                agg_lt_SecOfNMinute = 0
                n_mins_id_pool.extend([id])
    
    print(n_mins_id_pool)
    print(n_mins_max_idv_count)
            
    if ignoreIdv:
        nop_ = nop_ + len(n_mins_id_pool)
    else:
        nop_ = nop_ + n_mins_max_idv_count
    
    n_mins_max_idv_count = 1
    agg_lt_SecOfNMinute = 0
    n_mins_id_pool = list()
     
    output = pd.DataFrame({
        "NumberOfPhotos": [nop_],
        'NumberOfEvents': [noe_], 
        'WorkingHours': [dt["workingHours"].iloc[0]], 
        'WorkingDays': [dt["workingDays"].iloc[0]],
        'NopPerWorkingHour': [nop_ / dt["workingHours"].iloc[0]],
        'NoePerWorkingHour': [noe_ / dt["workingHours"].iloc[0]],
        'NopPerWorkingDay': [nop_ / dt["workingDays"].iloc[0]],
        'NoePerWorkingDay': [noe_ / dt["workingDays"].iloc[0]]
    })

    return output

