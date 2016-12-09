sca;
clear;
DeviceIndex = [];

% use debugging for now
% PsychDebugWindowConfiguration

PsychDefaultSetup(2); % default settings
Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
Screen('Preference', 'DefaultFontSize', 60);
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


% make neurofeedback y label texture
[~, ~, FeedbackLabel] = DrawFormattedText(Window, ...
    'Neurofeedback Signal5  ', 'center', 'center', White);
FeedbackTextureRect = ones(ceil((FeedbackLabel(4) - FeedbackLabel(2)) * 1.1), ...
    ceil((FeedbackLabel(3) - FeedbackLabel(1)) * 1.1)) .* Grey;
FeedbackLabelTexture = Screen('MakeTexture', Window, FeedbackTextureRect);
DrawFormattedText(FeedbackLabelTexture, 'Neurofeedback Signal5  ', ...
    'center', 'center', Black);
[FunctionTexture, nx, ny] = MakeTextTexture(Window, ...
    'Neurofeedback Signal5', ...
    Grey, ...
    'Arial', ...
    60, ...
    Black);

% make dose y label texture
[~, ~, DoseLabel] = DrawFormattedText(Window, ...
    '% Dose Administered', 'center', 'center', White);
DoseTextureRect = ones(ceil((DoseLabel(4) - DoseLabel(2)) * 1.1), ...
    ceil((DoseLabel(3) - DoseLabel(1)) * 1.1)) .* Grey;
DoseLabelTexture = Screen('MakeTexture', Window, DoseTextureRect);
DrawFormattedText(DoseLabelTexture, 'Neurofeedback Signal', ...
    'center', 'center', Black);

% clear unwanted text from screen
Screen('FillRect', Window, Grey);

% set default text type for window
Screen('TextSize', Window, 35);
Screen('TextColor', Window, White);
Screen('TextSize', OffWindow, 35);
Screen('TextColor', OffWindow, White);

FeedbackRect = [0 0 750 750];
FeedbackXCenter = 119 + XCenter; % 256 more pixels to use
FeedbackYCenter = YCenter;
CenteredFeedback = CenterRectOnPointd(FeedbackRect, ...
    FeedbackXCenter, FeedbackYCenter);

BarRect = [0 0 50 750];
BarXCenter = XCenter - 437;
BarYCenter = YCenter;
CenteredBar = CenterRectOnPointd(BarRect, ...
    BarXCenter, BarYCenter);

Frame = [0 0 1025 769];
CenteredFrame = CenterRectOnPointd(Frame, XCenter, YCenter);

% outline working space resolution
Screen('FrameRect', OffWindow, Black, CenteredFrame);

% make feedback and does rects
Screen('FillRect', OffWindow, Black, [CenteredFeedback' CenteredBar']);

% draw numbers

% draw offscreen to screen
Screen('DrawText', OffWindow, ...
    '100', XCenter - 313, YCenter - 381, Black);
Screen('DrawText', OffWindow, ...
    '50', XCenter - 294, YCenter - 199, Black);
Screen('DrawText', OffWindow, ...
    '0', XCenter - 275, YCenter - 13, Black);
Screen('DrawText', OffWindow, ...
    '-50', XCenter - 306, YCenter + 173, Black);
Screen('DrawText', OffWindow, ...
    '-100', XCenter - 325, YCenter + 358, Black);
Screen('DrawTexture', Window, OffWindow);
Screen('DrawLine', Window, White, ...
    CenteredFeedback(1), ...
    YCenter, ...
    CenteredFeedback(3), ...
    YCenter); 

% bbox2 = Screen('TextBounds', Window, 'Neurofeedback Signal');
% bbox2 = ceil(1.1 * bbox2);
% woff = Screen('OpenOffscreenWindow', Window, Grey, bbox2);
% Screen('TextFont', woff, 'Arial');
% Screen('TextSize', woff, 35);
% Screen('TextColor', woff, White);
% Screen('DrawText', woff, 'Neurofeedback Signal', 0, 0, 0);
% % DrawFormattedText(woff, 'Neurofeedback Signal', 'center', 'center', Black);
% tmp = CenterRectOnPointd(bbox2, XCenter-100, YCenter);
% Screen('DrawTexture', Window, woff, [], floor(tmp), -90);


nx1 = size(FeedbackTextureRect, 2);
ny1 = size(FeedbackTextureRect, 1);
otherBbox = [0 0 nx1 ny1];
tmp = CenterRectOnPointd(otherBbox, XCenter-51, YCenter);
Screen('DrawTexture', Window, FeedbackLabelTexture, [], [], -90);
Screen('DrawTexture', Window, FeedbackLabelTexture, [], tmp, -90);

bbox = [0 0 nx ny];
tmp = CenterRectOnPointd(bbox, XCenter+51, YCenter);
Screen('DrawTexture', Window, FunctionTexture, [], tmp, -90);

tmp = CenterRectOnPointd(bbox, XCenter+101, YCenter);
Screen('DrawTexture', Window, FunctionTexture, [], tmp, -90);

% text
Screen('TextSize', Window, 60);
Screen('DrawText', Window, 'Neurofeedback Signal5', 1, 1, Black);

Screen('Flip', Window);
KbStrokeWait;
sca;

