import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


file_path = '../data/actual_connectivity.csv'
df = pd.read_csv(file_path)

df_0 = df[['BTP_all', 'ATP_all', 'ACTP_all', 'Hemisphere']].copy()
df_0.columns = ['BTP', 'ATP', 'ACTP', 'Hemisphere']
df_0.loc[:, 'Matter type'] = 'All'
df_0_long = pd.melt(df_0, id_vars=['Matter type', 'Hemisphere'], value_name='Connectivity', var_name='Area')
df_1 = df[['BTP_white', 'ATP_white', 'ACTP_white', 'Hemisphere']].copy()
df_1.columns = ['BTP', 'ATP', 'ACTP', 'Hemisphere']
df_1.loc[:, 'Matter type'] = 'White'
df_1_long = pd.melt(df_1, id_vars=['Matter type', 'Hemisphere'], value_name='Connectivity', var_name='Area')
df_2 = df[['BTP_grey', 'ATP_grey', 'ACTP_grey', 'Hemisphere']].copy()
df_2.columns = ['BTP', 'ATP', 'ACTP', 'Hemisphere']
df_2.loc[:, 'Matter type'] = 'Grey'
df_2_long = pd.melt(df_2, id_vars=['Matter type', 'Hemisphere'], value_name='Connectivity', var_name='Area')

df_long = pd.concat([df_0_long, df_1_long, df_2_long], ignore_index=True)
print(df_long.head())

cmap = ["#F7CB67", '#6E6A91','#7899BC']
sns.catplot(
    data=df_1_long, kind="violin",
    x='Area', y='Connectivity', hue='Hemisphere',
    inner=None,
    fill=False,
    legend=False,
    density_norm="count",
    common_norm = True,
    palette='dark:black',
    aspect=3.6,
    height=3,
    linewidth=1,
    # height=5,
    # width=20,
)
sns.swarmplot(data=df_1_long, x='Area', y='Connectivity', hue='Hemisphere', 
              dodge=True, 
              size=5,
              edgecolor='black',
              linewidth=1,
              legend=False,
              palette=cmap,
)

plt.savefig('connectivity.svg')
plt.show()