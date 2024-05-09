import numpy as np
import json

def classify_labels(labels):
    right_cond = np.vectorize(lambda x: x.startswith('r.') or x.startswith('Right'))
    right_labels = right_cond(labels)
    
    left_cond = np.vectorize(lambda x: x.startswith('l.') or x.startswith('Left'))
    left_labels = left_cond(labels)
    
    if all(right_labels) and not any(left_labels):
        return "right"
    elif all(left_labels) and not any(right_labels):
        return "left"
    elif any(right_labels) and any(left_labels):
        return "both"
    else:
        return "none"


if __name__ == "__main__":
    with open('output_data/combined_seizures.json', 'r', encoding='utf-8') as f:
        seizures = json.load(f)
    ts_size = len(seizures)

    save_json = []

    for id in range(ts_size):

        seizure = seizures[id]
        tp = seizure.get("truncation_point")
        eeg = np.array(seizure.get("continuing_seizure"))
        labels = np.array(seizure.get("labels"))
        regions_bf_tp_indices = np.where(eeg[:, tp] == 1)[0]
        regions_af_tp_indices = np.where(eeg[:, eeg.shape[1]-1] == 1)[0]
        regions_no_indices = np.where(eeg[:, eeg.shape[1]-1] == 0)[0]
        regions_af_tp_indices = np.setdiff1d(regions_af_tp_indices, regions_bf_tp_indices)

        regions_bf_tp = labels[regions_bf_tp_indices]
        regions_af_tp = labels[regions_af_tp_indices]
        regions_no = labels[regions_no_indices]
        hemisphere = classify_labels(labels)

        

        # save to json file
        dict_json = dict()
        dict_json["id"] = id+1
        dict_json["patient_id"] = seizure.get("patient_id")
        dict_json["truncation_point"] = int(tp)
        dict_json["regions"] = labels.tolist()
        dict_json["hemisphere"] = hemisphere
        dict_json["regions_bf_tp"] = regions_bf_tp.tolist()
        dict_json["regions_af_tp"] = regions_af_tp.tolist()
        dict_json["regions_no"] = regions_no.tolist()

        save_json.append(dict_json)

    # save to json file
    with open('output_data/truncation_labels.json', 'w') as f:
        json.dump(save_json, f)