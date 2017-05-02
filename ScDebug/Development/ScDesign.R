library(tidyverse)
library(stringr)

set.seed(13)

design <- read_csv('TrialOrders.csv')
faces <- read_csv('FaceList.csv')
context <- read_csv('ContextList.csv')

# assign Context and Emotion as string columns
design.expand <- design %>%
  mutate(
    Context = case_when(
      .$Condition %in% c(1, 2, 3) ~ 'Pleasant',
      .$Condition %in% c(4, 5, 6) ~ 'Unpleasant'
    ),
    Emotion = case_when(
      .$Condition %in% c(1, 5) ~ 'Happy',
      .$Condition %in% c(2, 4) ~ 'Fearful',
      .$Condition %in% c(3, 6) ~ 'Neutral'
    )
  )

# assign Emotion and FaceNum to faces
faces.expand <- faces %>%
  mutate(
    Emotion = case_when(
      str_detect(.$FaceFile, "_F") ~ "Fearful",
      str_detect(.$FaceFile, "_N") ~ "Neutral",
      str_detect(.$FaceFile, "_H") ~ "Happy"
    ),
    FaceNum = str_sub(.$FaceFile, 1, 2)
  )

# assign conext images to runs 1 and 2 indicated by Order
context.order <- context %>%
  group_by(Context) %>%
  mutate(
    Index = sample(n()),
    Order = ifelse(Index <= n()/2, 1, 2)
  ) %>%
  ungroup() %>%
  select(-Index)

# duplicate design to put in the Order column  
design.expand <- replicate(2, design.expand, simplify = FALSE)
for (i in 1:2) {
  design.expand[[i]]$Order <- i
}
design.expand <- bind_rows(design.expand)

# replicate context images for each run
context.run <- replicate(5, context.order, simplify = FALSE)
for (i in 1:5) {
  context.run[[i]]$Run = i
}
context.run <- bind_rows(context.run)

# randomly assign context images to design by merging context images into design
# each merge key is randomly assign in context data frame by order, run, then context
design.expand <- design.expand %>%
  group_by(Order, Run, Context) %>%
  mutate(ContextMatch = 1:n()) %>%
  ungroup()

context.run <- context.run %>%
  group_by(Order, Run, Context) %>%
  mutate(ContextMatch = sample(n())) %>%
  ungroup()

design.expand <- left_join(design.expand, context.run, by=c("Order", "Run", "Context", "ContextMatch")) %>%
  select(-ContextMatch)

# replicate face iamges for each run
faces.run <- replicate(5, faces.expand, simplify = FALSE)
for (i in 1:5) {
  faces.run[[i]]$Run = i
}
faces.run <- bind_rows(faces.run)

# randomly assing face images to design
# this needs to be done in a way such that no FaceFiles from the same FaceNum follow each other
# make a used column to use when filtering
design.split <- design.expand %>% split(.$Order)
for (i in 1:2) {
  design.split[[i]] <- design.split[[i]] %>% split(.$Run)
}

for (iOrder in 1:2) {
  for (iRun in 1:5) {
    faces_to_use <- faces.run %>%
      filter(Order == iOrder, Run == iRun) %>%
      mutate(Index = 1:n(), CanUse = TRUE)

    # now go through each order/run and assign faces to each observation
    design.split[[iOrder]][[iRun]] <- design.split[[iOrder]][[iRun]] %>%
      mutate(
        FaceFile = NA_character_,
        FaceNum = NA_character_,
        Gender = NA_character_
      )

    n_obs <- nrow(design.split[[iOrder]][[iRun]])
    for (iObs in 1:n_obs) {
      # we need to assign the observarion emotion to a variable; otherwise,
      # things mess up in filter. We could use lazyeval, but this is much
      # lazier.
      obs_emotion <- design.split[[iOrder]][[iRun]]$Emotion[iObs]
      faces_for_obs <- faces_to_use %>%
        filter(
          Emotion == obs_emotion,
          CanUse
        )
          
      index_samp <- base::sample(faces_for_obs$Index, size = 1)
      
      if (iObs != 1 && iObs != nrow(design.split[[iOrder]][[iRun]])) {
        if (all(faces_to_use$FaceNum[index_samp] == faces_to_use$FaceNum)) {
          stop("All avaible faces are the same. Try a different seed.")
        }

        while(faces_to_use$FaceNum[index_samp] == design.split[[iOrder]][[iRun]]$FaceNum[iObs - 1]) {
          index_samp <- base::sample(faces_for_obs$Index, size = 1)
        }
      }

      design.split[[iOrder]][[iRun]]$FaceFile[iObs] <- faces_to_use$FaceFile[index_samp]
      design.split[[iOrder]][[iRun]]$Gender[iObs] <- faces_to_use$Gender[index_samp]
      design.split[[iOrder]][[iRun]]$FaceNum[iObs] <- faces_to_use$FaceNum[index_samp]

      faces_to_use$CanUse[index_samp] <- FALSE
    }

    if(design.split[[iOrder]][[iRun]]$FaceNum[n_obs] == 
       design.split[[iOrder]][[iRun]]$FaceNum[n_obs - 1]
    ) {
      stop("Last two trials have face from same person. Try a different seed.")
    }
  }
}

design.full <- map(design.split, bind_rows)
design.full <- bind_rows(design.full)

write_csv(design.full, "ScDesign.csv")    
