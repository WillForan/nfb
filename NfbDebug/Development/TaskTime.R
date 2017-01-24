library(dplyr)

MeanJitter <- function(Min, Max, Lambda) {
  term1 <- Lambda/(exp(-Lambda*Min) -  exp(-Lambda*Max))
  term2 <- Min*exp(-Lambda*Min) - Max*exp(-Lambda*Max)
  term3 <- exp(-Lambda*Min) - exp(-Lambda*Max)
  value <- term1*((1/Lambda)*term2 + (1/Lambda^2)*term3)
  value
}

BoundedExp <- function(Min, Max, Lambda, N) {
  e1 <- exp(-Lambda*Min)
  e2 <- exp(-Lambda*Max)
  samples <- (-1/Lambda * log(e1 - runif(N) * (e1 - e2)))
}

PossibleTimes <- expand.grid(
  TotalTrials = c(36*4, 32*4),
  TrialTime = c(16, 17, 18),
  MinJitter = c(0, 5, 10, 15, 20, 25)/60,
  MaxJitter = c(120, 180)/60) %>%
  arrange(TotalTrials, TrialTime, MinJitter, MaxJitter)

Lambda <- 60

PossibleTimes <- PossibleTimes %>%
  mutate(JitterSeconds = MeanJitter(MinJitter, MaxJitter, 1) * TotalTrials * 4, 
    TrialSeconds = TrialTime * TotalTrials,
    JitterMinutes = JitterSeconds / 60,
    TrialMinutes = TrialSeconds / 60,
    TotalSeconds = JitterSeconds + TrialSeconds,
    TotalMinutes = TotalSeconds / 60)

SelectedTimes <- PossibleTimes %>%
  filter(TotalMinutes <= 46 & TotalMinutes >= 42) %>%
  arrange(TotalMinutes)

write.csv(SelectedTimes, file="PossibleTimes.csv", quote=F, row.names=F)
  


BaseTrialDur <- 17
data <- read.csv("NfbDesign.csv")
MeanJitter <- mean(c(data$Jitter1Dur, data$Jitter2Dur, data$Jitter3Dur, data$Jitter4Dur))
data.time <- data %>%
  group_by(Run) %>%
  summarize(JitterSeconds = (sum(Jitter1Dur) + sum(Jitter2Dur) + sum(Jitter3Dur) + sum(Jitter4Dur))/60,
    TrialSeconds = BaseTrialDur*n(),
    TotalSeconds = JitterSeconds + TrialSeconds,
    Minutes = TotalSeconds/60)
TotalMinutes <- sum(data.time$Minutes)
    
