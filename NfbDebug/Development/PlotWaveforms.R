library(tidyverse)

data <- read.csv("Waveforms.csv")
dataPoints <- data %>%
  group_by(Number, Section) %>%
  summarize(Time=Time[n()], Value=Value[n()])

p <- ggplot(data, aes(x=Time, y=Value))
AllPlot <- p + geom_line(aes(color=factor(Number))) + 
  facet_grid(factor(Run) ~ .)
FacetPlot <- p + 
  geom_line(aes(color=factor(Section))) +
  facet_grid(factor(Number) ~ factor(Run))
