tmp = Screen('Resolution', 0);
Rect = [0 0 tmp.width tmp.height];
[XCenter, YCenter] = RectCenter(Rect);

FeedbackRect = [0 0 920 750];
FeedbackXCenter = 52 + XCenter;
CenteredFeedback = CenterRectOnPointd(FeedbackRect, FeedbackXCenter, YCenter);
RefX = CenteredFeedback(1);
RefY = CenteredFeedback(2);

% now experiment with drawing signal
Scale = 2; % move by this many points across signals
FlipSecs = 2/60; % time to display signal
% WaitFrames = round(FlipSecs / Refresh); % display signal every this frame
% set MaxX, this value determines the number of seconds to move from one
% end of the screen to the other; FlipSecs and MaxX depend on each other
MaxX = Scale*120;

% create original and plotted ranges
XRange = [0 (MaxX-1)];
YRange = [-100 100];
NewXRange = [CenteredFeedback(1) CenteredFeedback(3)];
NewYRange = [CenteredFeedback(2) CenteredFeedback(4)];

% dummy signals
X = 0:(MaxX-1);
% load FeedbackSigs and NoFeedbackSigs
load('./DebugScripts/Development/Waveforms.mat');

% modify signals to allow continuous plotting between them
ModFeedSigs = cell(size(FeedbackSigs));
ModNoFeedSigs = cell(size(NoFeedbackSigs));
for i = 1:size(ModFeedSigs, 1)
    ModFeedSigs{i, 1} = FeedbackSigs{i, 1};

    for k = 2:size(ModFeedSigs, 2)
        BeginSig1 = length(FeedbackSigs{i, k - 1}) - MaxX + 1 + Scale;
        ModFeedSigs{i, k} = [FeedbackSigs{i, k - 1}(BeginSig1:end) ...
            FeedbackSigs{i, k}];
    end
end 
        

% % convert from old range values to new range values
% NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
% 
% for i = 1:size(FeedbackSigs, 1)
%     for k = 1:size(FeedbackSigs, 2)
%         FeedbackSigs{i, k} = (FeedbackSigs{i, k} - YRange(1)) / ...
%             diff(YRange)*diff(NewYRange)+NewYRange(1);
%         FeedbackSigs{i, k} = NewYRange(2) - FeedbackSigs{i, k} + NewYRange(1);
%     end
% end
% clear i k
% 
% for i = 1:size(NoFeedbackSigs, 1)
%     for k = 1:size(NoFeedbackSigs, 2)
%         NoFeedbackSigs{i, k} = (NoFeedbackSigs{i, k} - YRange(1)) / ...
%             diff(YRange)*diff(NewYRange)+NewYRange(1);
%         NoFeedbackSigs{i, k} = NewYRange(2) - NoFeedbackSigs{i, k} + NewYRange(1);
%     end
% end
% clear i k
% 
% % create values that appear as continuous lines when plotted
% NewX_Line = zeros(1, 2*(length(NewX)-1));
% NewX_Line(1:2:end) = NewX(1:end-1);
% NewX_Line(2:2:end) = NewX(2:end);
% 
% LineFeedbackSigs = cell(size(FeedbackSigs));
% for i = 1:size(LineFeedbackSigs, 1)
%     for k = 1:size(LineFeedbackSigs, 2)
%         LineFeedbackSigs{i, k} = zeros(1, 2*(length(FeedbackSigs{i, k})-1));
%         LineFeedbackSigs{i, k}(1:2:end) = FeedbackSigs{i, k}(1:end-1);
%         LineFeedbackSigs{i, k}(2:2:end) = FeedbackSigs{i, k}(2:end);
%     end
%     for k = 2:size(LineFeedbackSigs, 2)
%         Signal1 = LineFeedbackSigs{i, k - 1};
%         Signal2 = LineFeedbackSigs{i, k};
% 
%         N = length(FeedbackSigs{i, k - 1});
%         BeginEnd = (N - 1) * 2 - 2 * (MaxX - 1);
%         BeginNext = BeginEnd + 2 * Scale;
% 
%         LineFeedbackSigs{i, k} = [Signal1(BeginNext:end) Signal1(end) ...
%             Signal2(1) Signal2];
%     end
% end
% clear i k
% 
% LineNoFeedbackSigs = cell(size(NoFeedbackSigs));
% for i = 1:size(LineNoFeedbackSigs, 1)
%     for k = 1:size(LineNoFeedbackSigs, 2)
%         LineNoFeedbackSigs{i, k} = zeros(1, 2*(length(NoFeedbackSigs{i, k})-1));
%         LineNoFeedbackSigs{i, k}(1:2:end) = NoFeedbackSigs{i, k}(1:end-1);
%         LineNoFeedbackSigs{i, k}(2:2:end) = NoFeedbackSigs{i, k}(2:end);
%     end
%     for k = 2:size(LineNoFeedbackSigs, 2)
%         Signal1 = LineNoFeedbackSigs{i, k - 1};
%         Signal2 = LineNoFeedbackSigs{i, k};
% 
%         N = length(NoFeedbackSigs{i, k - 1});
%         BeginEnd = (N - 1) * 2 - 2 * (MaxX - 1);
%         BeginNext = BeginEnd + 2 * Scale;
% 
%         LineNoFeedbackSigs{i, k} = [Signal1(BeginNext:end) Signal1(end) ...
%             Signal2(1) Signal2];
%     end
% end
% clear i k
% 
