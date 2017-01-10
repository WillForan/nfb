clear all;
rng(1234567890);

% 18 trials each of 1,2,3,4 (A,B,C,D)
% 15 1,3 positive
% 3 1,3 baseline
% 10 2,4 positive
% 8 2,4 baseline

AllTrials = repmat([1 2 3 4], 1, 18);

AllTrials = AllTrials(randperm(length(AllTrials)));
