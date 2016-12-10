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
[XCenter, YCenter] = RectCenter(Rect);
Refresh = Screen('GetFlipInterval', Window);

% blend
Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Feedback rect location; this is used as position reference for most
% other drawn objects
FeedbackRect = [0 0 750 750];
FeedbackXCenter = 119 + XCenter; 
FeedbackYCenter = YCenter;
CenteredFeedback = CenterRectOnPointd(FeedbackRect, ...
    FeedbackXCenter, FeedbackYCenter);
RefX = CenteredFeedback(1);
RefY = CenteredFeedback(2);

% set "Neurofeedback Signal" label location
[NeuroTexture NeuroBox] = MakeTextTexture(Window, ...
    'Neurofeedback Signal', Grey, [], 55);
NeuroXLoc = RefX - 69 - 5;
NeuroLoc = CenterRectOnPointd(NeuroBox, NeuroXLoc, YCenter);

% set dose rect location
BarRect = [0 0 50 750];
BarXCenter = RefX - 69 -5 - NeuroBox(4);
BarYCenter = YCenter;
CenteredBar = CenterRectOnPointd(BarRect, ...
    BarXCenter, BarYCenter);
[DoseX, DoseY] = RectCenter(CenteredBar);

% set "% dose administered" label location
[DoseTexture DoseBox] = MakeTextTexture(Window, ...
    '% dose administered', Grey, [], 55);
DoseXLoc = CenteredBar(1) - 60;
DoseLoc = CenterRectOnPointd(DoseBox, DoseXLoc, YCenter);

% create dose level rect
DoseLevelRect = [0 0 50 5];
DoseLevelRect = CenterRectOnPointd(DoseLevelRect, ...
    DoseX, CenteredBar(2));

% create changing time dose rect
PerDoseRect = [0 0 48 0];
PerDoseRect = CenterRectOnPointd(PerDoseRect, ...
    DoseX, CenteredBar(4) - 1);


% make a frame for my testing purposes
Frame = [0 0 1025 769];
CenteredFrame = CenterRectOnPointd(Frame, XCenter, YCenter);

% now experiment with drawing signal
Scale = 1; % move by this many points across signals
FlipSecs = 1/60; % time to display signal
WaitFrames = round(FlipSecs / Refresh); % display signal every this frame
% set MaxX, this value determines the number of seconds to move from one
% end of the screen to the other; FlipSecs and MaxX depend on each other
MaxX = Scale*240;

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

% do bar movment calculation here
NumPoints = (length(NewSignal_Line) - (2*(MaxX-1)))/2;
Increment = (750 - 1)/NumPoints;

Begin = 1;
index = 1;
for i = (2*(MaxX-1)):(2*Scale):length(NewSignal_Line)

    % draw feedback number labels
    Screen('DrawText', Window, ...
        '100', RefX - 57, RefY - 6, Black);
    Screen('DrawText', Window, ...
        '50', RefX - 38, RefY + 167, Black);
    Screen('DrawText', Window, ...
        '0', RefX - 19, RefY + 362, Black);
    Screen('DrawText', Window, ...
        '-50', RefX - 50, RefY + 548, Black);
    Screen('DrawText', Window, ...
        '-100', RefX - 69, RefY + 731, Black);

    % draw graph text labels
    Screen('DrawTextures', Window, ...
        [NeuroTexture DoseTexture], [], ...
        [NeuroLoc' DoseLoc'], ...
        -90);

    % draw dose number labels
    Screen('DrawText', Window, ...
        '100', CenteredBar(1) - 57, RefY - 6, Black);
    Screen('DrawText', Window, ...
        '0', CenteredBar(1) - 19, RefY + 731);
    
    % draw feedback and dose rects
    Screen('FillRect', Window, ...
    [0 0 0; 0 0 0; 1 0 0 ; 0.5 0.5 1]', ... 
    [CenteredFeedback' CenteredBar' PerDoseRect' DoseLevelRect']);

    % draw feedback line
    Screen('DrawLines', Window, ...
        [NewX_Line NewXRange(1) NewXRange(2); ...
        NewSignal_Line(Begin:i) sum(NewYRange)/2 sum(NewYRange)/2], ...
        5, [repmat([1 0 0]', 1, i-Begin+1) [1 1 1; 1 1 1]']);

    % frame for testing purposes
    Screen('FrameRect', Window, Black, CenteredFrame);

    % do flip here
    vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5)*Refresh);

    PerDoseRect(2) = PerDoseRect(2) - Increment;
    vbls(index) = vbl;
    Begin = Begin + 2 * Scale;
    index = index + 1;
end

vbl = 0;
Screen('Flip', Window);

% get "NEXT INFUSION" size
OldSize = Screen('TextSize', Window, 60);
NextRect = Screen('TextBounds', Window, 'NEXT INFUSION');
NextRect = CenterRectOnPointd(NextRect, XCenter, YCenter - 350);
Screen('TextSize', Window, OldSize);

% get "Continue infusion?" size
OldSize = Screen('TextSize', Window, 60);
ContinueRect = Screen('TextBounds', Window, 'Continue infusion?');
ContinueRect = CenterRectOnPointd(ContinueRect, XCenter, YCenter + 150);
Screen('TextSize', Window, OldSize);

% get "YES" size
OldSize = Screen('TextSize', Window, 70);
OldStyle = Screen('TextStyle', Window, 1);
YesRect = Screen('TextBounds', Window, 'YES');
YesRect = CenterRectOnPointd(YesRect, ContinueRect(1), ContinueRect(4) + 75);
Screen('TextSize', Window, OldSize);
Screen('TextStyle', Window, OldStyle);

% get "NOT" size
OldSize = Screen('TextSize', Window, 70);
OldSyle = Screen('TextStyle', Window, 1);
NoRect = Screen('TextBounds', Window, 'NOT');
NoRect = CenterRectOnPointd(NoRect, ContinueRect(3), ContinueRect(4) + 75);
Screen('TextSize', Window, OldSize);
Screen('TextStyle', Window, OldStyle);

% set up keyboard response
KbNames = KbName('KeyNames');
KeyNamesOfInterest = {'1!', '2@', '1', '2'};
KeysOfInterest = zeros(1, 256);
for i = 1:numel(KeyNamesOfInterest)
    KeysOfInterest(KbName(KeyNamesOfInterest{i})) = 1;
end
clear i
KbQueueCreate(DeviceIndex, KeysOfInterest);

Response = 0;
for i = 5:-1:1

    % "NEXT INFUSION" text
    Screen('TextSize', Window, 60);
    DrawFormattedText(Window, 'NEXT INFUSION', 'center', 'center',  ...
        [0 1 0], [], [], [], [], [], NextRect);

    % Time text
    Screen('TextSize', Window, 200);
    Screen('TextStyle', Window, 1);
    DrawFormattedText(Window, sprintf('00:%02d', i), 'center', 'center', [1 0 0]);
    Screen('TextStyle', Window, 0);

    if i < 3
        Screen('TextSize', Window, 60);
        DrawFormattedText(Window, 'Continue infusion?', 'center', 'center', ...
            White, [], [], [], [], [], ContinueRect);

        Screen('TextSize', Window, 70);
        Screen('TextStyle', Window, 1);
        DrawFormattedText(Window, 'YES', 'center', 'center', ...
            White, [], [], [], [], [], YesRect);
        DrawFormattedText(Window, 'NOT', 'center', 'center', ...
            White, [], [], [], [], [], NoRect);
        Screen('TextStyle', Window, 0);
    end

    % frame for testing purposes
    Screen('FrameRect', Window, Black, CenteredFrame);

    vbl = Screen('Flip', Window, vbl + 1 - Refresh);
    if i == 2
        KbQueueStart(DeviceIndex);
        ResponseOnset = vbl;
    end
end

KbQueueStop(DeviceIndex);
[DidRespond, TimeKeysPressed] = KbQueueCheck(DeviceIndex);
if DidRespond
    TimeKeysPressed(TimeKeysPressed == 0) = nan;
    [RT, Idx] = min(TimeKeysPressed);
    Response = KbNames{Idx};
    RT = RT - ResponseOnset;
end
KbQueueFlush(DeviceIndex);
% fprintf(1, 'Run: %d, Trial: %d, RT: %0.4f, Response: %s\n', ...
%     i, k, RunDesign{k, FACERT}, RunDesign{k, FACERESPONSE});
    
    
    
    


WaitSecs(1);
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
