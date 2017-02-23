clear all;
rng(1234567890);

Interval1 = [15 120];
Interval2 = [90 200];
FeedbackTime = 10;
% remaining seconds at max
Refresh = 1/60;
Scale = 2; % move by this many points across signals
FlipSecs = 1/30; % time to display signal
WaitFrames = round(FlipSecs / Refresh); % display signal every this frame
% set MaxX, this value determines the number of seconds to move from one
% end of the screen to the other; FlipSecs and MaxX depend on each other
MaxX = Scale*120;
N = Scale*4*1/FlipSecs + Scale*FeedbackTime*1/FlipSecs-1;
FinalVal = 80;
NumRuns = 4;

% 85% of 8 trials 
UniquePositive = 7;
% 65% of 8 trials
UniqueBaseline = 5;


% Baselines
% Signals
for iRun = 1:NumRuns
    for i = 1:UniquePositive
        Noise = 8.5*randn(1, N);
        T1 = randi(Interval1);
        T2 = randi(Interval2);
        if mod(T2, 2)
            T2 = T2 - 1;
        end
    
        Index1 = 1:(4*Scale*1/FlipSecs + T1);
        Index2 = (Index1(end)+1):(Index1(end)+1+T2-1);
        Index3 = (Index2(end)+1):N;
        Inc = FinalVal/length(Index2);
        Ramp = 0:Inc:(FinalVal-Inc);
    
        Phase1 = 2*rand(1, 1);
        Phase2 = 2*rand(1, 1);
    
        Mag1 = 5 + (8-5)*rand(1, 1);
        Mag2 = 0.5 + (2-0.5)*rand(1, 1);
        fprintf(1, 'Mag1:%0.2f, Mag1:%0.2f\n', Mag1, Mag2);
        
        Sin1 = Mag1*sin(2*pi*(1:N)*(1/60) + Phase1*pi);
        Sin2 = Mag2*sin(2*pi*(1:N)*(1/2) + Phase1*pi);
    
        if i <= UniqueBaseline
            Baselines{iRun}{i, 1} = Noise(Index1);
            Baselines{iRun}{i, 2} = Noise(Index2);
            Baselines{iRun}{i, 3} = Noise(Index3);
        end
    
        Signals{iRun}{i, 1} = Noise(Index1);
        Signals{iRun}{i, 2} = Noise(Index2) + Ramp + Sin1(Index2) + Sin2(Index2);
        Signals{iRun}{i, 2}(Signals{iRun}{i, 2} > 100) = 99;
        Signals{iRun}{i, 3} = Noise(Index3) + FinalVal + Sin1(Index3) + Sin2(Index3);
        Signals{iRun}{i, 3}(Signals{iRun}{i, 3} > 100) = 99;
    end
end

for iRun = 1:NumRuns
    for i = 1:size(Signals{iRun}, 1)
        for k = 1:size(Signals{iRun}, 2)
            fprintf(1, '%d:%d:%0.3f ', iRun, k, max(Signals{iRun}{i, k}));
        end
        fprintf(1, '\n');
    end
end

for iRun = 1:NumRuns
    for i = 1:size(Signals{iRun}, 1)
        for k = 1:size(Signals{iRun}, 2)
            fprintf(1, '%d:%d:%0.2f ', iRun, k, length(Signals{iRun}{i, k})/60);
        end
        fprintf(1, '\n');
    end
end

save('Waveforms', 'Baselines', 'Signals');
