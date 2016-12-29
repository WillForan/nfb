sca;
clear all;
DeviceIndex = [];

% PsychDebugWindowConfiguration

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
[Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Black);
%     Screen('Resolution', Window, 1024, 768);

PriorityLevel = MaxPriority(Window);
Priority(PriorityLevel);
[XCenter, YCenter] = RectCenter(Rect);
Refresh = Screen('GetFlipInterval', Window);

% blend
Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

WaitFrames = 600;
DrawFormattedText(Window, '10', 'center', 'center', White);
vbl(1) = Screen('Flip', Window);
for i = 2:11
    DrawFormattedText(Window, sprintf('%d', 10-i+1), 'center', 'center', White);
    vbl(i) = Screen('Flip', Window, vbl(i-1) + (600 - 0.5) * Refresh);
end
sca
