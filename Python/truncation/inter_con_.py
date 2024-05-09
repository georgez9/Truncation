import random
from adjacency_matrix import Tp_matrix, find_submatrix
from scipy.stats import pearsonr, spearmanr, kendalltau, chi2_contingency
import pandas as pd
import json
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

def calculate_correlations(x, y):
    x = np.asarray(x)
    y = np.asarray(y)

    pearson_coef, pearson_p = pearsonr(x, y)
    
    spearman_coef, spearman_p = spearmanr(x, y)
    
    kendall_coef, kendall_p = kendalltau(x, y)

    return {
        "Pearson": {"Coefficient": pearson_coef, "P-value": pearson_p},
        "Spearman": {"Coefficient": spearman_coef, "P-value": spearman_p},
        "Kendall": {"Coefficient": kendall_coef, "P-value": kendall_p}
    }


class Inter_connection(Tp_matrix):
    def cal_and_ranking_permute_tp(self):

        def scale_to_unit_interval(arr):
            n_min = min(arr)
            n_max = max(arr)
            
            if n_max == n_min:
                return [0 if x == n_min else 1 for x in arr]

            scaled_arr = [(x - n_min) / (n_max - n_min) for x in arr]
            return scaled_arr

        actual_pre_pen = self.pre_len

        if self.pre_len<1 or self.post_len<1 or self.active_len<3:
            return None
        # calculate all the possible inter_group connections
        inter_gd_list = []
        for i in range(1, self.active_len):
            self.pre_len = i
            inter_gd = self.calculate_graph_density('ac')[2]
            # inter_gd = self.calculate_largest_connected_component('ac')[2]
            inter_gd_list.append(inter_gd)
        gap = 1/(len(inter_gd_list)-1)


        inter_gd_list = scale_to_unit_interval(inter_gd_list)
        inter_gd_list = [round(num, 3) for num in inter_gd_list]
        return [actual_pre_pen-1, inter_gd_list]
    
if __name__ == "__main__":
    # load files
    with open('data/connection_matrix.json', 'r', encoding='utf-8') as f:
        connections = json.load(f)

    map_labels = np.array(connections.get("labels"))[0]

    map_white_matters = np.array(connections.get("white_matter"))
    map_grey_matters = np.array(connections.get("grey_matter"))
    map_all_matters = map_white_matters + map_grey_matters
    map_all_matters[map_all_matters > 0] = 1

    with open('output_data/truncation_labels.json', 'r', encoding='utf-8') as f:
        seizures = json.load(f)

    matter_type = "all"
    method = "gd"

    df_all_seizures = pd.DataFrame()
    df_actual_seizures = pd.DataFrame()

    times = 0
    for seizure in seizures:
        id = seizure.get("id")
        patient_id = seizure.get("patient_id")
        regions = seizure.get("regions")
        hemisphere = seizure.get("hemisphere")
        pre_len = len(seizure.get("regions_bf_tp"))
        post_len = len(seizure.get("regions_af_tp"))

        maps = map_all_matters
        for i in range(len(maps)):
            maps[i][i] == 0

        matrix = find_submatrix(regions, map_labels, maps)
        seizure_matrix = Inter_connection(matrix, pre_len, post_len, regions, hemisphere, id, patient_id, matter_type)
        
        inter_group_connection_list = seizure_matrix.cal_and_ranking_permute_tp()
        if inter_group_connection_list:
            len_list = len(inter_group_connection_list[1])
            df_single_seizure = pd.DataFrame(
                {
                    "id" : [id]*len_list,
                    "position_rank" : [i for i in range(len_list)],
                    "position" : [round((i / (len_list - 1)), 3) for i in range(len_list)],
                    "connectivity" : inter_group_connection_list[1]
                }
            )
            df_all_seizures = pd.concat([df_all_seizures, df_single_seizure])
            # save tp position
            rank = inter_group_connection_list[0]
            query_string = f"position_rank == {rank}"
            selected_row = df_single_seizure.query(query_string)
            result = tuple(selected_row[['position', 'connectivity']].iloc[0])
            df_single_tp_position = pd.DataFrame(
                {
                    "id" : [id],
                    "position" : result[0],
                    "connectivity" : result[1]
                }
            )
            df_actual_seizures = pd.concat([df_actual_seizures, df_single_tp_position])

    print("df_all_seizures:")
    print(df_all_seizures.head())
    print("df_actual_seizures:")
    print(df_actual_seizures.head())



    plt.figure(figsize=(5, 5))
    ax = sns.scatterplot(
        data=df_all_seizures,
        x="position", y="connectivity",
        # hue="id",
        legend=False
    )

    ax = sns.scatterplot(
        data=df_actual_seizures,
        x="position", y="connectivity",
        # hue="id",
        legend=False
    )

    df_permute = df_all_seizures[['connectivity']].copy()
    data1 = df_permute.to_numpy().T[0]
    data1 = np.random.choice(data1, 56, replace=False)

    df_permute['type'] = 'permute'  # 添加 'type' 列

    # 从 df_tp_position 创建新 DataFrame
    df_actual = df_actual_seizures[['connectivity']].copy()
    data2 = df_actual.to_numpy().T[0]
    print(len(data2))

    df_actual['type'] = 'actual'  # 添加 'type' 列

    # 合并两个 DataFrame
    df_new = pd.concat([df_permute, df_actual], ignore_index=True)
    print(df_new.head())
    
    plt.figure(figsize=(5, 4))
    sns.histplot(data=df_new, x="connectivity", hue="type", bins=10, stat='probability', kde=True, common_norm=False)
    # sns.kdeplot(data=df_all_seizures, x="connectivity")
    # sns.histplot(data=df_new, x="connectivity", hue="type", bins=5, stat='probability', kde=True, multiple="stack")
    # sns.kdeplot(data=df_tp_position, x="connectivity")


    print(calculate_correlations(data1, data2))

    plt.show()