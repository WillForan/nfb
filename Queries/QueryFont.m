try
    sca;
    clear all;
    DeviceIndex = [];
    
    PsychDebugWindowConfiguration
    
    PsychDefaultSetup(2); % default settings
    KbName('UnifyKeyNames');
    if ~IsLinux()
        Screen('Preference', 'SkipSyncTests', 2);
    end
    Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
    Screen('Preference', 'DefaultFontSize', 35);
    Screen('Preference', 'DefaultFontName', 'Arial');
    Screens = Screen('Screens'); % get scren number
    if IsLinux || IsOSX
        ScreenNumber = max(Screens);
    else
        ScreenNumber = 1;
    end
    
    % Define black and white
    White = WhiteIndex(ScreenNumber);
    Black = BlackIndex(ScreenNumber);
    Grey = White * 0.5;
    FilledColor = [41 249 64] * 1/255;
    
    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = Screen('OpenWindow', ScreenNumber, Black);
    Screen('ColorRange', Window, 1, [], 1);
    
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
        'Arial', 0;
        'digital-7', 0; % monospaced
        'Digital-7', 0; % monospaced
        'Digital-7 Mono', 0; % monospaced
        'digital 7', 0; % monospaced
        'Digital 7', 0; % monospaced
        'Digital 7 Mono', 0; % monospaced
        'Digital-7 Mono Italic', 0;
        'Digital-7 Mono', 2;
        'LCD', 0; % monospaced
        'segment14', 0; % monospaced
        'digital dismay', 0;
    };

    for i = 1:size(fonts)
        str = sprintf('Screen %d\n%s\n%s\n%d', i, fonts{i, 1}, TestStr, fonts{i, 2});
        Screen('TextFont', Window, fonts{i, 1});
        Screen('TextStyle', Window, fonts{i, 2});
        DrawFormattedText(Window, str, 'center', 'center', FilledColor);
        Screen('Flip', Window);
        KbStrokeWait;
    end

    DrawFormattedText(Window, 'Goodbye! (Press any key to quit.)', 'center', 'center', FilledColor);
    Screen('Flip', Window);
    KbStrokeWait;
    sca;
catch err
    sca;
    rethrow(err);
end

