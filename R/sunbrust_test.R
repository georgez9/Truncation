library(sunburstR)
library(d3r)

dat <- data.frame(
  level1 = rep(c("base1", "base2"), each=3),
  level2 = c("child1", "child2", "child3","child3", "child2", "child1"),
  size = c(1,7,7,7,42,4),
  stringsAsFactors = FALSE
)

# 转换数据为层次结构
tree <- d3_nest(dat, value_cols = "size")


# colors
colors <- c("#F7CB67",
            "#6E6A91",
            "#CA8BB5",
            "#7899BC",
            "#2D5C87"
            )
# match those colors to leaf names, matched by index
labels <- c("base1", "base2", "child1","child2","child3")


sunburst(tree, 
         colors = list(range = colors, domain = labels),
         width="100%", height=500, legend = FALSE)
