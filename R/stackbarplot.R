library(ggplot2)
library(ggbeeswarm)

# 创建数据集
specie <- c(rep("Actual", 4), rep("Permuted", 4))
Proportion <- c(0.02, 0.23, 0.25, 0.5, 0.02, 0.23, 0.25, 0.5)
data <- data.frame(specie, condition, Proportion)

#data1
Actual <-   c(0.00,0.93,0.84,0.80,0.00,0.25,0.00,0.69,0.59,0.56,0.00,0.70,0.33,
              0.00,0.30,0.00,0.22,0.60,0.00,0.60,0.62,0.53,0.00,0.00,0.00,0.97,
              0.00,0.00,0.48,1.00,0.72,0.00,0.00,0.00,0.00,0.03,0.03,0.00,0.35,
              0.00,0.00,0.00,0.17,0.00,0.54,0.00,0.50,0.89,0.00,0.46,0.76,0.07,
              0.57,0.12,0.14,1.00)

Permuted <- c(0.57,0.50,0.49,0.49,0.21,0.51,0.48,0.48,0.50,0.51,0.51,0.50,0.52,
              0.25,0.52,0.53,0.52,0.50,0.50,0.45,0.44,0.51,0.48,0.38,0.38,0.50,
              0.48,0.50,0.50,0.54,0.55,0.51,0.52,0.44,0.20,0.52,0.51,0.52,0.52,
              0.53,0.20,0.50,0.50,0.46,0.51,0.23,0.53,0.53,0.50,0.51,0.55,0.48,
              0.49,0.49,0.52,0.72
)

data1 <- data.frame(
  value = c(Actual, Permuted),
  specie = rep(c("Actual", "Permuted"), each=length(Actual))
)

data1$ValueRange <- cut(data1$value, breaks=c(-Inf, 0.01, 0.25, 0.5, Inf), labels=c("0", "0-25%", "25%-50%","50%-100%"))


# 绘制堆叠柱状图，只显示边框
ggplot() + 
  geom_bar(data=data, aes(fill=condition, y=Proportion, x=specie), position="stack", stat="identity", width=0.5, color="black", fill=NA) +
  geom_beeswarm(data=data1, aes(x=specie, y=value, color=ValueRange), size = 2, alpha=0.7)+
  scale_color_manual(values=c("0"="#FF6666", "0-25%"="#99cccc", "25%-50%"="#336699", "50%-100%"="#000000")) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 12), 
    axis.text.y = element_text(size = 12), 
    axis.title.x = element_blank(), # 去除X轴标题
    axis.title.y = element_text(size = 12),
    axis.ticks.x = element_line(),
    axis.ticks.y = element_line(),
    panel.grid.major = element_blank(), # 去除主要网格线
    panel.grid.minor = element_blank(), # 去除次要网格线
    axis.line.x = element_line(), # X轴箭头
    axis.line.y = element_line(),  # Y轴箭头
    legend.position = "none"
  )






########################################################################

library(ggplot2)

# create a dataset
specie <- c(rep("Actual" , 4) , rep("Permuted" , 4) )
condition <- rep(c("0" , "0-25%" , "25%-50%", "50%-100%") , 2)
Proportion <- c(23, 7, 6, 20, 0.1, 4, 16, 36)
#value <- c(20, 6, 7, 23, 36, 16, 4, 0.1)
data <- data.frame(specie,condition,Proportion)

# 绘制堆叠柱状图
ggplot(data, aes(fill=condition, y=Proportion, x=specie)) + 
  geom_bar(position="fill", stat="identity", width=0.5) + # 调整宽度
  scale_y_reverse() +
  scale_fill_manual(values=c("0"="#FF6666", "0-25%"="#99cccc", "25%-50%"="#336699", "50%-100%"="#000000")) + # 手动调整颜色
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 12), # 调整X轴文字角度并改善显示，设置字号
    axis.text.y = element_blank(),
    axis.title.x = element_blank(), # 去除X轴标题
    axis.title.y = element_text(size = 12),
    axis.ticks.x = element_line(),
    panel.grid.major = element_blank(), # 去除主要网格线
    panel.grid.minor = element_blank(), # 去除次要网格线
    axis.line.x = element_line(), # X轴箭头
    axis.line.y = element_line(),  # Y轴箭头
    legend.title = element_blank()
  )

