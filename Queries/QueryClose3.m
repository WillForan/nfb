clear all;

try
    % setup up diary
    OutDir = fullfile(pwd, 'QueryScanner');
    mkdir(OutDir);
    OutFile = fullfile(OutDir, 'QueryClose3.txt');
    if exist(OutFile, 'file') == 2
        delete(OutFile);
    end
    diary(OutFile);
    
    % change preferences
    KbName('UnifyKeyNames');
    if ~IsLinux()
        Screen('Preference', 'SkipSyncTests', 2);
    end
    Screen('Preference', 'VisualDebugLevel', 3);
    
    % screen initialization and refresh
    Screens = Screen('Screens'); % get scren number
    if IsLinux || IsOSX
        ScreenNumber = max(Screens);
    else
        ScreenNumber = 1;
    end
    [Window, Rect] = Screen('OpenWindow', ScreenNumber);
    Screen('ColorRange', Window, 1, [], 1);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    [Refresh] = Screen('GetFlipInterval', Window);
    
    % Define commonly used colors
    White = WhiteIndex(ScreenNumber);
    Black = BlackIndex(ScreenNumber);
    Gray = White * 0.5;
    BgColor = [45 59 55] * 1/255;
    UnfilledColor = [38 41 26] * 1/255;
    BoxColor = [21 32 17] * 1/255;
    FilledColor = [41 249 64] * 1/255;
    Screen('FillRect', Window, BgColor);
    
    % set up text properties
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 50);
    
    % draw on screen
    Until = 0;
    for i = 1:5
        DrawFormattedText(Window, ...
            ['This is to test Screen(''Close'', Window).\n\n' ...
            'This window should terminate in ' num2str(6-i) ' second(s).'], ...
            'center', 'center', [1 1 1]);
        vbl = Screen('Flip', Window, Until);
        Until = vbl + 1 - Refresh * 0.5;
    end
    WaitSecs('UntilTime', Until);

    Screen('Close', Window);
    ShowCursor;
    Priority(0);
    diary off
catch err
    ShowCursor;
    Screen('Close', Window);
    Priority(0);
    fprintf(1, '%s\n', err.message);
    diary off
    rethrow(err);
end

