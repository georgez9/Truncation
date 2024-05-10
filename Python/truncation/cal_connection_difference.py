import json
import csv
import os
import numpy as np
import pandas as pd
from adjacency_matrix import Tp_matrix, find_submatrix, calculate_DBA_DAA, save_DBA_DAA, save_connectivity, plot_dba_daa

permutation_times_default = 1000
matter_type = "all"


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

    matter_type_list = ["all", "white", "grey"]
    matter_type_list = [matter_type]

    permute_type_list = ["ac", "pt", "pr"]
    connection_type_list = ["gd", "lcc"]
    
    # clear the permutation .csv file
    file_path = os.path.join('output_data', 'permute_results.csv')
    with open(file_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['id', 'patient_id', 'permute_type', 'connection_type', 'BTP', 'ATP', 'ACTP'])

    for connection in connection_type_list:

        dba_daa_csv_save_path = f'output_data/dba_daa_{connection}.csv'
        figure_save_path = f'figures/dba_daa_{connection}.svg'
        
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

                    if pre_len > 1 and post_len > 1:
                        seizure_matrix.permutation(permutation_times_default, permute_type, connection)

                    # if method == "gd":
                    #     connectivity = seizure_matrix.calculate_graph_density(permute_type, permutation_times_default)
                    # elif method == "lcc":
                    #     connectivity = seizure_matrix.calculate_largest_connected_component(permute_type, permutation_times_default)
                    
                    # test_list.append([round(connectivity[2], 3), round(seizure_matrix.pre_len/(seizure_matrix.pre_len+seizure_matrix.post_len), 2)])

                #     if permute_type == "ac":
                #         connectivity_list.append(connectivity)
                #     DBA_DAA_list.append(calculate_DBA_DAA(connectivity))

                # if connectivity_list:
                #     save_connectivity(connectivity_list, f'output_data/connectivity_{connection}.csv', matter_type, hemisphere_list)
                # save_DBA_DAA(DBA_DAA_list, dba_daa_csv_save_path, matter_type, permute_type, hemisphere_list)

        # plot_dba_daa(dba_daa_csv_save_path, figure_save_path)
