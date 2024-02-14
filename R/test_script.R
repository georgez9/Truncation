library(ggplot2)
library(tidyr)
library(dplyr)
# read csv
data <- read.csv('selected_columns.csv')
print(data)
data_long <- data %>%
  pivot_longer(cols = c("before_tp_contiguous", "after_tp_contiguous", "truncation_tp_contiguous"), names_to = "Variable", values_to = "Value") %>%
  mutate(Variable = factor(Variable, levels = c("before_tp_contiguous", "after_tp_contiguous", "truncation_tp_contiguous"), labels = c("Before truncation points", "After truncation points", "Across truncation points")))

ggplot(data_long, aes(x = Variable, y = Value, fill = Variable)) +
  geom_violin(trim = TRUE) +
  geom_point(position = position_jitter(width = 0.15), alpha=0.5, size=1) +
  theme_minimal() +
  theme(axis.title.x = element_blank()) + 
  labs(title = "Matter connectivity distribution", y = "Connectivity")+
  theme(plot.title = element_text(hjust = 0.5))
  ylim(0, 1)

############################################################
data_long <- data %>%
  pivot_longer(cols = c("permutation_before_tp_contiguous", "permutation_after_tp_contiguous", "permutation_truncation_tp_contiguous"), names_to = "Variable", values_to = "Value") %>%
  mutate(Variable = factor(Variable, levels = c("permutation_before_tp_contiguous", "permutation_after_tp_contiguous", "permutation_truncation_tp_contiguous"), labels = c("Before truncation points", "After truncation points", "Across truncation points")))

ggplot(data_long, aes(x = Variable, y = Value, fill = Variable)) +
  geom_violin(trim = FALSE) +
  geom_point(position = position_jitter(width = 0.15), alpha=0.5, size=1) +
  theme_minimal() +
  theme(axis.title.x = element_blank()) + 
  labs(title = "Matter connectivity distribution", y = "Connectivity")+
  theme(plot.title = element_text(hjust = 0.5))+
  ylim(0, 1)
############################################################
data_long <- data %>%
  pivot_longer(cols = c("CDP", "CDN", "permutation_CDP", "permutation_CDN"), names_to = "Variable", values_to = "Value") %>%
  mutate(Group = case_when(
    grepl("permutation", Variable) ~ "Permutation",
    TRUE ~ "Original"
  ))

data_long$Position <- factor(data_long$Variable, levels = c("CDP", "CDN", "permutation_CDP", "permutation_CDN"), , labels = c("CDP", "CDN", "Permutation CDP", "Permutation CDN"))
# 设置位置调整的宽度
dodge_width <- position_dodge(width = 0.5) # 控制同组的两个图的靠近程度

ggplot(data_long, aes(x = Position, y = Value, fill = Group)) +
  geom_boxplot(position = dodge_width, width = 0.4, alpha = 0.3) + # 使用dodge_width来调整箱线图的位置
  geom_point(aes(color = Group), position = position_jitterdodge(jitter.width = 0.2, dodge.width = 0.1), alpha = 0.9) +
  theme_bw() +
  labs(title = "Matter connectivity difference", y = "Difference") +
  theme(legend.title = element_blank(), axis.title.x = element_blank(), plot.title = element_text(hjust = 0.5)) +
  ylim(-1, 1)

