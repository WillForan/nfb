
sca;
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
[Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Grey);
% might need the code below after in scanning testing
% if InScan
%     Screen('Resolution', Window, 1024, 768);
% end
PriorityLevel = MaxPriority(Window);
Priority(PriorityLevel);
[XCenter, YCenter] = RectCenter(Rect);
Refresh = Screen('GetFlipInterval', Window);

% blend
Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%%% FEEDBACK SETUP %%%
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
OrigPerDoseY = PerDoseRect(2);

% make a frame for my testing purposes
% Frame = [0 0 1025 769];
% CenteredFrame = CenterRectOnPointd(Frame, XCenter, YCenter);

% now experiment with drawing signal
Scale = 1; % move by this many points across signals
FlipSecs = 1/60; % time to display signal
WaitFrames = round(FlipSecs / Refresh); % display signal every this frame
% set MaxX, this value determines the number of seconds to move from one
% end of the screen to the other; FlipSecs and MaxX depend on each other
MaxX = Scale*240;

% create original and plotted ranges
XRange = [0 (MaxX-1)];
YRange = [-100 100];
NewXRange = [CenteredFeedback(1) CenteredFeedback(3)];
NewYRange = [CenteredFeedback(2) CenteredFeedback(4)];

% dummy signals
X = 0:(MaxX-1);
Noise = -99 + (99+99).*rand(1, Scale*4*60 + (Scale*10*60-1));
% Line1 = 0:(100/119):100;
% Steep = 1.33*Line1;
% Slow = 0.75*Line1;
% Slope = zeros(1, 120);
% Slope(1:2:end) = Steep(1:2:end);
% Slope(2:2:end) = Steep(2:2:end);
% Slope(Slope > 100) = 100;
% Signal = [(10 - -10) + (-10*rand(1, 4*60)) ...
%     Slope ...
%     (98 - 85) + 85*rand(1, 5*60)];

% convert from old range values to new range values
NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
% NewSignal = (Signal-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
% NewSignal = NewYRange(2) - NewSignal + NewYRange(1);
NewNoise = (Noise-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
NewNoise = NewYRange(2) - NewNoise + NewYRange(1);

% create values that appear as continuous lines when plotted
NewX_Line = zeros(1, 2*(length(NewX)-1));
NewX_Line(1:2:end) = NewX(1:end-1);
NewX_Line(2:2:end) = NewX(2:end);
% NewSignal_Line =  zeros(1, 2*(length(NewSignal)-1));
% NewSignal_Line(1:2:end) = NewSignal(1:end-1);
% NewSignal_Line(2:2:end) = NewSignal(2:end);
NewNoise_Line =  zeros(1, 2*(length(NewNoise)-1));
NewNoise_Line(1:2:end) = NewNoise(1:end-1);
NewNoise_Line(2:2:end) = NewNoise(2:end);

% do bar movment calculation here
% NumPoints = (length(NewSignal_Line) - (2*(MaxX-1)))/2;
NumPoints = (length(NewNoise_Line) - (2*(MaxX-1)))/2;
Numpoints = (length(Noise) - (2*(MaxX-1)))/2;
Increment = (750 - 1)/(NumPoints/Scale);

%%% JITTER1 %%%
Screen('FillRect', Window, Black);
BeginTime = Screen('Flip', Window);

%%% FEEDBACK RUNNING CODE %%%

% set Window text values to be safe
Screen('TextSize', Window, 35);
Screen('TextFont', Window, 'Arial');
Screen('TextStyle', Window, 0);
Screen('FillRect', Window, Grey);

Begin = 1;
Index = 1;
for iSig = (2*(MaxX-1)):(2*Scale):length(NewNoise_Line)

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
        NewNoise_Line(Begin:iSig) sum(NewYRange)/2 sum(NewYRange)/2], ...
        5, [repmat([1 0 0]', 1, iSig-Begin+1) [1 1 1; 1 1 1]']);

    % frame for testing purposes
    % Screen('FrameRect', Window, Black, CenteredFrame);

    % do flip here
    if Begin == 1
        vbl = Screen('Flip', Window, BeginTime + 1.5 - 0.5 * Refresh);
        % RunDesign{k, FEEDONSET} = vbl - BeginTime;
        FeedOnset = vbl - BeginTime;
        vbls(Index) = vbl;
    else
        % can try no duration here to see what happens
        % but will need duration if I plan to show signal everyth nth frame
        % with n > 1, so might as well keep it for now
        vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5) * Refresh);
        % vbl = Screen('Flip', Window);
        vbls(Index) = vbl;
    end

    PerDoseRect(2) = PerDoseRect(2) - Increment;
    Begin = Begin + 2 * Scale;
    Index = Index + 1;
end
clear iSig
% PerDoseRect(2) = OrigPerDoseY;

%%% JITTER2 %%%
Screen('FillRect', Window, Black);
vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5) * Refresh);
J2Onset = vbl - BeginTime;
% Until = vbl + RunDesign{k, JITTER2DUR} - Refresh;
Screen('FillRect', Window, Grey);

sca;
