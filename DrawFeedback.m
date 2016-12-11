sca;
clear;
DeviceIndex = [];

% use debugging for now
PsychDebugWindowConfiguration

PsychDefaultSetup(2); % default settings
Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
Screen('Preference', 'DefaultFontSize', 35);
Screen('Preference', 'DefaultFontName', 'Arial');
Screens = Screen('Screens'); % get scren number
ScreenNumber = max(Screens);
% Screen('Resolution', ScreenNumber, 1024, 768)

% define colors
White = WhiteIndex(ScreenNumber);
Black = BlackIndex(ScreenNumber);
Grey = White * 0.5;

% we want X = Left-Right, Y = top-bottom
[Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Grey);
OffWindow = Screen('OpenOffScreenWindow', Window, Grey);
PriorityLevel = MaxPriority(Window);
Priority(PriorityLevel);
[XCenter, YCenter] = RectCenter(Rect); % get the center of the coordinate Window
Refresh = Screen('GetFlipInterval', Window);

% blend
Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% draw the feedback screen objects from right to left
% start with feedback rect location
FeedbackRect = [0 0 750 750];
FeedbackXCenter = 119 + XCenter; 
FeedbackYCenter = YCenter;
CenteredFeedback = CenterRectOnPointd(FeedbackRect, ...
    FeedbackXCenter, FeedbackYCenter);
RefX = CenteredFeedback(1);
RefY = CenteredFeedback(2);

% draw numbers
Screen('DrawText', OffWindow, ...
    '100', RefX - 57, RefY - 6, Black);
Screen('DrawText', OffWindow, ...
    '50', RefX - 38, RefY + 167, Black);
Screen('DrawText', OffWindow, ...
    '0', RefX - 19, RefY + 362, Black);
Screen('DrawText', OffWindow, ...
    '-50', RefX - 50, RefY + 548, Black);
Screen('DrawText', OffWindow, ...
    '-100', RefX - 69, RefY + 731, Black);

% draw Neurofeedback Signal label
[NeuroTexture NeuroBox] = MakeTextTexture(Window, ...
    'Neurofeedback Signal', Grey, [], 55);
NeuroXLoc = RefX - 69 - 5;
tmp = CenterRectOnPointd(NeuroBox, NeuroXLoc, YCenter);
Screen('DrawTexture', OffWindow, NeuroTexture, [], tmp, -90);

% dose rect location
BarRect = [0 0 50 750];
BarXCenter = RefX - 69 -5 - NeuroBox(4);
BarYCenter = YCenter;
CenteredBar = CenterRectOnPointd(BarRect, ...
    BarXCenter, BarYCenter);

% draw dose number labels
Screen('DrawText', OffWindow, ...
    '100', CenteredBar(1) - 57, RefY - 6, Black);
Screen('DrawText', OffWindow, ...
    '0', CenteredBar(1) - 19, RefY + 731);

% draw "% dose administered" label
[DoseTexture DoseBox] = MakeTextTexture(Window, ...
    '% dose administered', Grey, [], 55);
DoseXLoc = CenteredBar(1) - 60;
tmp = CenterRectOnPointd(DoseBox, DoseXLoc, YCenter);
Screen('DrawTexture', OffWindow, DoseTexture, [], tmp, -90);

% draw feedback and does rects
Screen('FillRect', OffWindow, Black, [CenteredFeedback' CenteredBar']);

% draw offscreen to screen
Screen('DrawTexture', Window, OffWindow);

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

Screen('Flip', Window);
KbStrokeWait;
sca;

