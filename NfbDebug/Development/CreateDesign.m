clear all;
rng(1234567890);

% 4 runs
%   32 trials per run
%   8 trials for each condition in 1 run
%       7 1,3 positive
%       1 1,3 baseline
%       6 2,4 positive
%       2 2,4 baseline
% 8 trials of each (1, 2, 3, 4)

NumRuns = 4;
NumTrials = 32;
Trials = [1 2 3 4];
Possible = PrintAllPermutations(Trials);
TrialBlocks = NumTrials / length(Trials);
UniquePositive = 7;
UniqueBaseline = 6;
NumBaseAC = TrialBlocks - UniquePositive;
NumPosBD = TrialBlocks - UniqueBaseline;
NumJitters = 2;

fid = fopen('NfbDesign.csv', 'w');
fprintf(fid, 'Run,');
fprintf(fid, 'TrialNum,');
fprintf(fid, 'Infusion,');
fprintf(fid, 'Feedback,');
fprintf(fid, 'Waveform,');
fprintf(fid, 'Jitter1,');
fprintf(fid, 'Jitter2\n');

for i = 1:NumRuns

    % get trial order
    Blocks = randperm(size(Possible, 1), TrialBlocks);
    RunTrials = Possible(Blocks, :);
    RunTrials = RunTrials';
    RunTrials = RunTrials(:);

    % make 2 exponentially distributed distributions
    lambda = 1/60;
    c1 = 20;
    c2 = 120;
    e1 = exp(-lambda*c1);
    e2 = exp(-lambda*c2);
    Jitter = floor(-1/lambda * log(e1-rand(NumTrials, NumJitters)*(e1-e2)));
    Jitter(randi(NumTrials, 1), 1) = randi([240 420], 1);
    Jitter(randi(NumTrials, 1), 2) = randi([240 420], 1);

    % assign waveforms
    Waveforms = zeros(NumTrials, 1);
    Feedback = zeros(NumTrials, 1);

    ProtALoc = find(RunTrials == 1);
    ProtAPosLoc = ProtALoc(randperm(length(ProtALoc), UniquePositive));
    ProtABaseLoc = setdiff(ProtALoc, ProtAPosLoc);
    Waveforms(ProtAPosLoc) = randperm(UniquePositive);
    Feedback(ProtAPosLoc) = 1;
    Waveforms(ProtABaseLoc) = randperm(UniqueBaseline, NumBaseAC);
    Feedback(ProtABaseLoc) = 2;

    ProtCLoc = find(RunTrials == 3);
    ProtCPosLoc = ProtCLoc(randperm(length(ProtCLoc), UniquePositive));
    ProtCBaseLoc = setdiff(ProtCLoc, ProtCPosLoc);
    Waveforms(ProtCPosLoc) = randperm(UniquePositive);
    Feedback(ProtCPosLoc) = 1;
    UsedBase = Waveforms(ProtABaseLoc);
    Waveforms(ProtCBaseLoc) = UsedBase(randperm(length(UsedBase)));
    Feedback(ProtCBaseLoc) = 2;

    ProtBLoc = find(RunTrials == 2);
    ProtBPosLoc = ProtBLoc(randperm(length(ProtBLoc), NumPosBD));
    ProtBBaseLoc = setdiff(ProtBLoc, ProtBPosLoc);
    Waveforms(ProtBPosLoc) = randperm(UniquePositive, NumPosBD);
    Feedback(ProtBPosLoc) = 1;
    Waveforms(ProtBBaseLoc) = randperm(UniqueBaseline);
    Feedback(ProtBBaseLoc) = 2;

    ProtDLoc = find(RunTrials == 4);
    ProtDPosLoc = ProtDLoc(randperm(length(ProtDLoc), NumPosBD));
    ProtDBaseLoc = setdiff(ProtDLoc, ProtDPosLoc);
    UsedPos = Waveforms(ProtBPosLoc);
    Waveforms(ProtDPosLoc) = UsedPos(randperm(length(UsedPos)));
    Feedback(ProtDPosLoc) = 1;
    Waveforms(ProtDBaseLoc) = randperm(UniqueBaseline);
    Feedback(ProtDBaseLoc) = 2;

    for k = 1:NumTrials
        fprintf(fid, '%d,', i);
        fprintf(fid, '%d,', k);

        if RunTrials(k) == 1
            Infusion = 'A';
        elseif RunTrials(k) == 2
            Infusion = 'B';
        elseif RunTrials(k) == 3
            Infusion = 'C';
        else
            Infusion = 'D';
        end
        fprintf(fid, '%s,', Infusion);

        if Feedback(k) == 1
            FeedbackVal = 'Signal';
        else
            FeedbackVal = 'Baseline';
        end
        fprintf(fid, '%s,', FeedbackVal);

        fprintf(fid, '%d,', Waveforms(k));

        fprintf(fid, '%d,%d\n', Jitter(k, 1), Jitter(k, 2));
    end
end
fclose(fid);
    
        
    
