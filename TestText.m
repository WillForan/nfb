sca;
clear;
DeviceIndex = [];

% use debugging for now
PsychDebugWindowConfiguration
try
    PsychDefaultSetup(2); % default settings
    Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
    Screen('Preference', 'DefaultFontSize', 35);
    Screens = Screen('Screens'); % get scren number
    ScreenNumber = max(Screens);
    
    % Define black and white
    White = WhiteIndex(ScreenNumber);
    Black = BlackIndex(ScreenNumber);
    Grey = White * 0.5;
    
    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Grey); % open Window on Screen
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect); % get the center of the coordinate Window
    
    % need alpha-blending
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % set sizes for rotated texts
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 60);
    Screen('TextColor', Window, White);
    % Screen('TextStyle', Window, 1+2);
    bbox1 = ceil(Screen('TextBounds', Window, 'Neurofeedback Signal5 ')); 
    bbox2 = bbox1;
    bbox3 = ceil(Screen('TextBounds', Window, 'Neurofeedback Signal5')*1.3); 
    bbox2(3) = bbox2(3) + 1;
    bbox2(4) = bbox2(4) + 1;

    if mod(bbox3(3), 2)
        bbox3(3) = bbox3(3) + 1;
    end
    if mod(bbox3(4), 2)
        bbox3(4) = bbox3(4) + 1;
    end
    
    OffWindow1 = Screen('OpenOffScreenWindow', Window, Grey, bbox1);
    Screen('TextFont', OffWindow1, 'Arial');
    Screen('TextSize', OffWindow1, 60);
    Screen('TextColor', OffWindow1, White);
    tex1 = Screen('DrawText', OffWindow1, 'Neurofeedback Signal5  ', 0, 0, 0);

    OffWindow2 = Screen('OpenOffScreenWindow', Window, Grey, bbox2);
    Screen('TextFont', OffWindow2, 'Arial');
    Screen('TextSize', OffWindow2, 60);
    Screen('TextColor', OffWindow2, White);
    tex2 = Screen('DrawText', OffWindow2, 'Neurofeedback Signal5  ', 0, 0, 0);

    TexRect = ones(bbox3(4), bbox3(3)) * Grey;
    TexRect = Screen('MakeTexture', Window, TexRect);
    DrawFormattedText(TexRect, 'Neurofeedback Signal5', 'center', 'center', 0);

    % middle -     
    Screen('DrawTexture', Window, OffWindow1, [], [], -90);

    % first left of middle - smeared quality
    tmp1 = CenterRectOnPointd(bbox1, XCenter-50, YCenter);
    Screen('DrawTexture', Window, OffWindow1, [], floor(tmp1), -90);

    % second left of middle - good quality   
    tmp2 = CenterRectOnPointd(bbox2, XCenter-100, YCenter);
    Screen('DrawTexture', Window, OffWindow2, [], tmp2, -90);

    % third left of middle -
    tmp3 = CenterRectOnPointd(bbox2, XCenter-150, YCenter);
    Screen('DrawTexture', Window, OffWindow2, [], floor(tmp3), -90);

    % Screen('DrawTexture', Window, OffWindow1, [], OffsetRect(bbox1, XCenter - 100, YCenter), -90, [], [], [], 0);
    % 
    % Screen('DrawText', Window, 'Neurofeedback Signal5', 1, 1, 0);
    
    Screen('Flip', Window);
    
    KbStrokeWait;
    sca;
catch err
    sca;
    rethrow(err);
end
