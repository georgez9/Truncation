import numpy as np
import pandas as pd
import seaborn as sns
import os
import matplotlib.pyplot as plt

class Tp_matrix:
    """Define the connection matrix in a seizure, visualize and operate it."""
    def __init__(self, matrix, pre_len, post_len, labels=None, hemisphere=None, seizure_id="None", patient_id="None", matter_type = ".test"):
        ## property
        self._matrix = np.array(matrix)
        self.labels = labels
        if labels:
            self.labels = np.array(labels)
            self.pre_labels = self.labels[:pre_len]
            self.post_labels = self.labels[pre_len:pre_len+post_len]
        self.hemisphere = hemisphere
        self.patient_id = patient_id
        self.id = seizure_id
        self.matter_type = matter_type
        ## length
        self.len = len(self.matrix)
        self.active_len = pre_len+post_len
        for i in range(self.len):
            self.matrix[i, i] = 0
        self._pre_len = pre_len
        self.post_len = post_len
        ## matrix
        self.pre_matrix = self.matrix[:pre_len, :pre_len]
        self.post_matrix = self.matrix[pre_len:pre_len+post_len, pre_len:pre_len+post_len]
        self.inter_matrix = self.matrix[:pre_len, pre_len:pre_len+post_len]

    # if pre_len changes, autoly update others
    @property
    def pre_len(self):
        return self._pre_len
    
    @pre_len.setter
    def pre_len(self, new_value):
        if new_value != self._pre_len:
            self._pre_len = new_value
            self.tp_changed()
    def tp_changed(self):
        self.post_len = self.active_len-self._pre_len
        self.pre_matrix = self.matrix[:self._pre_len, :self._pre_len]
        self.post_matrix = self.matrix[self._pre_len:self._pre_len+self.post_len, self._pre_len:self._pre_len+self.post_len]
        self.inter_matrix = self.matrix[:self._pre_len, self._pre_len:self._pre_len+self.post_len]

    # if matrix changes, autoly update others
    @property
    def matrix(self):
        return self._matrix
    
    @matrix.setter
    def matrix(self, new_matrix):
        if not np.array_equal(new_matrix, self._matrix):
            self._matrix = new_matrix
            self.regions_changed()
    def regions_changed(self):
        self.pre_matrix = self._matrix[:self._pre_len, :self._pre_len]
        self.post_matrix = self._matrix[self._pre_len:self._pre_len+self.post_len, self._pre_len:self._pre_len+self.post_len]
        self.inter_matrix = self._matrix[:self._pre_len, self._pre_len:self._pre_len+self.post_len]
    
    # show connection heatmap
    def plot_heatmap(self, if_show): # show the connection matrix and save them to the `file_path`
        heatmap = self.matrix
        ## set different colors for the heatmap
        for i in range(self._pre_len+self.post_len):
            for j in range(self._pre_len+self.post_len):
                if heatmap[i, j] > 0:
                    heatmap[i, j] = 4
        for i in range(self._pre_len):
            for j in range(self._pre_len):
                if heatmap[i, j] > 0:
                    heatmap[i, j] = 2
                    
        for i in range(self._pre_len, self._pre_len+self.post_len):
            for j in range(self._pre_len, self._pre_len+self.post_len):
                if heatmap[i, j] > 0:
                    heatmap[i, j] = 3

        ## plot
        cmap = ["#eeeeee", "#dddddd", "#336699", "#99cccc", "#ff6666"]
        plt.figure(figsize=(10, 6))
        ax = sns.heatmap(self.matrix, cbar=None, square=True, cmap=cmap, vmin = 0, vmax = 4)

        for i in range(self.len):
            ax.axhline(i, color='white', linewidth=8)
            ax.axvline(i, color='white', linewidth=8)
        linewidth = 2
        linecolor = "k"
        ax.axhline(y = 0.01, color=linecolor, linewidth=linewidth, xmin=0, xmax=(self._pre_len+self.post_len)/self.len)
        ax.axhline(y = self._pre_len, color=linecolor, linewidth=linewidth, xmin=0, xmax=(self._pre_len+self.post_len)/self.len)
        ax.axhline(y = self._pre_len+self.post_len, color=linecolor, linewidth=linewidth, xmin=0, xmax=(self._pre_len+self.post_len)/self.len)
        ax.axvline(x = 0.01, color=linecolor, linewidth=linewidth, ymin=1-((self._pre_len+self.post_len)/self.len), ymax=1)
        ax.axvline(x = self._pre_len, color=linecolor, linewidth=linewidth, ymin=1-((self._pre_len+self.post_len)/self.len), ymax=1)
        ax.axvline(x = self._pre_len+self.post_len, color=linecolor, linewidth=linewidth, ymin=1-((self._pre_len+self.post_len)/self.len), ymax=1)
        ax.set_xticklabels(self.labels, rotation=0)
        ax.set_yticklabels(self.labels, rotation=0)
        
        if if_show:
            plt.show()

        ## save
        file_path = f'figures/connection_matrix/{self.matter_type}.png'
        plt.savefig(file_path, dpi=300, format='png', bbox_inches='tight')
        plt.close()
    
    # Calculate graph density
    def calculate_graph_density(self) -> np.ndarray:
   
        pre_connections = np.sum(self.pre_matrix)
        post_connections = np.sum(self.post_matrix)
        inter_connections = np.sum(self.inter_matrix)

        group1_density = pre_connections / (self._pre_len*(self._pre_len-1)) if self._pre_len > 1 else float('nan')
        group2_density = post_connections / (self.post_len*(self.post_len-1)) if self.post_len > 1 else float('nan')
        inter_group_density = inter_connections / (self._pre_len*self.post_len) if self._pre_len > 0 and self.post_len > 0 else float('nan')

        return np.array([group1_density, group2_density, inter_group_density])

    

    # Calculate_largest_connected_component
    def calculate_largest_connected_component(self) -> np.ndarray:

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
        inter_portion = 1 - count_zero_rows_columns(self.inter_matrix)/(self._pre_len+self.post_len)

        return np.array([pre_portion, post_portion, inter_portion])

        
    
    
    
    
    def permutation(self, permutation_times, permute_type, connection_type):

        def shuffling_regions(self):
            idx = np.random.permutation(self.len)
            self.matrix = self._matrix[idx, :][:, idx]
            self.labels = self.labels[idx]
        
        def shuffling_TP(self):
            cut = np.random.randint(1, self.len+1)
            self.pre_len = cut

        connection_list = []

        while len(connection_list) < permutation_times:
            if permute_type == "pr":
                shuffling_regions(self)
            elif permute_type == "pt":
                shuffling_TP(self)
            elif permute_type != 'ac':
                raise TypeError("Wrong permutation type")

            if connection_type == "gd":
                connection = self.calculate_graph_density()
            elif connection_type == "lcc":
                connection = self.calculate_largest_connected_component()
            else:
                raise TypeError("Wrong connection type")
            # judge acutal
            if permute_type == 'ac':
                if np.isnan(connection).any():
                    return
                connection_list.append(connection)
                break

            # judge permutation
            if np.isnan(connection).any():
                continue
            connection_list.append(connection)
        
        ## save permutation results
        connection_list = np.array(connection_list)
        df_permutation = pd.DataFrame(
            {
                "id" : [self.id]*len(connection_list),
                "patient_id" : [self.patient_id]*len(connection_list),
                "permute_type" : [permute_type]*len(connection_list),
                "connection_type" : [connection_type]*len(connection_list),
                "BTP" : connection_list[:, 0],
                "ATP" : connection_list[:, 1],
                "ACTP" : connection_list[:, 2],
            }
        )

        output_path = os.path.join('output_data', 'permute_results.csv')
        df_permutation.to_csv(output_path, mode='a', header=False, index=False)
        
        bf = np.nan if np.all(np.isnan(connection_list[:, 0])) else np.nanmean(connection_list[:, 0])
        af = np.nan if np.all(np.isnan(connection_list[:, 1])) else np.nanmean(connection_list[:, 1])
        ac = np.nan if np.all(np.isnan(connection_list[:, 2])) else np.nanmean(connection_list[:, 2])
        
        return np.array([bf, af, ac])

    def info(self):
        print()
        print("New info:")
        print('Matrix:')
        print(self.matrix)
        if self.labels:
            print(self.labels)
        print('Pre truncated matrix:')
        print(self.pre_matrix)
        if self.labels:
            print(self.pre_labels)
        print('Post truncated matrix:')
        print(self.post_matrix)
        if self.labels:
            print(self.post_labels)
        print('Inter truncated matrix:')
        print(self.inter_matrix)
        print('Graph density:', end=' ')
        print(self.calculate_graph_density('ac', 1))
        print('Largest_connected_component:', end=' ')
        print(self.calculate_largest_connected_component('ac',1))

def find_submatrix(labels, map_labels, map): 
    # form the whole matter connection map extract the submap for a seizure
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

def save_connectivity(connectivity_list, file_path, matter_type, hemisphere_list):
    connectivity_list = np.array(connectivity_list)
    write_file = pd.read_csv(file_path)
    if len(connectivity_list) == len(write_file):
        write_file["Hemisphere"] = hemisphere_list
        write_file[f'BTP_{matter_type}'] = connectivity_list[:, 0]
        write_file[f'ATP_{matter_type}'] = connectivity_list[:, 1]
        write_file[f'ACTP_{matter_type}'] = connectivity_list[:, 2]
        write_file.to_csv(file_path, index=False)
    else:
        print("Error: The length of the new data does not match the number of rows in the DataFrame.")

def plot_dba_daa(csv_save_path, figure_save_path):

    def subplot(full_df, column_names, matter_type, axes, location):
        df = full_df[column_names].copy()
        df.loc[:, 'Matter_type'] = matter_type
        df = pd.melt(df, id_vars=['Matter_type', 'Hemisphere'], var_name='Groups', value_name='Graph density difference')

        cmap = ["#F7CB67", '#CA8BBB', '#6E6A91']
        cmap1 = ["#FCEBC4", '#E7CBE0', '#C3C1D1']

        sns.boxplot(
            data=df,
            x='Groups', y='Graph density difference', hue='Hemisphere',
            legend=False,
            linecolor='black',
            linewidth=1,
            palette=cmap1,
            ax=axes.flat[location],
            gap = .2,
        )
        sns.stripplot(data=df, x='Groups', y='Graph density difference', hue='Hemisphere',
                dodge=True, 
                size=4,
                edgecolor='black',
                linewidth=1,
                legend=False,
                palette=cmap,
                ax=axes.flat[location],
        )
        axes.flat[location].axhline(0, color='red', linestyle='-', linewidth = 1)

    _, axes = plt.subplots(2, 3, figsize=([10, 6]))
    plot_df = pd.read_csv(csv_save_path)

    subplot(plot_df, ['DBA_all_ac', 'DBA_all_pr', 'DBA_all_pt', 'Hemisphere'], 'AM', axes, 0)
    subplot(plot_df, ['DBA_white_ac', 'DBA_white_pr', 'DBA_white_pt', 'Hemisphere'], 'WM', axes, 1)
    subplot(plot_df, ['DBA_grey_ac', 'DBA_grey_pr', 'DBA_grey_pt', 'Hemisphere'], 'GM', axes, 2)
    subplot(plot_df, ['DAA_all_ac', 'DAA_all_pr', 'DAA_all_pt', 'Hemisphere'], 'AM', axes, 3)
    subplot(plot_df, ['DAA_white_ac', 'DAA_white_pr', 'DAA_white_pt', 'Hemisphere'], 'WM', axes, 4)
    subplot(plot_df, ['DAA_grey_ac', 'DAA_grey_pr', 'DAA_grey_pt', 'Hemisphere'], 'GM', axes, 5)

    for ax in axes.flat:
        ax.set_ylim(-0.6, 1.1)
        ax.set_ylabel('')
        ax.set_xlabel('')

    axes.flat[0].set_yticks([-0.5, 0, 0.5, 1])
    axes.flat[0].set_xticks([])
    axes.flat[1].set_yticks([])
    axes.flat[1].set_xticks([])
    axes.flat[2].set_yticks([])
    axes.flat[2].set_xticks([])
    axes.flat[3].set_yticks([-0.5, 0, 0.5, 1])
    axes.flat[4].set_yticks([])
    axes.flat[5].set_yticks([])

    plt.tight_layout()
    plt.savefig(figure_save_path)
    plt.show()

def append_array_as_rows_to_csv(data_array, csv_file='output.csv'):
    # Transpose the data array so it has 10 rows and 2 columns
    transposed_data = np.transpose(data_array)
    
    # Create DataFrame with appropriate column names
    df_new = pd.DataFrame(transposed_data, columns=['Column_1', 'Column_2'])
    
    # Append or write to CSV file
    try:
        df_existing = pd.read_csv(csv_file)
        df_updated = pd.concat([df_existing, df_new], ignore_index=True)
    except FileNotFoundError:
        # If the file does not exist, start a new one
        df_updated = df_new
    
    df_updated.to_csv(csv_file, index=False)

if __name__ == "__main__":
    list1 = [
        [0, 1, 1, 0, 1],
        [1, 0, 0, 1, 0],
        [1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0],
        [1, 0, 0, 0, 0]
    ]
    matrix = Tp_matrix(list1, 2, 3)
    matrix.info()
    matrix.pre_len=3
    matrix.info()