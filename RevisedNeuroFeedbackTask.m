sca;
DeviceIndex = [];

% use debugging for now
PsychDebugWindowConfiguration

PsychDefaultSetup(2); % default settings
Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
Screens = Screen('Screens'); % get scren number
ScreenNumber = max(Screens);

% Define black and white
White = [255 255 255];
Black = [0 0 0];
Grey = White * 0.5;

% we want X = Left-Right, Y = top-bottom
[Window, Rect] = Screen('OpenWindow', ScreenNumber, Grey); % open Window on Screen
PriorityLevel = MaxPriority(Window);
Priority(PriorityLevel);
[ScreenXpixels, ScreenYpixels] = Screen('WindowSize', Window); % get Window size
[XCenter, YCenter] = RectCenter(Rect); % get the center of the coordinate Window
Refresh = Screen('GetFlipInterval', Window);

% set default text type for window
Screen('TextFont', Window, 'Arial');
Screen('TextSize', Window, 50);
Screen('TextColor', Window, White);

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

% *** NEW FEEDBACK RESOLUTION = 750 x 750
%   LeftLocation = 

% original BarResolution
%   LeftLocation = round(0.1 * 600) = 60
%   BottomLocation = round(0.135 * 600) = 81
%   RightLocation = round(0.032 * 600) + 60 = 79
%   TopLocation = round(0.752 * 600) + 81 = 532
%   LtoRPixels = 19
%   BtoTPixels = 451

FeedbackPos = [round(0.232*ScreenXpixels) ...
    round(0.135*ScreenYpixels) ...
    ScreenXpixels ...
    round(0.752*ScreenYpixels) + round(0.135*ScreenYpixels)];

% draw a rectangle
Screen('FillRect', Window, Black, FeedbackPos);
Screen('Flip', Window);
KbStrokeWait;
sca;

% original resolution was set at 800 x 600
% original figure resolution was set at 600 x 600
% assume resolution is 1024 x 768; let's start off with this
% matlab position = [left bottom width height]
% PTB position = [leftbegin bottombegin rightend topend]

% CenterRectOnPointd
