clear all;
rng(1234567890);

% 1 second of baseline
% 5 seconds increment
% 4 seconds at max
Refresh = 1/60;
Scale = 2; % move by this many points across signals
FlipSecs = 1/30; % time to display signal
WaitFrames = round(FlipSecs / Refresh); % display signal every this frame
% set MaxX, this value determines the number of seconds to move from one
% end of the screen to the other; FlipSecs and MaxX depend on each other
MaxX = Scale*120;
N = Scale*4*1/FlipSecs + Scale*10*1/FlipSecs-1;

Sin1 = 5.5*sin(2*pi*(1:N)*(1/60));
Sin2 = 1*sin(2*pi*(1:N)*(1/2));

% 4 initial baseline + 1 baseline + 5 ramp + 4 max
Index1 = 1:(5*Scale*1/FlipSecs-1);
Index2 = (Index1(end)+1):(Index1(end)+1+5*Scale*1/FlipSecs-1);
Index3 = (Index2(end)+1):N;

Inc = 85/length(Index2);
Ramp = 0:Inc:(85-Inc);

% NoFeedbackSigs
% FeedbackSigs
for i = 1:100
    Noise = 5*randn(1, N);
    NoFeedbackSigs{i, 1} = Noise(Index1);
    NoFeedbackSigs{i, 2} = Noise(Index2);
    NoFeedbackSigs{i, 3} = Noise(Index3);

    FeedbackSigs{i, 1} = Noise(Index1);
    FeedbackSigs{i, 2} = Noise(Index2) + Ramp + Sin1(Index2) + Sin2(Index2);
    FeedbackSigs{i, 2}(FeedbackSigs{i, 2} > 100) = 99;
    FeedbackSigs{i, 3} = Noise(Index3) + 85 + Sin1(Index3) + Sin2(Index3);
    FeedbackSigs{i, 3}(FeedbackSigs{i, 3} > 100) = 99;
end

for i = 1:size(FeedbackSigs, 1)
    for k = 1:size(FeedbackSigs, 2)
        fprintf(1, '%d:%0.3f ', k, max(FeedbackSigs{i, k}));
    end
    fprintf(1, '\n');
end

save('Waveforms', 'NoFeedbackSigs', 'FeedbackSigs');
