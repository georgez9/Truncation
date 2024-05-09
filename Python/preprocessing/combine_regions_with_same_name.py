from collections import defaultdict
from truncated_vs_continuing import plot_truncated_vs_continuing

import numpy as np
import json

def index_positions(array):
    result = defaultdict(list)
    
    for index, value in enumerate(array):
        result[value].append(index)
    
    return result

if __name__ == "__main__":

    with open('data/truncated_seizures.json', 'r', encoding='utf-8') as f:
        truncated_seizures = json.load(f)

    save_json = []
    ts_size = len(truncated_seizures)
    for id in range(ts_size):

        ts = truncated_seizures[id]
        patient_id = ts.get("patient_id")
        tp = ts.get("truncation_point")

        truncated_seizure = np.array(ts.get("truncated_seizure")).astype(int)
        if truncated_seizure.ndim == 1:
            zero_column = np.zeros((truncated_seizure.shape[0], 1), dtype=truncated_seizure.dtype)
            truncated_seizure = np.hstack((truncated_seizure.reshape(-1, 1), zero_column))

        continuing_seizure = np.array(ts.get("continuing_seizure")).astype(int)
        labels = np.array(ts.get("channel_ROI_labels"))
        combine_dict = index_positions(labels)

        label_indices = list(combine_dict.values())
        combined_labels = list(combine_dict.keys())
        combined_sequence_continuing = []
        combined_sequence_truncated = []
        for i in label_indices:
            sequence_continuing = np.zeros(continuing_seizure[0].shape)
            sequence_truncated = np.zeros(truncated_seizure[0].shape)
            for j in i:
                sequence_continuing = sequence_continuing+continuing_seizure[j]
                sequence_truncated = sequence_truncated+truncated_seizure[j]
            combined_sequence_continuing.append(sequence_continuing)
            combined_sequence_truncated.append(sequence_truncated)
        combined_sequence_continuing = np.array(combined_sequence_continuing)
        combined_sequence_truncated = np.array(combined_sequence_truncated)
        combined_labels = np.array(combined_labels)

        combined_sequence_truncated[combined_sequence_truncated>0] = 1
        combined_sequence_continuing[combined_sequence_continuing>0] = 1

        # fill the gaps
        for row in combined_sequence_continuing:
            for i in range(len(row)):
                if row[i] == 1:
                    row[i:] = 1
                    break
        
        # sort
        first_one_indices = []
        for row in combined_sequence_continuing:
            # find the first 1
            index = np.where(row == 1)[0]
            if index.size > 0:
                first_one_indices.append(index[0])
            else:
                first_one_indices.append(len(row))

        first_one_indices = np.array(first_one_indices)

        sorted_indices = np.argsort(first_one_indices)

        combined_sequence_continuing = combined_sequence_continuing[sorted_indices]
        combined_sequence_truncated = combined_sequence_truncated[sorted_indices]
        combined_labels = combined_labels[sorted_indices]
        

        # save to json file
        dict_json = dict()
        dict_json["id"] = id+1
        dict_json["patient_id"] = patient_id
        dict_json["truncation_point"] = int(tp)
        dict_json["labels"] = combined_labels.tolist()
        dict_json["continuing_seizure"] = combined_sequence_continuing.tolist()

        save_json.append(dict_json)

        # plot
        plot_truncated_vs_continuing('figures/combined_truncated_vs_continuing',combined_sequence_truncated, 
                                    combined_sequence_continuing, combined_labels, id, patient_id, tp)


    # save to json file
    with open('output_data/combined_seizures.json', 'w') as f:
        json.dump(save_json, f)

