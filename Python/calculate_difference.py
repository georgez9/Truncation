import pandas as pd
from sklearn.cluster import SpectralClustering
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
import os
from scipy.cluster.hierarchy import fcluster, linkage, dendrogram
from scipy.spatial.distance import squareform
import community as community_louvain
import networkx as nx

save_graph = True
matter_type = "white"
permute_tp = False
permute_region = True
permutation_times_default = 1000

def plot_heatmap(labels_index_1, labels_index_2, map, data, id):

    if save_graph and not (permute_tp or permute_region):
        for i in range(len(labels_index_1)):
            for j in range(len(labels_index_1)):
                if map[i, j] > 0:
                    map[i, j] = 2
                    
        for i in range(len(labels_index_1), len(labels_index_1)+len(labels_index_2)):
            for j in range(len(labels_index_1), len(labels_index_1)+len(labels_index_2)):
                if map[i, j] > 0:
                    map[i, j] = 3

        sns.set_theme()
        plt.figure(figsize=(10, 6))
        ax = sns.heatmap(map, cbar=None, square=True)
        ax.axhline(len(labels_index_1), color='white')
        ax.axvline(len(labels_index_1), color='white')
        ax.set_yticklabels(np.append(data['LabelsBeforeTP'].dropna().to_numpy(dtype='U30'), 
                                    data['LabelsAfterTP'].dropna().to_numpy(dtype='U30')), rotation=0)
        file_path = f"./pictures/connection_matrix/white/{id}_{data['PatientID'].to_list()[0]}.png"
        directory_path = os.path.dirname(file_path)
        if not os.path.exists(directory_path):
            os.makedirs(directory_path)
        plt.savefig(file_path, dpi=300, format='png', transparent=True, bbox_inches='tight')
        plt.close()

def cal_graph_density(matrix, len1, len2):
    group1_matrix = matrix[:len1, :len1]
    group2_matrix = matrix[len1:, len1:]
    inter_group_matrix = matrix[:len1, len1:]

    group1_connections = np.sum(group1_matrix)
    group2_connections = np.sum(group2_matrix)
    inter_group_connections = np.sum(inter_group_matrix)
    
    group1_density = group1_connections / (len1*(len1-1)) if len1 > 1 else float('nan')
    group2_density = group2_connections / (len2*(len2-1)) if len2 > 1 else float('nan')
    inter_group_density = inter_group_connections / (len1*len2) if len1 > 0 and len2 > 0 else float('nan')
    return round(group1_density, 2), round(group2_density, 2), round(inter_group_density, 2)

def save_csv(density_list_dropnan, matter_type, permute_tp, permute_region, directory="./data_output"):
    graph_density_before_tp = density_list_dropnan[:, 0]
    graph_density_after_tp = density_list_dropnan[:, 1]
    graph_density_across_tp = density_list_dropnan[:, 2]

    permutation_type = "permute_tp" if permute_tp else "actual"
    if permute_region:
        permutation_type = "permute_region"
    save_csv_path = f"{directory}/{matter_type}_matter_density_{permutation_type}.csv"
    
    df = pd.DataFrame({
        'Before TP': graph_density_before_tp,
        'After TP': graph_density_after_tp,
        'Across TP': graph_density_across_tp
    })
    
    df.to_csv(save_csv_path, index=False)
    
    return df

def ploy_box_graph_density(df):
    df_long = pd.melt(df, var_name='Groups', value_name='Graph density')
    plt.figure(figsize=(4, 6))
    sns.boxplot(x='Groups', y='Graph density', data=df_long, palette="Set3", legend=False)
    sns.stripplot(x='Groups', y='Graph density', data=df_long, color='black', size=5, jitter=True, alpha=0.5)

    dba = (df['Before TP'] - df['Across TP']) / 2
    daa = (df['After TP'] - df['Across TP']) /2
    plt.ylim(-0.1, 1.1)

    df = pd.DataFrame({'DBA': dba,
                    'DAA': daa})
    df_long = pd.melt(df, var_name='Groups', value_name='Graph density difference')
    plt.figure(figsize=(2, 6))
    sns.boxplot(x='Groups', y='Graph density difference', data=df_long, palette="Set3", legend=False)
    sns.stripplot(x='Groups', y='Graph density difference', data=df_long, color='black', size=5, jitter=True, alpha=0.5)
    plt.ylim(-0.5, 0.5)
    plt.show()

def divide_matrix(matrix, n_pre):
    len_m = len(matrix)
    if len_m > 0:
        m = 1
        rank_list = []
        while m < len_m:
            p = matrix[0:m, m:len_m]
            p = np.mean(p)
            rank_list.append(p)
            m = m + 1
        rank_list_max = np.max(rank_list)
        rank_list_min = np.min(rank_list)
        
        if rank_list_max == rank_list_min:
            rank = 0
        else:
            rank = (rank_list[n_pre-1] - rank_list_min) / (rank_list_max - rank_list_min)
            rank = round(rank, 2)

    return rank


# load files
map_labels = pd.read_csv(r".\data\connection_map_labels.csv", header=None)[0].to_numpy(dtype='U30')
map_white_matters = pd.read_csv(r".\data\connection_map_white_matter.csv", header=None).to_numpy(dtype=int)
map_grey_matters = pd.read_csv(r".\data\connection_map_grey_matter.csv", header=None).to_numpy(dtype=int)
df = pd.read_csv(r"..\connection_func\seizures\regions_on_both_side_of_tp.csv")

# delete self connection
for i in range(0, len(map_white_matters)):
    map_white_matters[i][i] = 0

for i in range(0, len(map_grey_matters)):
    map_grey_matters[i][i] = 0

map_all_matters = map_white_matters + map_grey_matters
map_all_matters[map_all_matters > 0] = 1

# each id is a seizure
seizure_ids = np.unique(np.array(df['ID']))
density_list = []

# can't permute regions and tp at same time
if permute_region and permute_tp:
    raise ValueError("permute_region and permute_tp cannot both be True.")

warnings.simplefilter("ignore", category=RuntimeWarning)
warnings.simplefilter("ignore", category=FutureWarning)

for seizure_id in seizure_ids:
    seizure_df = df[df['ID'] == seizure_ids[seizure_id-1]].copy()
    permute_region_list = []
    
    labels_choices = seizure_df['Labels'].dropna().unique()
    map_labels_indices = {label: idx for idx, label in enumerate(map_labels)}
    seizure_label_indices_actual = [map_labels_indices[label] for label in labels_choices]

    p_result = []
    fit_result_list = []
    for _ in range(permutation_times_default if permute_region else 1):

        if permute_region:
            seizure_label_indices = np.random.permutation(seizure_label_indices_actual)
        else:
            seizure_label_indices = seizure_label_indices_actual

        len_before_tp = seizure_df['LabelsBeforeTP'].notna().sum()
        len_after_tp = seizure_df['LabelsAfterTP'].notna().sum()
        
        labels_before_tp_indices = seizure_label_indices[:len_before_tp]
        labels_after_tp_indices = seizure_label_indices[len_before_tp:len_before_tp+len_after_tp]

        labels_indices = list(labels_before_tp_indices) + list(labels_after_tp_indices)

        if matter_type == "white":
            seizure_matrix = map_white_matters[np.ix_(labels_indices, labels_indices)]
        elif matter_type == "grey":
            seizure_matrix = map_grey_matters[np.ix_(labels_indices, labels_indices)]
        elif matter_type == "all":
            seizure_matrix = map_all_matters[np.ix_(labels_indices, labels_indices)]

        # # inter-group connection code
        # if len(labels_before_tp_indices) > 0 and len(labels_after_tp_indices) > 0 and len(labels_before_tp_indices)+len(labels_after_tp_indices) > 2:
        #     result = divide_matrix(seizure_matrix, len(labels_before_tp_indices))
        #     p_result.append(result)

        # clustering code
        if len(labels_before_tp_indices) > 0 and len(labels_after_tp_indices) > 0 and len(labels_before_tp_indices)+len(labels_after_tp_indices) > 2:
            distance_matrix = 1 - seizure_matrix
            np.fill_diagonal(distance_matrix, 0)
            distance_vector = squareform(distance_matrix)
            Y = linkage(distance_vector, 'single')
            clustering_labels = fcluster(Y, t=2, criterion='maxclust')
            clustering_labels = np.array(clustering_labels-1)
            actual_labels = [1]*len(labels_before_tp_indices)+[0]*len(labels_after_tp_indices)
            actual_labels = np.array(actual_labels)
            
        # clustering code 2
        # if len(labels_before_tp_indices) > 0 and len(labels_after_tp_indices) > 0 and len(labels_before_tp_indices)+len(labels_after_tp_indices) > 2:
        #     G = nx.from_numpy_array(seizure_matrix)
        #     partition = community_louvain.best_partition(G)

        #     # 绘制图和社区
        #     pos = nx.spring_layout(G)
        #     cmap = plt.get_cmap('viridis')
        #     colors = [cmap(i) for i in partition.values()]
        #     nx.draw_networkx_nodes(G, pos, node_size=100, node_color=colors)
        #     nx.draw_networkx_edges(G, pos, alpha=0.5)
        #     plt.show()

        #     # 获取所有社区标签的唯一值
        #     unique_labels = set(partition.values())

        #     # 创建一个标签到0和1的映射
        #     label_to_binary = {label: i for i, label in enumerate(unique_labels)}

        #     # 根据映射生成二进制标签数组
        #     binary_labels = [label_to_binary[partition[i]] for i in range(len(partition))]

        #     print(binary_labels)
            
        # clustering code 3
        # if len(labels_before_tp_indices) > 0 and len(labels_after_tp_indices) > 0 and len(labels_before_tp_indices)+len(labels_after_tp_indices) > 2:
        #     n_clusters = 2
        #     # warnings.simplefilter("ignore", category=UserWarning)
        #     modified_matrix = np.where(seizure_matrix == 0, 0.1, seizure_matrix)
        #     clustering = SpectralClustering(n_clusters=n_clusters, affinity='precomputed', assign_labels='kmeans')
        #     clustering_labels = clustering.fit_predict(modified_matrix)
        #     clustering_labels = np.array(clustering_labels)
        #     actual_labels = [1]*len(labels_before_tp_indices)+[0]*len(labels_after_tp_indices)
        #     actual_labels = np.array(actual_labels)

            # calculate TP, TN, FP, FN
            TP = np.sum((actual_labels == 1) & (clustering_labels == 1)) / len(actual_labels)
            TN = np.sum((actual_labels == 0) & (clustering_labels == 0)) / len(actual_labels)
            FP = np.sum((actual_labels == 0) & (clustering_labels == 1)) / len(actual_labels)
            FN = np.sum((actual_labels == 1) & (clustering_labels == 0)) / len(actual_labels)
            confusion_matrix = np.array([[TP, FP], [FN, TN]])
            fit_result = np.abs((TP+TN) - (FP+FN))
            # print(actual_labels)
            # print(clustering_labels)
            # print(confusion_matrix)
            fit_result_list.append(fit_result)


        # plot_heatmap(labels_before_tp_indices, labels_after_tp_indices, seizure_matrix, seizure_df, seizure_id)

        permute_tp_list = []
        for _ in range(permutation_times_default if permute_tp else 1):
            if permute_tp:
                cut = np.random.randint(0, len(labels_indices)+1)
                labels_before_tp_indices = labels_indices[:cut]
                labels_after_tp_indices = labels_indices[cut:]
            list1 = cal_graph_density(seizure_matrix, len(labels_before_tp_indices), len(labels_after_tp_indices))
            permute_tp_list.append(list1)

        if permute_tp_list:
            list1 = np.nanmean(permute_tp_list, axis=0)
            permute_region_list.append(list1)

    if permute_region_list:
        list1 = np.nanmean(permute_region_list, axis=0)
        density_list.append(list1)

    # if p_result:
    #     print(round(np.mean(p_result), 2))
    if fit_result_list:
        print(round(np.mean(fit_result_list), 2))

density_list_dropnan = []
for i in density_list:
    if np.any(np.isnan(i)):
        continue
    density_list_dropnan.append(i)

density_list_dropnan = np.array(density_list_dropnan)

print(f"{len(density_list)} seizures,")
print(f"{len(density_list_dropnan)} left after droping 'nan'.")

# save graph density to .csv file
df = save_csv(density_list_dropnan, matter_type, permute_tp, permute_region)
ploy_box_graph_density(df)
