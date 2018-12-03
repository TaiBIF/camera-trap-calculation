import pandas as pd

def NumberofPhotos(orig_dt, NMinute = 30, ignoreIdv = False):
    """
    有效目擊照片    
    """
    if not orig_dt.empty:
        # 每個檔案 ID 被拍照的數量
        orig_dt['dt_diff'] = orig_dt['unix_datetime'].diff().fillna(0)  
        orig_dt['file_id'] = orig_dt['FileName'] + '-' + orig_dt['unix_datetime'].astype(int).astype(str)
        
        perFileSpeciesIdvCount = orig_dt.groupby(['file_id'])['IdvCount'].sum().reset_index()
        perFileSpeciesIdvCount.rename(columns={"IdvCount": "sumIdvCount"}, inplace=True) 

        SecOfNMinute = NMinute * 60  # 轉換成秒
        
        agg_lt_SecOfNMinute = 0
        n_mins_id_pool = list()
        n_mins_max_idv_count = 1
        prev_file_id = ""
  
        file_idv_pool = list()
        nop_ = 0

        print(orig_dt.DateTime.iloc[0])

        for di, d in enumerate(orig_dt['dt_diff']):  
            agg_lt_SecOfNMinute = agg_lt_SecOfNMinute + d  # 累積的時間差
                
            if agg_lt_SecOfNMinute > SecOfNMinute:
                # reset and output
                print(n_mins_id_pool)
                print(n_mins_max_idv_count)
                print(orig_dt['DateTime'].iloc[di])

                if ~ignoreIdv:
                    nop_ = nop_ + len(n_mins_id_pool)
                else:
                    nop_ = nop_ + n_mins_max_idv_count
   
                n_mins_max_idv_count = 1
                agg_lt_SecOfNMinute = 0
                n_mins_id_pool = list()
                    
            file_id_ = orig_dt['file_id'].iloc[di]
            if file_id_ != prev_file_id:
                n_mins_max_idv_count = max(int(perFileSpeciesIdvCount['sumIdvCount'].loc[perFileSpeciesIdvCount.file_id == file_id_]), n_mins_max_idv_count)
                file_idv_pool = list()
                sno = 1

            if "ID" not in orig_dt.columns:
                # 不計個體
                id = "Ignored"

            elif orig_dt['ID'].iloc[di] == []:
                # default 用 ID 辨識個體
                id = orig_dt['ID'].iloc[di]

            else:
                # 用其他特徵辨識個體
                # 按照檔案中每一隻特徵給id，如果特徵相同則給流水號
                id_tmp = "Anonymous" + "-" + str(orig_dt['Sex'].iloc[di]) + "-" + str(orig_dt['Age'].iloc[di])

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
    else:
        print("Houston, we've had a problem here.")
        
    print(n_mins_id_pool)
    print(n_mins_max_idv_count)
        
    if ignoreIdv:
        nop_ = nop_ + len(n_mins_id_pool)
    else:
        nop_ = nop_ + n_mins_max_idv_count

    n_mins_max_idv_count = 1
    agg_lt_SecOfNMinute = 0
    n_mins_id_pool = list()
 
    outout = {"NumberOfPhotos": nop_}
    return outout