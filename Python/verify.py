import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
 
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
        # fill=False,
        # aspect=1,
        # height=5,
        palette=cmap1,
        ax=axes.flat[location],
        # palette='dark:black',
        gap = .2,
        # jitter=0.3
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



def plot_dba_daa(save_path):
    _, axes = plt.subplots(2, 3, figsize=([10, 6]))
    plot_df = pd.read_csv(save_path)

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

# plot_dba_daa('../data/dba_daa_lcc_python.csv')
# plt.savefig('pictures/dba_daa_lcc.svg')
# plt.show()


