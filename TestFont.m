try
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
    FilledColor = [41 249 64] * 1/255;
    
    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Black);
    %     Screen('Resolution', Window, 1024, 768);
    
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    Refresh = Screen('GetFlipInterval', Window);
    
    % blend
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % testing fonts
    TestStr = 'This is a the test string: 0123456789.\nPress any key to continue';

    Screen('TextSize', Window, 100);
    fonts = {
        'Arial';
        'digital-7';
        'Digital-7';
        'Digital-7 Mono';
    };

    for i = 1:size(fonts)
        str = sprintf('Screen %d\n%s\n%s', i, fonts{i}, TestStr);
        Screen('TextFont', Window, fonts{i});
        DrawFormattedText(Window, str, 'center', 'center', FilledColor);
        Screen('Flip', Window);
        KbStrokeWait;
    end

    DrawFormattedText(Window, 'Goodbye!', 'center', 'center', FilledColor);
    Screen('Flip', Window);
    KbStrokeWait;
    sca;
catch err
    sca;
    rethrow(err);
end

