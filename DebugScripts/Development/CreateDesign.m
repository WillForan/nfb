clear all;
rng(1234567890);

% 18 trials each of 1,2,3,4 (A,B,C,D)
% 15 1,3 positive
% 3 1,3 baseline
% 10 2,4 positive
% 8 2,4 baseline

NumRuns = 2;
NumTrials = 72;
Trials = [1 2 3 4];
Possible = PrintAllPermutations(Trials);

fid = fopen('Design.csv', 'w');
fprintf(fid, 'Run,');
fprintf(fid, 'TrialNum,');
fprintf(fid, 'Infusion,');
fprintf(fid, 'Feedback,');
fprintf(fid, 'Waveform,');
fprintf(fid, 'Jitter1Dur,');
fprintf(fid, 'Jitter2Dur\n');

for i = 1:NumRuns

    % get trial order
    Blocks = randperm(size(Possible, 1), 18);
    RunTrials = Possible(Blocks, :);
    RunTrials = RunTrials';
    RunTrials = RunTrials(:);

    % make random jitter1 and 2
    Jitter = randi([0 120], NumTrials, 2);

    % assign waveforms
    Waveforms = zeros(NumTrials, 1);
    Feedback = zeros(NumTrials, 1);

    ProtALoc = find(RunTrials == 1);
    ProtAPosLoc = ProtALoc(randperm(length(ProtALoc), 15));
    ProtABaseLoc = setdiff(ProtALoc, ProtAPosLoc);
    Waveforms(ProtAPosLoc) = randperm(15);
    Feedback(ProtAPosLoc) = 1;
    Waveforms(ProtABaseLoc) = randperm(8, 3);
    Feedback(ProtABaseLoc) = 2;

    ProtCLoc = find(RunTrials == 3);
    ProtCPosLoc = ProtCLoc(randperm(length(ProtCLoc), 15));
    ProtCBaseLoc = setdiff(ProtCLoc, ProtCPosLoc);
    Waveforms(ProtCPosLoc) = randperm(15);
    Feedback(ProtCPosLoc) = 1;
    UsedBase = Waveforms(ProtABaseLoc);
    Waveforms(ProtCBaseLoc) = UsedBase(randperm(length(UsedBase)));
    Feedback(ProtCBaseLoc) = 2;

    ProtBLoc = find(RunTrials == 2);
    ProtBPosLoc = ProtBLoc(randperm(length(ProtBLoc), 10));
    ProtBBaseLoc = setdiff(ProtBLoc, ProtBPosLoc);
    Waveforms(ProtBPosLoc) = randperm(15, 10);
    Feedback(ProtBPosLoc) = 1;
    Waveforms(ProtBBaseLoc) = randperm(8);
    Feedback(ProtBBaseLoc) = 2;

    ProtDLoc = find(RunTrials == 4);
    ProtDPosLoc = ProtDLoc(randperm(length(ProtDLoc), 10));
    ProtDBaseLoc = setdiff(ProtDLoc, ProtDPosLoc);
    UsedPos = Waveforms(ProtBPosLoc);
    Waveforms(ProtDPosLoc) = UsedPos(randperm(length(UsedPos)));
    Feedback(ProtDPosLoc) = 1;
    Waveforms(ProtDBaseLoc) = randperm(8);
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
        fprintf(fid, '%0.4f\n', Jitter(k, 2));
    end
end
fclose(fid);
    
        
    
