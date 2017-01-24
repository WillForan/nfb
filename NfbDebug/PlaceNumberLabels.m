sca;
clear;
DeviceIndex = [];

% use debugging for now
PsychDebugWindowConfiguration

PsychDefaultSetup(2); % default settings
Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
Screen('Preference', 'DefaultFontSize', 35);
Screen('Preference', 'DefaultFontName', 'Arial');
Screens = Screen('Screens');
ScreenNumber = max(Screens);
% Screen('Resolution', ScreenNumber, 1024, 768)

% Define black and white
White = WhiteIndex(ScreenNumber);
Black = BlackIndex(ScreenNumber);
Grey = White * 0.5;

% we want X = Left-Right, Y = top-bottom
[Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Grey); % open Window on Screen
OffWindow = Screen('OpenOffScreenWindow', Window, Grey);
PriorityLevel = MaxPriority(Window);
Priority(PriorityLevel);
[XCenter, YCenter] = RectCenter(Rect); % get the center of the coordinate Window
Refresh = Screen('GetFlipInterval', Window);

% set default text type for window
Screen('TextColor', Window, White);

% blend
Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% draw the feedback screen objects from right to left
% start with feedback rect location
FeedbackRect = [0 0 750 750];
FeedbackXCenter = 119 + XCenter; 
FeedbackYCenter = YCenter;
CenteredFeedback = CenterRectOnPointd(FeedbackRect, ...
    FeedbackXCenter, FeedbackYCenter);

% dose rect location
BarRect = [0 0 50 750];
BarXCenter = XCenter - 325 - 5 - NeuroBox(4);
BarYCenter = YCenter;
CenteredBar = CenterRectOnPointd(BarRect, ...
    BarXCenter, BarYCenter);

% outline working space
Frame = [0 0 1025 769];
CenteredFrame = CenterRectOnPointd(Frame, XCenter, YCenter);
Screen('FrameRect', OffWindow, Black, CenteredFrame);

% draw Neurofeedback Signal label
[NeuroTexture NeuroBox] = MakeTextTexture(Window, ...
    'Neurofeedback Signal', Grey, [], 55);
NeuroXLoc = XCenter - 325 - 5;
tmp = CenterRectOnPointd(NeuroBox, NeuroXLoc, YCenter);
Screen('DrawTexture', OffWindow, NeuroTexture, [], tmp, -90);

% make feedback and does rects
Screen('FillRect', OffWindow, Black, [CenteredFeedback' CenteredBar']);

% draw offscreen to screen
Screen('DrawTexture', Window, OffWindow);

EscapeKey = KbName('ESCAPE');
ReturnKey = KbName('Return');
BackspaceKey = KbName('BackSpace');
TabKey = KbName('tab');
Right = KbName('RightArrow');
Left = KbName('LeftArrow');
Down = KbName('DownArrow');
Up = KbName('UpArrow');
Space = KbName('space');

Numbers = {
    '100', [XCenter 10],
    '50', [XCenter 200],
    '0', [XCenter 300],
    '-50', [XCenter 400],
    '-100' [XCenter 500]
};
load('NumberPositions.mat');

TextBoxes = zeros(size(Numbers, 1), 3);

Selected = 1;
for iNum = 1:size(Numbers, 1)
    if iNum ~= Selected
        [TextBoxes(iNum, 1) TextBoxes(iNum, 2) TextBoxes(iNum, 3)] = Screen(...
            'DrawText', Window, ...
            Numbers{iNum, 1}, ...
            Numbers{iNum, 2}(1), ...
            Numbers{iNum, 2}(2), White);
    end
end
[TextBoxes(Selected, 1) TextBoxes(Selected, 2) TextBoxes(Selected, 3)] = Screen(...
    'DrawText', Window, ...
    Numbers{Selected, 1}, ...
    Numbers{Selected, 2}(1), ...
    Numbers{Selected, 2}(2), [0.1 0.1 1]);
Screen('Flip', Window);

FineTune = 0;
while 1
    [Pressed, Secs, KeyCode] = KbCheck;
    if Pressed
        if KeyCode(EscapeKey)
            break;
        elseif KeyCode(TabKey)
            Selected = Selected + 1;
            if Selected > size(Numbers, 1)
                Selected = 1;
            end
            KbReleaseWait;
        elseif KeyCode(Right)
            Numbers{Selected, 2}(1) = Numbers{Selected, 2}(1) + 1;
            if FineTune
                KbReleaseWait;
            end
        elseif KeyCode(Left)
            Numbers{Selected, 2}(1) = Numbers{Selected, 2}(1) - 1;
            if FineTune
                KbReleaseWait;
            end
        elseif KeyCode(Down)
            Numbers{Selected, 2}(2) = Numbers{Selected, 2}(2) + 1;
            if FineTune
                KbReleaseWait;
            end
        elseif KeyCode(Up)
            Numbers{Selected, 2}(2) = Numbers{Selected, 2}(2) - 1;
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
        Screen('DrawTexture', Window, OffWindow);
        for iNum = 1:size(Numbers, 1)
            if iNum ~= Selected
                [TextBoxes(iNum, 1) TextBoxes(iNum, 2) TextBoxes(iNum, 3)] = Screen(...
                    'DrawText', Window, ...
                    Numbers{iNum, 1}, ...
                    Numbers{iNum, 2}(1), ...
                    Numbers{iNum, 2}(2), White);
            end
        end
        [TextBoxes(Selected, 1) TextBoxes(Selected, 2) TextBoxes(Selected, 3)] = Screen(...
            'DrawText', Window, ...
            Numbers{Selected, 1}, ...
            Numbers{Selected, 2}(1), ...
            Numbers{Selected, 2}(2), [0.1 0.1 1]);
        Screen('DrawLine', Window, Black, ...
            CenteredFeedback(1)-5, ...
            1, ...
            CenteredFeedback(1)-5, ...
            1440);

        Screen('DrawLine', Window, White, ...
            CenteredFeedback(1)-60, ...
            CenteredFeedback(2), ...
            CenteredFeedback(3), ...
            CenteredFeedback(2));
        Screen('DrawLine', Window, White, ...
            CenteredFeedback(1)-60, ...
            (YCenter + CenteredFeedback(2))/2, ...
            CenteredFeedback(3), ...
            (YCenter + CenteredFeedback(2))/2);
        Screen('DrawLine', Window, White, ...
            CenteredFeedback(1)-60, ...
            YCenter, ...
            CenteredFeedback(1), ...
            YCenter);
        Screen('DrawLine', Window, White, ...
            CenteredFeedback(1)-60, ...
            (YCenter + CenteredFeedback(4))/2, ...
            CenteredFeedback(3), ...
            (YCenter + CenteredFeedback(4))/2);
        Screen('DrawLine', Window, White, ...
            CenteredFeedback(1)-60, ...
            CenteredFeedback(4), ...
            CenteredFeedback(3), ...
            CenteredFeedback(4));
        Screen('Flip', Window);
        Pressed = 0;
    end
end
                
sca;
