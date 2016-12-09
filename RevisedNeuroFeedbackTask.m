sca;
DeviceIndex = [];

% use debugging for now
PsychDebugWindowConfiguration

PsychDefaultSetup(2); % default settings
Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
Screen('Preference', 'DefaultFontSize', 35);
Screen('Preference', 'DefaultFontName', 'Arial');
Screens = Screen('Screens'); % get scren number
ScreenNumber = max(Screens);

% Define black and white
White = WhiteIndex(ScreenNumber);
Black = BlackIndex(ScreenNumber);
Grey = White * 0.5;

% we want X = Left-Right, Y = top-bottom
[Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Grey);
PriorityLevel = MaxPriority(Window);
Priority(PriorityLevel);
[XCenter, YCenter] = RectCenter(Rect); % get the center of the coordinate Window
Refresh = Screen('GetFlipInterval', Window);

% blend
Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% draw the feedback screen objects from right to left
FeedWin = Screen('OpenOffScreenWindow', Window, Grey);

% start with feedback rect location
FeedbackRect = [0 0 750 750];
FeedbackXCenter = 119 + XCenter; 
FeedbackYCenter = YCenter;
CenteredFeedback = CenterRectOnPointd(FeedbackRect, ...
    FeedbackXCenter, FeedbackYCenter);
RefX = CenteredFeedback(1);
RefY = CenteredFeedback(2);

% draw numbers
Screen('DrawText', FeedWin, ...
    '100', RefX - 57, RefY - 6, Black);
Screen('DrawText', FeedWin, ...
    '50', RefX - 38, RefY + 167, Black);
Screen('DrawText', FeedWin, ...
    '0', RefX - 19, RefY + 362, Black);
Screen('DrawText', FeedWin, ...
    '-50', RefX - 50, RefY + 548, Black);
Screen('DrawText', FeedWin, ...
    '-100', RefX - 69, RefY + 731, Black);

% draw Neurofeedback Signal label
[NeuroTexture NeuroBox] = MakeTextTexture(Window, ...
    'Neurofeedback Signal', Grey, [], 55);
NeuroXLoc = RefX - 69 - 5;
tmp = CenterRectOnPointd(NeuroBox, NeuroXLoc, YCenter);
Screen('DrawTexture', FeedWin, NeuroTexture, [], tmp, -90);

% dose rect location
BarRect = [0 0 50 750];
BarXCenter = RefX - 69 -5 - NeuroBox(4);
BarYCenter = YCenter;
CenteredBar = CenterRectOnPointd(BarRect, ...
    BarXCenter, BarYCenter);

% draw dose number labels
Screen('DrawText', FeedWin, ...
    '100', CenteredBar(1) - 57, RefY - 6, Black);
Screen('DrawText', FeedWin, ...
    '0', CenteredBar(1) - 19, RefY + 731);

% draw "% dose administered" label
[DoseTexture DoseBox] = MakeTextTexture(Window, ...
    '% dose administered', Grey, [], 55);
DoseXLoc = CenteredBar(1) - 60;
tmp = CenterRectOnPointd(DoseBox, DoseXLoc, YCenter);
Screen('DrawTexture', FeedWin, DoseTexture, [], tmp, -90);

% draw feedback and does rects
Screen('FillRect', FeedWin, Black, [CenteredFeedback' CenteredBar']);

% draw offscreen to screen
Screen('DrawTexture', Window, FeedWin);

% draw working space frame for my purposes
Frame = [0 0 1025 769];
CenteredFrame = CenterRectOnPointd(Frame, XCenter, YCenter);
Screen('FrameRect', Window, Black, CenteredFrame);

% draw center line for my purposes
Screen('DrawLine', Window, White, ...
    CenteredFeedback(1), ...
    YCenter, ...
    CenteredFeedback(3), ...
    YCenter); 

% now experiment with drawing signal
Scale = 2; % move by this many points across signals
FlipSecs = 1/30; % time to display signal
WaitFrames = round(FlipSecs / Refresh); % display signal every this frame
% set MaxX, this value determines the number of seconds to move from one
% end of the screen to the other; FlipSecs and MaxX depend on each other
MaxX = Scale*120;

% create original and plotted ranges
XRange = [0 MaxX];
YRange = [-100 100];
NewXRange = [CenteredFeedback(1) CenteredFeedback(3)];
NewYRange = [CenteredFeedback(2) CenteredFeedback(4)];

% dummy signal
X = 0:(MaxX-1);
Signal = [zeros(1, MaxX) + 10*rand(1, MaxX), ...
    90*ones(1, MaxX) + 10*rand(1, MaxX)];

% convert from old range values to new range values
NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
NewSignal = (Signal-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
NewSignal = NewYRange(2) - NewSignal + NewYRange(1);

% create values that appear as continuous lines when plotted
NewX_Line = zeros(1, 2*(length(NewX)-1));
NewX_Line(1:2:end) = NewX(1:end-1);
NewX_Line(2:2:end) = NewX(2:end);
NewSignal_Line =  zeros(1, 2*(length(NewSignal)-1));
NewSignal_Line(1:2:end) = NewSignal(1:end-1);
NewSignal_Line(2:2:end) = NewSignal(2:end);

vbl = KbStrokeWait;
tmp = vbl;
vbls = zeros(1, MaxX/Scale + 1);

Begin = 1;
index = 1;
for i = (2*(MaxX-1)):(2*Scale):length(NewSignal_Line)
    Screen('DrawTexture', Window, FeedWin);
    Screen('DrawLines', Window, ...
        [NewX_Line NewXRange(1) NewXRange(2); ...
        NewSignal_Line(Begin:i) sum(NewYRange)/2 sum(NewYRange)/2], ...
        5, White);
    vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5)*Refresh);
    vbls(index) = vbl;
    Begin = Begin + 2 * Scale;
    index = index + 1;
end


KbStrokeWait;
sca;


% we will be working in 1024 x 768 resolution
% orignal FeedbackBoxResolution:
%   LeftLocation = round(0.232 * 600) = 139
%   BottomLocation = round(0.135 * 600) = 81
%   RightLocation = round(0.752 * 600) + 139 = 590
%   TopLocation = round(0.752 * 600) + 81 = 532
%   LtoRPixels = 451
%   BtoTPixels = 451
%   LOffsetFromMid = 139 - 300 = -161
%   BOffsetFromMid = 81 - 300 = -219
%   OriginalSpeed = 451/4 = 112 pixels/second
%   56% of screen^2

% *** NEW FEEDBACK RESOLUTION = 750 x 750
%   LeftLocation = 

% original BarResolution
%   LeftLocation = round(0.1 * 600) = 60
%   BottomLocation = round(0.135 * 600) = 81
%   RightLocation = round(0.032 * 600) + 60 = 79
%   TopLocation = round(0.752 * 600) + 81 = 532
%   LtoRPixels = 19
%   BtoTPixels = 451

% original resolution was set at 800 x 600
% original figure resolution was set at 600 x 600
% assume resolution is 1024 x 768; let's start off with this
% matlab position = [left bottom width height]
% PTB position = [leftbegin bottombegin rightend topend]

% CenterRectOnPointd
