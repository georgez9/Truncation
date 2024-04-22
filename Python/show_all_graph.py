import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# 创建示例数据
data = {
    'Group': ['Before TP'] * 12 + ['After TP'] * 12 + ['Across TP'] * 12,
    'Category': ['all matter', 'white matter', 'grey matter'] * 2 * 3,
    'Subcategory': ['actual', 'permuted'] * 9,
    'Value': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] * 3  # 示例数据，应根据实际情况替换
}

# 转换成DataFrame
df = pd.DataFrame(data)

# 绘制箱线图
plt.figure(figsize=(10, 6))
sns.boxplot(x='Group', y='Value', hue='Category', data=df)

# 为了更详细地区分子类别（"actual" vs. "permuted"），我们可以添加`dodge`参数
sns.boxplot(x='Group', y='Value', hue='Category', data=df, palette="Set3", dodge=True)

# 添加更多图表元素来提高可读性
plt.title('Boxplot Grouped by Group, Category, and Subcategory')
plt.ylabel('Values')
plt.xlabel('Group')
plt.legend(title='Category', loc='upper right')

plt.show()
