library(tidyverse)

set.seed(1234567890)

design <- read.csv('TrialOrders.csv')
faces <- read.csv('FaceList.csv')
context <- read.csv('ContextList.csv')

design.expand <- design %>%
  mutate(Context=ifelse(Condition %in% c(1, 2, 3), 'Pleasant', NA),
    Context=ifelse(Condition %in% c(4, 5, 6), 'Unpleasant', Context),
    Emotion=ifelse(Condition %in% c(1, 5), 'Happy', NA),
    Emotion=ifelse(Condition %in% c(2, 4), 'Fearful', Emotion),
    Emotion=ifelse(Condition %in% c(3, 6), 'Neutral', Emotion))

faces.expand <- faces %>%
  mutate(Emotion=ifelse(grepl("_F", FaceFile), "Fearful", NA),
    Emotion=ifelse(grepl("_N", FaceFile), "Neutral", Emotion),
    Emotion=ifelse(grepl("_H", FaceFile), "Happy", Emotion))

context.order <- context %>%
  group_by(Context) %>%
  mutate(Index = sample(n()),
    Order = ifelse(Index <= n()/2, 1, 2)) %>%
  ungroup() %>%
  select(-Index)
  

design.order <- data.frame()
for (i in c(1, 2)) {
  design.expand$Order <- i
  design.order <- bind_rows(design.order, design.expand)
}

faces.run <- data.frame()
for (i in c(1, 2, 3, 4, 5)) {
  faces.expand$Run <- i
  faces.run <- bind_rows(faces.run, faces.expand)
}

context.run <- data.frame()
for (i in c(1, 2, 3, 4, 5)) {
  context.order$Run <- i
  context.run <- bind_rows(context.run, context.order)
}

design.order <- design.order %>%
  group_by(Order, Run, Emotion) %>%
  mutate(FaceMatch = 1:n()) %>%
  ungroup()

faces.run <- faces.run %>%
  group_by(Order, Run, Emotion) %>%
  mutate(FaceMatch = sample(n())) %>%
  ungroup()

design.faces <- left_join(design.order, faces.run, by=c("Order", "Run", "Emotion", "FaceMatch")) %>%
  select(-FaceMatch)

design.faces <- design.faces %>%
  group_by(Order, Run, Context) %>%
  mutate(ContextMatch = 1:n()) %>%
  ungroup()

context.run <- context.run %>%
  group_by(Order, Run, Context) %>%
  mutate(ContextMatch = sample(n())) %>%
  ungroup()

design.sc <- left_join(design.faces, context.run, by=c("Order", "Run", "Context", "ContextMatch")) %>%
  select(-ContextMatch)

write.csv(design.sc, file="ScDesign.csv", quote=F, row.names=F)
