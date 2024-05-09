import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import json

def plot_truncated_vs_continuing(path, truncated_seizure, continuing_seizure, labels, id, patient_id, tp):
    left_len = truncated_seizure.shape[1]
    right_len = continuing_seizure.shape[1]
    total_len = right_len+left_len
    plt.rcParams['font.family'] = 'Arial' 
    plt.rcParams['font.size'] = 8
    plt.figure(figsize=(15, 10))
    plt.subplot2grid((1, total_len+total_len//15), (0, 0), colspan=left_len)
    plt.title(f"{id+1}_{patient_id}")
    sns.heatmap(
        truncated_seizure,
        yticklabels=labels,
        cbar=None
        )
    plt.xlabel("Truncated seizure")
    plt.subplot2grid((1, total_len+total_len//15), (0, left_len+total_len//15), colspan=right_len)
    sns.heatmap(
        continuing_seizure,
        yticklabels=False,
        cbar=None
        )
    plt.xlabel("Continuing seizure")
    plt.axvline(x=tp, color='red', linestyle='--', linewidth=1)
    plt.savefig(f'{path}/{id+1}_{patient_id}.png', dpi=300)
    plt.close()

if __name__ == "__main__":
    with open('data/truncated_seizures.json', 'r', encoding='utf-8') as f:
        truncated_seizures = json.load(f)

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
        
        # sort
        sorted_indices = np.argsort(labels)
        labels = labels[sorted_indices]
        truncated_seizure = truncated_seizure[sorted_indices]
        continuing_seizure = continuing_seizure[sorted_indices]

        path = 'figures/original_truncated_vs_continuing'
        
        plot_truncated_vs_continuing(path, truncated_seizure, continuing_seizure, labels, id, patient_id, tp)


