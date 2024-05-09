from adjacency_matrix import Tp_matrix, find_submatrix, calculate_DBA_DAA, save_DBA_DAA
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from verify import plot_dba_daa

display_graph = True

using_method = "gd" # gd - graph density, lcc - largest connected component
permutation_times_default = 1000

# load files
map_labels = pd.read_csv(r"..\data\connection_map_labels.csv", header=None)[0].to_numpy(dtype='U30')
map_white_matters = pd.read_csv(r"..\data\connection_map_white_matter.csv", header=None).to_numpy(dtype=int)
map_grey_matters = pd.read_csv(r"..\data\connection_map_grey_matter.csv", header=None).to_numpy(dtype=int)
map_all_matters = map_white_matters + map_grey_matters
map_all_matters[map_all_matters > 0] = 1
df = pd.read_csv(r"..\data\seizure_regions.csv")
dba_daa_csv_save_path = f'../data/dba_daa_{using_method}_python.csv'

matter_type_list = ["all", "white", "grey"]
permute_type_list = ["ac", "pt", "pr"]

for matter_type in matter_type_list:
    for permute_type in permute_type_list:
        if matter_type == "white":
            maps = map_white_matters
        elif matter_type == "grey":
            maps = map_grey_matters
        elif matter_type == "all":
            maps = map_all_matters
        # delete self connection
        for i in range(len(maps)):
            maps[i][i] == 0

        seizure_ids = np.unique(np.array(df['ID']))
        # print(f'seizure number: {len(seizure_ids)}')

        DBA_DAA_list = []
        hemisphere_list = []

        for seizure_id in seizure_ids:
            patient_id = df['PatientID'].to_numpy(dtype='U30')[0]
            seizure_df = df[df['ID'] == seizure_ids[seizure_id-1]]
            labels = seizure_df['Labels'].to_numpy(dtype='U30')
            pre_len = seizure_df['LabelsBeforeTP'].notna().sum()
            post_len = seizure_df['LabelsAfterTP'].notna().sum()
            matrix = find_submatrix(labels, map_labels, maps)
            hemisphere = seizure_df['Hemisphere'].to_numpy(dtype='U30')[0]
            hemisphere_list.append(hemisphere)
            seizure_matrix = Tp_matrix(matrix, pre_len, post_len, labels, hemisphere, seizure_id, patient_id, matter_type)

            if using_method == "gd":
                DBA_DAA_list.append(calculate_DBA_DAA(seizure_matrix.calculate_graph_density(permute_type, permutation_times_default)))
            elif using_method == "lcc":
                DBA_DAA_list.append(calculate_DBA_DAA(seizure_matrix.calculate_largest_connected_component(permute_type, permutation_times_default))) 


        save_DBA_DAA(DBA_DAA_list, dba_daa_csv_save_path, matter_type, permute_type, hemisphere_list)

plot_dba_daa(dba_daa_csv_save_path)
plt.savefig('pictures/dba_daa_gd.svg')
plt.show()