sca;
clear all;
addpath('/home/heffjos/Documents/Work/Pecina/RevisedNeurofeedback/');
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

% make a frame for my testing purposes
Frame = [0 0 1025 769];
CenteredFrame = CenterRectOnPointd(Frame, XCenter, YCenter);

%%% FEEDBACK SETUP
% 100, 50, 0, -50, -100
% x = 52, 35, 16, 46, 65
% y = 24  for all
% NeuroBox = [0 0 592 58];
% 69 - 5
% 69 + 5 = 74 + 58/2 = 103
Pos100 = Screen('TextBounds', Window, '100');  % [0 0 52 24]
Pos50 = Screen('TextBounds', Window, '50');    % [0 0 35 24]
Zero = Screen('TextBounds', Window, '0');      % [0 0 16 24]
Neg50 = Screen('TextBounds', Window, '-50');   % [0 0 46 24]
Neg100 = Screen('TextBounds', Window, '-100'); % [0 0 65 24]

FeedbackRect = [0 0 920 750];
FeedbackXCenter = 52 + XCenter;
CenteredFeedback = CenterRectOnPointd(FeedbackRect, FeedbackXCenter, YCenter);
RefX = CenteredFeedback(1);
RefY = CenteredFeedback(2);

Screen('FillRect', Window, ...
    [0.5 0.5 0.5; 0 0 0]', ...
    [Rect' CenteredFeedback']);

% set "Neurofeedback Signal" label location
[NeuroTexture NeuroBox] = MakeTextTexture(Window, ...
    'Neurofeedback Signal', Grey, [], 55);
NeuroXLoc = RefX - 69 - 5;
NeuroLoc = CenterRectOnPointd(NeuroBox, NeuroXLoc, YCenter);

% create noise signal for testing
Scale = 2; % move by this many points across signals
FlipSecs = 1/30; % time to display signal
WaitFrames = round(FlipSecs / Refresh); % display signal every this frame
% set MaxX, this value determines the number of seconds to move from one
% end of the screen to the other; FlipSecs and MaxX depend on each other
MaxX = Scale*120;

% create original and plotted ranges
XRange = [0 (MaxX-1)];
YRange = [-100 100];
NewXRange = [CenteredFeedback(1) CenteredFeedback(3)];
NewYRange = [CenteredFeedback(2) CenteredFeedback(4)];

% dummy signals
X = 0:(MaxX-1);
N = Scale*4*1/FlipSecs + Scale*10*1/FlipSecs-1;
Sin1 = 5.5*sin(2*pi*(1:N)*(1/60));
Sin2 = 1*sin(2*pi*(1:N)*(1/2));
Ref = 10*sin(2*pi*(1:N)*(1/N));
Noise = 5*randn(1, N);

Index1 = 1:(5*Scale*1/FlipSecs-1);
Index2 = (Index1(end)+1):(Index1(end)+1+5*Scale*1/FlipSecs-1);
Index3 = (Index2(end)+1):N;

Inc = 85/length(Index2);
Ramp = 0:Inc:(85-Inc);
Noise(Index2) = Noise(Index2) + Ramp + Sin1(Index2) + Sin2(Index2);
Noise(Index3) = Noise(Index3) + 85 + Sin1(Index3) + Sin2(Index3);
Noise(Noise > 100) = 99;

% convert from old range values to new range values
NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
NewNoise = (Noise-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
NewNoise = NewYRange(2) - NewNoise + NewYRange(1);

% create values that appear as continuous lines when plotted
NewX_Line = zeros(1, 2*(length(NewX)-1));
NewX_Line(1:2:end) = NewX(1:end-1);
NewX_Line(2:2:end) = NewX(2:end);
NewNoise_Line =  zeros(1, 2*(length(NewNoise)-1));
NewNoise_Line(1:2:end) = NewNoise(1:end-1);
NewNoise_Line(2:2:end) = NewNoise(2:end);

Begin = 1;
Index = 1;
for iSig = (2*(MaxX-1)):(2*Scale):length(NewNoise_Line)

    % Draw rectangles
    Screen('FillRect', Window, ...
        [0.5 0.5 0.5; 0 0 0]', ...
        [Rect' CenteredFeedback']);
    
    % Draw "Neurofeedback Signal"
    Screen('DrawTexture', Window, NeuroTexture, [], NeuroLoc, -90);
    
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
    
    % draw frame for testing purposes
    Screen('FrameRect', Window, White, CenteredFrame);

    % draw feedback line
    Screen('DrawLines', Window, ...
        [NewX_Line NewXRange(1) NewXRange(2); ...
        NewNoise_Line(Begin:iSig) sum(NewYRange)/2 sum(NewYRange)/2], ...
        [repmat(4, length(Begin:iSig)/2, 1); 1], ...
        [repmat([1 0 0]', 1, iSig-Begin+1) [1 1 1; 1 1 1]']);

    % do flip here
    if Begin == 1
        vbl(Index) = Screen('Flip', Window);
    else
        vbl(Index) = Screen('Flip', Window, vbl(Index-1) + (WaitFrames - 0.5) * Refresh);
    end

    Begin = Begin + 2 * Scale;
    Index = Index + 1;
end

    
% vbl(Index) = Screen('Flip', Window, vbl(Index-1) + (WaitFrames - 0.5) * Refresh);
KbStrokeWait;
sca;

