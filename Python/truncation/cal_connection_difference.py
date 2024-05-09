import json
import numpy as np
import pandas as pd
from adjacency_matrix import Tp_matrix, find_submatrix, calculate_DBA_DAA, save_DBA_DAA, save_connectivity, plot_dba_daa


permutation_times_default = 100

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

    # matter_type_list = ["all", "white", "grey"]
    matter_type_list = ["all"]
    # permute_type_list = ["ac", "pt", "pr"]
    permute_type_list = ["pr"]
    # using_method = ["gd", "lcc"]
    using_method = ["lcc"]

    for method in using_method:

        dba_daa_csv_save_path = f'output_data/dba_daa_{method}.csv'
        figure_save_path = f'figures/dba_daa_{method}.svg'
        
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

                connectivity_list = []
                DBA_DAA_list = []
                hemisphere_list = []

                test_list = []

                for seizure in seizures:
                    id = seizure.get("id")
                    patient_id = seizure.get("patient_id")
                    regions = seizure.get("regions")
                    pre_len = len(seizure.get("regions_bf_tp"))
                    post_len = len(seizure.get("regions_af_tp"))
                    matrix = find_submatrix(regions, map_labels, maps)

                    hemisphere = seizure.get("hemisphere")
                    hemisphere_list.append(hemisphere)
                    seizure_matrix = Tp_matrix(matrix, pre_len, post_len, regions, hemisphere, id, patient_id, matter_type)

                    if method == "gd":
                        connectivity = seizure_matrix.calculate_graph_density(permute_type, permutation_times_default)
                    elif method == "lcc":
                        connectivity = seizure_matrix.calculate_largest_connected_component(permute_type, permutation_times_default)
                    
                    # test_list.append([round(connectivity[2], 3), round(seizure_matrix.pre_len/(seizure_matrix.pre_len+seizure_matrix.post_len), 2)])

                    if permute_type == "ac":
                        connectivity_list.append(connectivity)
                    DBA_DAA_list.append(calculate_DBA_DAA(connectivity))

                if connectivity_list:
                    save_connectivity(connectivity_list, f'output_data/connectivity_{method}.csv', matter_type, hemisphere_list)
                save_DBA_DAA(DBA_DAA_list, dba_daa_csv_save_path, matter_type, permute_type, hemisphere_list)

                # write_file = pd.read_csv('testpt.csv')
                # test_list = np.array(test_list)
                # write_file["intec"] = test_list[:,0]
                # write_file["position"] = test_list[:,1]
                # write_file.to_csv('testpt.csv', index=False)

        plot_dba_daa(dba_daa_csv_save_path, figure_save_path)
