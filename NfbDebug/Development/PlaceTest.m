sca;
clear all;
DeviceIndex = [];

PsychDebugWindowConfiguration

PsychDefaultSetup(2); % default settings
% Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
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

%%% TEXT SETUP %%%
OldSize = Screen('TextSize', Window, 100);
WillImpText = 'Will\nImprove?';
[~, ~, WillImpRect] = DrawFormattedText(Window, ...
    WillImpText, 'center', 'center', White);
WillImpRect = CenterRectOnPointd(WillImpRect, XCenter, YCenter - 138);

Screen('TextStyle', Window, 1);
[~, ~, YesRect] = DrawFormattedText(Window, ...
    'YES', 'center', 'center', White);
YesRect = CenterRectOnPointd(YesRect, XCenter - 200, YCenter);
[~, ~, NoRect] = DrawFormattedText(Window, ...
    'NO', 'center', 'center', White);
NoRect = CenterRectOnPointd(NoRect, XCenter + 200, YCenter);

% get "Improved?" size
Screen('TextStyle', Window, 0);
ImprovedText = 'Improved?';
[~, ~, ImprovedRect] = DrawFormattedText(Window, ...
    ImprovedText, 'center', 'center', White);
ImprovedRect = CenterRectOnPointd(ImprovedRect, XCenter, YCenter - 95);

Screen('FillRect', Window, Black);
Text = {
% 'SampleText', FontSize, FontType, FontStyle, 
% 'Will\nImprove?', 100, 'Arial', 0, WillImpRect;
% 'YES', 100, 'Arial', 1, YesRect;
% 'NO', 100, 'Arial', 1, NoRect;
% 'Improved?', 100, 'Arial', 0, ImprovedRect;
'100', 35, 'Arial', 0, [1512 430 1569 454];
'50', 35, 'Arial', 0, [1530 707 1568 731];
'0', 35, 'Arial', 0, [1549 986 1568 1010];
'Protocol IZTP10081', 50, 'Arial', 1, [];
'Protocol AA481DG', 50, 'Arial', 1, [];
};

% Initialize all text positions to center
Selected = 1;
Screen('FillRect', Window, ...
    [0.5 0.5 0.5; 0 0 0]', ...
    [InfGreyRectCenter' InfBlackRectCenter']);
for i = 1:size(Text, 1)
    Screen('TextSize', Window, Text{i, 2});
    Screen('TextFont', Window, Text{i, 3});
    Screen('TextStyle', Window, Text{i, 4});
    if i ~= Selected
        TextColor = White;
    else
        TextColor = [0.1 0.1 1];
    end
    [~, ~, Rect] = DrawFormattedText(Window, Text{i, 1}, 'center', 'center', TextColor, ...
        [], [], [], [], [], Text{i, 5});
    Text{i, end} = Rect;
end
Screen('DrawLine', Window, White, 0, YCenter, round(2*XCenter), YCenter);
Screen('FrameRect', Window, White, CenteredFrame);
Screen('Flip', Window);

EscapeKey = KbName('ESCAPE');
ReturnKey = KbName('Return');
BackspaceKey = KbName('BackSpace');
TabKey = KbName('tab');
Right = KbName('RightArrow');
Left = KbName('LeftArrow');
Down = KbName('DownArrow');
Up = KbName('UpArrow');
Space = KbName('space');

FineTune = 0;
while 1
    [Pressed, Secs, KeyCode] = KbCheck;
    if Pressed
        if KeyCode(EscapeKey)
            break;
        elseif KeyCode(TabKey)
            Selected = Selected + 1;
            if Selected > size(Text, 1)
                Selected = 1;
            end
            KbReleaseWait;
        elseif KeyCode(Right)
            Text{Selected, end}(1) = Text{Selected, end}(1) + 1;
            Text{Selected, end}(3) = Text{Selected, end}(3) + 1;
            if FineTune
                KbReleaseWait;
            end
        elseif KeyCode(Left)
            Text{Selected, end}(1) = Text{Selected, end}(1) - 1;
            Text{Selected, end}(3) = Text{Selected, end}(3) - 1;
            if FineTune
                KbReleaseWait;
            end
        elseif KeyCode(Down)
            Text{Selected, end}(2) = Text{Selected, end}(2) + 1;
            Text{Selected, end}(4) = Text{Selected, end}(4) + 1;
            if FineTune
                KbReleaseWait;
            end
        elseif KeyCode(Up)
            Text{Selected, end}(2) = Text{Selected, end}(2) - 1;
            Text{Selected, end}(4) = Text{Selected, end}(4) - 1;
            if FineTune
                KbReleaseWait;
            end
        elseif KeyCode(Space)
            if FineTune
                FineTune = 0;
            else
                FineTune = 1;
            end
            KbReleaseWait;
        end
        
        % redraw everything
        Screen('FillRect', Window, Black);
        Screen('FillRect', Window, ...
            [0.5 0.5 0.5; 0 0 0]', ...
            [InfGreyRectCenter' InfBlackRectCenter']);
        for iNum = 1:size(Text, 1)
            Screen('TextSize', Window, Text{iNum, 2});
            Screen('TextFont', Window, Text{iNum, 3});
            Screen('TextStyle', Window, Text{iNum, 4});
            if iNum ~= Selected
                TextColor = White;
            else
                TextColor = [0.1 0.1 1];
            end
            DrawFormattedText(Window, Text{iNum, 1}, 'center', 'center', ...
                TextColor, [], [], [], [], [], Text{iNum, end});
        end
        Screen('DrawLine', Window, White, 0, YCenter, round(2*XCenter), YCenter);
        Screen('FrameRect', Window, White, CenteredFrame);
        Screen('Flip', Window);
        Pressed = 0;
    end
end
                
sca;
