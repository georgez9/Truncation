import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path

class Tp_matrix:
    """Define the connection matrix of the imprinted regions in the seizure, visualize and operate it."""
    def __init__(self, matrix, pre_len, post_len, labels, hemisphere, seizure_id="None", patient_id="None", matter_type = ".test"):
        self.matrix = np.array(matrix)
        self.labels = np.array(labels)
        self.hemisphere = hemisphere
        self.patient_id = patient_id
        self.seizure_id = seizure_id
        self.matter_type = matter_type
        self.len = len(self.matrix)
        for i in range(self.len):
            self.matrix[i, i] = 0
        self.pre_len = pre_len
        self.post_len = post_len
        self.subclinical_len = len(self.matrix) - pre_len - post_len
        self.pre_labels = self.labels[:pre_len]
        self.post_labels = self.labels[pre_len:pre_len+post_len]
        self.pre_matrix = self.matrix[:pre_len, :pre_len]
        self.post_matrix = self.matrix[pre_len:pre_len+post_len, pre_len:pre_len+post_len]
        self.inter_matrix = self.matrix[:pre_len, pre_len:pre_len+post_len]

    def plot_heatmap(self, if_show):
        heatmap = self.matrix
        # set different colors for the heatmap
        for i in range(self.pre_len+self.post_len):
            for j in range(self.pre_len+self.post_len):
                if heatmap[i, j] > 0:
                    heatmap[i, j] = 4
        for i in range(self.pre_len):
            for j in range(self.pre_len):
                if heatmap[i, j] > 0:
                    heatmap[i, j] = 2
                    
        for i in range(self.pre_len, self.pre_len+self.post_len):
            for j in range(self.pre_len, self.pre_len+self.post_len):
                if heatmap[i, j] > 0:
                    heatmap[i, j] = 3

        # plot
        cmap = ["#eeeeee", "#dddddd", "#336699", "#99cccc", "#ff6666"]
        plt.figure(figsize=(10, 6))
        ax = sns.heatmap(self.matrix, cbar=None, square=True, cmap=cmap, vmin = 0, vmax = 4)

        for i in range(self.len):
            ax.axhline(i, color='white', linewidth=8)
            ax.axvline(i, color='white', linewidth=8)
        linewidth = 2
        linecolor = "k"
        ax.axhline(y = 0.01, color=linecolor, linewidth=linewidth, xmin=0, xmax=(self.pre_len+self.post_len)/self.len)
        ax.axhline(y = self.pre_len, color=linecolor, linewidth=linewidth, xmin=0, xmax=(self.pre_len+self.post_len)/self.len)
        ax.axhline(y = self.pre_len+self.post_len, color=linecolor, linewidth=linewidth, xmin=0, xmax=(self.pre_len+self.post_len)/self.len)
        ax.axvline(x = 0.01, color=linecolor, linewidth=linewidth, ymin=1-((self.pre_len+self.post_len)/self.len), ymax=1)
        ax.axvline(x = self.pre_len, color=linecolor, linewidth=linewidth, ymin=1-((self.pre_len+self.post_len)/self.len), ymax=1)
        ax.axvline(x = self.pre_len+self.post_len, color=linecolor, linewidth=linewidth, ymin=1-((self.pre_len+self.post_len)/self.len), ymax=1)
        ax.set_xticklabels(self.labels, rotation=0)
        ax.set_yticklabels(self.labels, rotation=0)
        
        if if_show:
            plt.show()

        # save
        current_file_path = Path(__file__).resolve()
        current_dir = current_file_path.parent
        file_path = current_dir / 'pictures' / 'connection_matrix' / f'{self.matter_type}' / f'{self.seizure_id}_{self.patient_id}.png'
        file_path.parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(file_path, dpi=300, format='png', bbox_inches='tight')
        plt.close()

    def plot_topological_graph(self):
        return 0
    
    def calculate_graph_density(self, permute_type, times) -> np.ndarray:
        if permute_type == "ac":    
            pre_connections = np.sum(self.pre_matrix)
            post_connections = np.sum(self.post_matrix)
            inter_connections = np.sum(self.inter_matrix)

            group1_density = pre_connections / (self.pre_len*(self.pre_len-1)) if self.pre_len > 1 else float('nan')
            group2_density = post_connections / (self.post_len*(self.post_len-1)) if self.post_len > 1 else float('nan')
            inter_group_density = inter_connections / (self.pre_len*self.post_len) if self.pre_len > 0 and self.post_len > 0 else float('nan')

            return np.array([group1_density, group2_density, inter_group_density])
        else:
            return self.permutation(times, permute_type)[0]
    


    def calculate_largest_connected_component(self, permute_type, times) -> np.ndarray:
        if permute_type == "ac":  
            def count_zero_rows_columns(matrix):
                if matrix.size == 0:
                    return 0

                zero_rows = np.sum(np.all(matrix == 0, axis=1))            
                zero_columns = np.sum(np.all(matrix == 0, axis=0))

                return zero_rows+zero_columns
            
            def max_connected_component(matrix):    
                n = len(matrix)  
                visited = [False] * n 

                def dfs(x):
                    nonlocal visited
                    count = 1
                    visited[x] = True
                    for i in range(n):
                        if matrix[x][i] == 1 and not visited[i]:
                            count += dfs(i)
                    return count

                max_size = 0
                for i in range(n):
                    if not visited[i]:
                        size = dfs(i)
                        max_size = max(max_size, size)

                if n < 2:
                    return np.nan
                else:        
                    return max_size / n

            pre_portion = max_connected_component(self.pre_matrix)
            post_portion = max_connected_component(self.post_matrix)
            inter_portion = 1 - count_zero_rows_columns(self.inter_matrix)/(self.pre_len+self.post_len)

            return np.array([pre_portion, post_portion, inter_portion])
        else:
            return self.permutation(times, permute_type)[1]
        
    def shuffling_regions(self):
        idx = np.random.permutation(self.len)
        shuffled_matrix = self.matrix[idx, :][:, idx]
        shuffled_labels = self.labels[idx]
        return Tp_matrix(shuffled_matrix, self.pre_len, self.post_len, shuffled_labels, self.seizure_id, self.patient_id, self.matter_type)
    
    def shuffling_TP(self):
        cut = np.random.randint(1, self.len+1)
        pre_len = cut
        post_len = self.len - cut
        return Tp_matrix(self.matrix, pre_len, post_len, self.labels, self.seizure_id, self.patient_id, self.matter_type)
    
    def permutation(self, times, permute_type):
        density_list = []
        max_c_list = []
        if permute_type == "pr":
            for _ in range(times):
                tmp_matrix = self.shuffling_regions()
                density_list.append(tmp_matrix.calculate_graph_density("ac", "1"))
                max_c_list.append(tmp_matrix.calculate_largest_connected_component("ac", "1"))
        elif permute_type == "pt":
            for _ in range(times):
                tmp_matrix = self.shuffling_TP()
                density_list.append(tmp_matrix.calculate_graph_density("ac", "1"))
                max_c_list.append(tmp_matrix.calculate_largest_connected_component("ac", "1"))
        density_list = np.array(density_list)
        dst1 = np.nan if np.all(np.isnan(density_list[:, 0])) else np.nanmean(density_list[:, 0])
        dst2 = np.nan if np.all(np.isnan(density_list[:, 1])) else np.nanmean(density_list[:, 1])
        dst3 = np.nan if np.all(np.isnan(density_list[:, 2])) else np.nanmean(density_list[:, 2])
        density_list = np.array([dst1, dst2, dst3])

        max_c_list = np.array(max_c_list)
        maxc1 = np.nan if np.all(np.isnan(max_c_list[:, 0])) else np.nanmean(max_c_list[:, 0])
        maxc2 = np.nan if np.all(np.isnan(max_c_list[:, 1])) else np.nanmean(max_c_list[:, 1])
        maxc3 = np.nan if np.all(np.isnan(max_c_list[:, 2])) else np.nanmean(max_c_list[:, 2])
        max_c_list = np.array([maxc1, maxc2, maxc3])
        
        return density_list, max_c_list

    def info(self):
        print('matrix:')
        print(self.matrix)
        print(self.labels)
        print('pre truncated matrix:')
        print(self.pre_matrix)
        print(self.pre_labels)
        print('post truncated matrix:')
        print(self.post_matrix)
        print(self.post_labels)
        print('graph density:')
        print(self.calculate_graph_density())
        print('largest_connected_component')
        print(self.calculate_largest_connected_component())

def find_submatrix(labels, map_labels, map):
    # dict - label:idx
    map_labels_indices = {label: idx for idx, label in enumerate(map_labels)}
    matrix_label_indices = [map_labels_indices[label] for label in labels]
    matrix = map[np.ix_(matrix_label_indices, matrix_label_indices)]
    return matrix

def calculate_DBA_DAA(ele_list: np.ndarray) -> np.ndarray:
    DBA = ele_list[0] - ele_list[2]
    DAA = ele_list[1] - ele_list[2]
    return np.array([DBA, DAA])

def save_DBA_DAA(DBA_DAA_list, file_path, matter_type, permute_type, hemisphere_list):
    DBA_DAA_list = np.array(DBA_DAA_list)
    column_name_DBA = f'DBA_{matter_type}_{permute_type}'
    column_name_DAA = f'DAA_{matter_type}_{permute_type}'

    write_file = pd.read_csv(file_path)

    if len(DBA_DAA_list) == len(write_file):
        write_file["Hemisphere"] = hemisphere_list
        write_file[column_name_DBA] = DBA_DAA_list[:, 0]
        write_file[column_name_DAA] = DBA_DAA_list[:, 1]
        write_file.to_csv(file_path, index=False)
    else:
        print("Error: The length of the new data does not match the number of rows in the DataFrame.")

# test class tp_matrix
# mt = [[1, 0, 1, 0],
#       [0, 0, 1, 0],
#       [1, 1, 0, 1],
#       [0, 0, 1, 1]]
# labels = ["a", "b", "c", "d"]

# seizure_matrix = Tp_matrix(mt, 1, 2, labels)
# seizure_matrix.info()

# sf = seizure_matrix.shuffling_regions()
# sf.info()

# test = calculate_DBA_DBB(seizure_matrix.calculate_graph_density())
# print(test)

# seizure_matrix.plot_heatmap(True)