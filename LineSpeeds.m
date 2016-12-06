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

