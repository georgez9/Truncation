import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

def prepare_and_plot(df, column_suffix, matter_type, y_label, color_map, method):
    cols = [f'BTP_{column_suffix}', f'ATP_{column_suffix}', f'ACTP_{column_suffix}', 'Hemisphere']
    df_filtered = df[cols].copy()
    df_filtered.columns = ['BTP', 'ATP', 'ACTP', 'Hemisphere']
    df_filtered['Matter type'] = matter_type
    df_long = pd.melt(df_filtered, id_vars=['Matter type', 'Hemisphere'], value_name='Connectivity', var_name='Area')
    sns.catplot(
        data=df_long, kind="violin",
        x='Area', y='Connectivity', hue='Hemisphere',
        inner=None, fill=False, legend=False,
        density_norm="count", common_norm=True, palette='dark:black',
        aspect=3.6, height=3, linewidth=1
    )
    sns.swarmplot(
        data=df_long, x='Area', y='Connectivity', hue='Hemisphere', 
        dodge=True, size=5, edgecolor='black', linewidth=1, legend=False, palette=color_map
    )
    plt.ylabel(y_label)
    plt.title(method)
    plt.savefig(f'figures/connectivity/{method}/{matter_type}_{method}.svg')

if __name__ == "__main__":
    method_list = ["gd", "lcc"]
    for method in method_list:
        file_path = f'output_data/connectivity_{method}.csv'
        df = pd.read_csv(file_path)

        cmap = ["#F7CB67", '#6E6A91', '#7899BC']

        prepare_and_plot(df, 'all', 'All', 'AM Connectivity', cmap, method)
        prepare_and_plot(df, 'white', 'White', 'WM Connectivity', cmap, method)
        prepare_and_plot(df, 'grey', 'Grey', 'GM Connectivity', cmap, method)

        plt.show()
    