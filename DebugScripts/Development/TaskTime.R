library(dplyr)

MeanJitter <- function(Min, Max, Lambda) {
  term1 <- Lambda/(exp(-Lambda*Min) -  exp(-Lambda*Max))
  term2 <- Min*exp(-Lambda*Min) - Max*exp(-Lambda*Max)
  term3 <- exp(-Lambda*Min) - exp(-Lambda*Max)
  value <- term1*((1/Lambda)*term2 + (1/Lambda^2)*term3)
}

BoundedExp <- function(Min, Max, Lambda, N) {
  e1 <- exp(-Lambda*Min)
  e2 <- exp(-Lambda*Max)
  samples <- (-1/Lambda * log(e1 - runif(N) * (e1 - e2)))
}

# PossibleTimes <- expand.grid(
#   TotalTrials = c(36*4, 32*4)
#   MinJitter = c(0, 5, 10, 15, 20, 25)
#   MaxJitter = c(2)
#   TrialTime = c(16, 17, 18)


BaseTrialDur <- 16
data <- read.csv("Design.csv")
MeanJitter <- mean(c(data$Jitter1Dur, data$Jitter2Dur, data$Jitter3Dur, data$Jitter4Dur))
data.time <- data %>%
  group_by(Run) %>%
  summarize(Seconds = (sum(Jitter1Dur) + sum(Jitter2Dur) + sum(Jitter3Dur) + sum(Jitter4Dur))/60 + 18*n(),
    Minutes = Seconds/60)
TotalMinutes <- sum(data.time$Minutes)
    