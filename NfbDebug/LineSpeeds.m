sca;
clear;
DeviceIndex = [];

% use debugging for now
PsychDebugWindowConfiguration

PsychDefaultSetup(2); % default settings
Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
Screens = Screen('Screens'); % get scren number
ScreenNumber = max(Screens);

% Define black and white
White = WhiteIndex(ScreenNumber);
Black = BlackIndex(ScreenNumber);
Grey = White * 0.5;

% we want X = Left-Right, Y = top-bottom
[Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Grey); % open Window on Screen
PriorityLevel = MaxPriority(Window);
Priority(PriorityLevel);
[ScreenXpixels, ScreenYpixels] = Screen('WindowSize', Window); % get Window size
[XCenter, YCenter] = RectCenter(Rect); % get the center of the coordinate Window
Refresh = Screen('GetFlipInterval', Window);

% set default text type for window
Screen('TextFont', Window, 'Arial');
Screen('TextSize', Window, 50);
Screen('TextColor', Window, White);
[OldMax OldClamp] = Screen('ColorRange', Window);

% % how to use draw lines correctly
% clear xy;
% xy(1, :) = (XCenter-600):(XCenter+600);
% rand_xy(1, :) = xy(1, :);
% xy(2, :) = (YCenter-600):(YCenter+600);
% rand_xy(2, :) = xy(2, :) + 10 + (50 - 10) * rand(1, size(xy(1, :), 2));
% rand_xy_line = zeros(2, 2 * (size(rand_xy, 2)-1));
% rand_xy_line(:, 1:2:end) = rand_xy(:, 1:(end-1));
% rand_xy_line(:, 2:2:end) = rand_xy(:, 2:end);
% Screen('DrawLines', Window, rand_xy_line, 2, [255 0 0]);
% Screen('Flip', Window);
% KbStrokeWait;
% 
% % experimenting with X scale
% Signal1 = [(2*112)*ones(1, 3*112) (2*112):-1:1 zeros(1, 5*112)];
% Signal1 = Signal1 + randi([0 30], 1, length(Signal1));
% X = XCenter + 500;
% X = (X-1000+1):X;
% X_Line = zeros(1, 2*(length(X)-1));
% X_Line(1:2:end) = X(1:end-1);
% X_Line(2:2:end) = X(2:end);
% Signal1_Line = zeros(1, 2*(length(Signal1)-1));
% Signal1_Line(1:2:end) = Signal1(1:end-1);
% Signal1_Line(2:2:end) = Signal1(2:end);
% Screen('DrawLines', Window, [X_Line X_Line*0.5; Signal1_Line(1:1998) Signal1_Line(1:1998)], 2, [255 0 0]);
% Screen('Flip', Window);
% KbStrokeWait;
% 
% % Experimenting with X scale mapping
% %   In plot X -> 0:191
% %   On screen X -> 1:750
% X2 = [1:749/191:750] + 499;
% Signal = 50*sin(pi*(0:191)/(192/4)) + 500;
% X2_Line = zeros(1, 2*(length(X2)-1));
% X2_Line(1:2:end) = X2(1:end-1);
% X2_Line(2:2:end) = X2(2:end);
% Signal_Line =  zeros(1, 2*(length(Signal)-1));
% Signal_Line(1:2:end) = Signal(1:end-1);
% Signal_Line(2:2:end) = Signal(2:end);
% Screen('DrawLines', Window, [X2_Line 500 1250; Signal_Line 500 500], 2, [255 0 0]);
% Screen('Flip', Window);
% KbStrokeWait;
% 
% % improving mapping
% XRange = [0 191];
% YRange = [-2 2];
% NewXRange = [1000 1749];
% NewYRange = [200 949];
% X = 0:191;
% Signal = 2*sin(pi*(X)/(192/4));
% NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
% NewSignal = (Signal-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
% NewSignal = NewYRange(2) - NewSignal + NewYRange(1);
% NewX_Line = zeros(1, 2*(length(NewX)-1));
% NewX_Line(1:2:end) = NewX(1:end-1);
% NewX_Line(2:2:end) = NewX(2:end);
% NewSignal_Line =  zeros(1, 2*(length(NewSignal)-1));
% NewSignal_Line(1:2:end) = NewSignal(1:end-1);
% NewSignal_Line(2:2:end) = NewSignal(2:end);
% Screen('DrawLines', Window, [NewX_Line 1000 1749 1000 1749 1000 1749; NewSignal_Line 200 200 949 949 (200+949)/2 (200+949)/2], 5, [255 0 0]);
% Screen('Flip', Window);
% KbStrokeWait;
 
% % now let's do movement
% FlipSecs = (1/24);
% WaitFrames = round(FlipSecs / Refresh);
% 
% XRange = [0 191];
% YRange = [-1 1];
% NewXRange = [XCenter-(750/2) XCenter+(750/2)-1];
% NewYRange = [36 235];
% X = 0:191;
% Signal = [zeros(1, 192) + 0.1*rand(1, 192), ...
%     0.9*ones(1, 192) + 0.1*rand(1, 192), ...
%     -0.9*ones(1, 192) - 0.1*rand(1, 192), ...
%     0.9*ones(1, 192) + 0.1*rand(1, 192), ...
%     zeros(1, 192) + 0.1*rand(1, 192)];
% NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
% NewSignal = (Signal-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
% NewSignal = NewYRange(2) - NewSignal + NewYRange(1);
% NewX_Line = zeros(1, 2*(length(NewX)-1));
% NewX_Line(1:2:end) = NewX(1:end-1);
% NewX_Line(2:2:end) = NewX(2:end);
% NewSignal_Line =  zeros(1, 2*(length(NewSignal)-1));
% NewSignal_Line(1:2:end) = NewSignal(1:end-1);
% NewSignal_Line(2:2:end) = NewSignal(2:end);
% Screen('DrawLines', Window, [NewX_Line; NewSignal_Line(1:382)], 5, [255 0 0]);
% vbl = Screen('Flip', Window);
% FirstVbl = vbl;
% % KbStrokeWait;
% 
% Begin = 5;
% for i = 386:4:length(NewSignal_Line)
%     Screen('DrawLines', Window, [NewX_Line NewXRange(1) NewXRange(2); NewSignal_Line(Begin:i) sum(NewYRange)/2 sum(NewYRange)/2], 5, [255 0 0 ]);
%     vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5)*Refresh);
%     Begin = Begin + 4;
% end

% % testing movement
% FlipSecs = 1/60;
% WaitFrames = round(FlipSecs / Refresh);
% 
% MaxX = 240;
% XRange = [0 MaxX];
% YRange = [-1 1];
% NewXRange = [XCenter-(750/2) XCenter+(750/2)-1];
% NewYRange = [36 235];
% X = 0:(MaxX-1);
% Signal = [zeros(1, MaxX) + 0.1*rand(1, MaxX), ...
%     0.9*ones(1, MaxX) + 0.1*rand(1, MaxX)];
%     % -0.9*ones(1, MaxX) - 0.1*rand(1, MaxX), ...
%     % 0.9*ones(1, MaxX) + 0.1*rand(1, MaxX), ...
%     % zeros(1, MaxX) + 0.1*rand(1, MaxX)];
% NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
% NewSignal = (Signal-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
% NewSignal = NewYRange(2) - NewSignal + NewYRange(1);
% NewX_Line = zeros(1, 2*(length(NewX)-1));
% NewX_Line(1:2:end) = NewX(1:end-1);
% NewX_Line(2:2:end) = NewX(2:end);
% NewSignal_Line =  zeros(1, 2*(length(NewSignal)-1));
% NewSignal_Line(1:2:end) = NewSignal(1:end-1);
% NewSignal_Line(2:2:end) = NewSignal(2:end);
% Screen('DrawLines', Window, [NewX_Line; NewSignal_Line(1:(2*(MaxX-1)))], 5, [255 0 0]);
% vbl = Screen('Flip', Window);
% FirstVbl = vbl;
% % KbStrokeWait;
% 
% Begin = 3;
% for i = (2*MaxX):2:length(NewSignal_Line)
%     Screen('DrawLines', Window, [NewX_Line NewXRange(1) NewXRange(2); NewSignal_Line(Begin:i) sum(NewYRange)/2 sum(NewYRange)/2], 5, [255 0 0 ]);
%     vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5)*Refresh);
%     Begin = Begin + 2;
% end
%     
% FlipSecs = 1/30;
% WaitFrames = round(FlipSecs / Refresh);
% 
% MaxX = 120;
% XRange = [0 MaxX];
% YRange = [-1 1];
% NewXRange = [XCenter-(750/2) XCenter+(750/2)-1];
% NewYRange = [36 235];
% X = 0:(MaxX-1);
% Signal = [zeros(1, MaxX) + 0.1*rand(1, MaxX), ...
%     0.9*ones(1, MaxX) + 0.1*rand(1, MaxX)];
%     % -0.9*ones(1, MaxX) - 0.1*rand(1, MaxX), ...
%     % 0.9*ones(1, MaxX) + 0.1*rand(1, MaxX), ...
%     % zeros(1, MaxX) + 0.1*rand(1, MaxX)];
% NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
% NewSignal = (Signal-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
% NewSignal = NewYRange(2) - NewSignal + NewYRange(1);
% NewX_Line = zeros(1, 2*(length(NewX)-1));
% NewX_Line(1:2:end) = NewX(1:end-1);
% NewX_Line(2:2:end) = NewX(2:end);
% NewSignal_Line =  zeros(1, 2*(length(NewSignal)-1));
% NewSignal_Line(1:2:end) = NewSignal(1:end-1);
% NewSignal_Line(2:2:end) = NewSignal(2:end);
% Screen('DrawLines', Window, [NewX_Line; NewSignal_Line(1:(2*(MaxX-1)))], 5, [255 0 0]);
% vbl = Screen('Flip', Window);
% FirstVbl = vbl;
% % KbStrokeWait;
% 
% Begin = 3;
% for i = (2*MaxX):2:length(NewSignal_Line)
%     Screen('DrawLines', Window, [NewX_Line NewXRange(1) NewXRange(2); NewSignal_Line(Begin:i) sum(NewYRange)/2 sum(NewYRange)/2], 5, [255 0 0 ]);
%     vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5)*Refresh);
%     Begin = Begin + 2;
% end

Scale = 1;
FlipSecs = 1/60;
WaitFrames = round(FlipSecs / Refresh);

MaxX = Scale*240;
XRange = [0 MaxX];
YRange = [-99 99];
NewXRange = [XCenter-(750/2) XCenter+(750/2)-1];
NewYRange = [36 235];
X = 0:(MaxX-1);
% Signal = [zeros(1, MaxX) + 0.1*rand(1, MaxX), ...
%     0.9*ones(1, MaxX) + 0.1*rand(1, MaxX)];
Signal = -99 + (99+99).*rand(1, 4*60 + 10*60);
NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
NewSignal = (Signal-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
NewSignal = NewYRange(2) - NewSignal + NewYRange(1);
NewX_Line = zeros(1, 2*(length(NewX)-1));
NewX_Line(1:2:end) = NewX(1:end-1);
NewX_Line(2:2:end) = NewX(2:end);
NewSignal_Line =  zeros(1, 2*(length(NewSignal)-1));
NewSignal_Line(1:2:end) = NewSignal(1:end-1);
NewSignal_Line(2:2:end) = NewSignal(2:end);
% Screen('DrawLines', Window, [NewX_Line; NewSignal_Line(1:(2*(MaxX-1)))], 5, [255 0 0]);
% vbl = Screen('Flip', Window);
vbl = KbStrokeWait;
tmp = vbl;
vbls = zeros(1, 241);

Begin = 1;
index = 1;
for i = (2*(MaxX-1)):(2*Scale):length(NewSignal_Line)
    Screen('DrawLines', Window, [NewX_Line NewXRange(1) NewXRange(2); NewSignal_Line(Begin:i) sum(NewYRange)/2 sum(NewYRange)/2], 5, White);
    vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5)*Refresh);
    vbls(index) = vbl;
    Begin = Begin + 2 * Scale;
    index = index + 1;
end

sca;
% look into DrawingStuffTest
