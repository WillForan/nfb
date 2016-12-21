sca;
clear all;
DeviceIndex = [];

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
[Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Black);
%     Screen('Resolution', Window, 1024, 768);

PriorityLevel = MaxPriority(Window);
Priority(PriorityLevel);
[XCenter, YCenter] = RectCenter(Rect);
Refresh = Screen('GetFlipInterval', Window);

% blend
Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% make a frame for my testing purposes
Frame = [0 0 1025 769];
CenteredFrame = CenterRectOnPointd(Frame, XCenter, YCenter);

%%% INFUSION SETUP %%%
InfGreyRect = [0 0 430 690];
InfGreyRectCenter = CenterRectOnPointd(InfGreyRect, XCenter, YCenter);

InfBlackRect = [0 0 300 560];
InfBlackRectCenter = CenterRectOnPointd(InfBlackRect, XCenter, YCenter);

InfFillRect = [0 0 300 0];
InfFillRectCentered = CenterRectOnPointd(InfFillRect, XCenter, InfBlackRectCenter(4));
InfFillRefreshes = 3 * round(1 / Refresh);
InfFillInc = 560 / (InfFillRefreshes - 1);

vbls = zeros(1, InfFillRefreshes);
for i = 1:InfFillRefreshes
    Screen('FrameRect', Window, White, CenteredFrame);
    Screen('FillRect', Window, ...
        [0.5 0.5 0.5; 0 0 0; 1 0 0]', ...
        [InfGreyRectCenter' InfBlackRectCenter' InfFillRectCentered']);
    vbls(i) = Screen('Flip', Window);

    InfFillRectCentered(2) = InfFillRectCentered(2) - InfFillInc;
end

% KbStrokeWait;
% sca
