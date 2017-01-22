clear all;
rng(1234567890);

% 4 runs
%   36 trials per run
%   9 trials for each condition in 1 run
%       7 1,3 positive
%       2 1,3 baseline
%       5 2,4 positive
%       4 2,4 baseline
% 9 trials of each (1, 2, 3, 4)

NumRuns = 4;
NumTrials = 36;
Trials = [1 2 3 4];
Possible = PrintAllPermutations(Trials);
NumJitters = 4;
TrialBlocks = 9;
UniquePositive = 7;
UniqueBaseline = 5;
NumBaseAC = 2;
NumPosBD = 4;

fid = fopen('Design.csv', 'w');
fprintf(fid, 'Run,');
fprintf(fid, 'TrialNum,');
fprintf(fid, 'Infusion,');
fprintf(fid, 'Feedback,');
fprintf(fid, 'Waveform,');
fprintf(fid, 'Jitter1Dur,');
fprintf(fid, 'Jitter2Dur,');
fprintf(fid, 'Jitter3Dur,');
fprintf(fid, 'Jitter4Dur\n');

for i = 1:NumRuns

    % get trial order
    Blocks = randperm(size(Possible, 1), TrialBlocks);
    RunTrials = Possible(Blocks, :);
    RunTrials = RunTrials';
    RunTrials = RunTrials(:);

    % make 4 exponentially distributed distributions
    lambda = 1/60;
    c1 = 5;
    c2 = 120;
    e1 = exp(-lambda*c1);
    e2 = exp(-lambda*c2);
    Jitter = floor(-1/lambda * log(e1-rand(NumTrials, NumJitters)*(e1-e2)));

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
        fprintf(fid, '%0.4f,', Jitter(k, 1));
        fprintf(fid, '%0.4f,', Jitter(k, 2));
        fprintf(fid, '%0.4f,', Jitter(k, 3));
        fprintf(fid, '%0.4f\n', Jitter(k, 4));
    end
end
fclose(fid);
    
        
    
