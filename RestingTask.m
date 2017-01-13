function RestingTask()

    sca;
    clear all;
    DeviceIndex = [];
    
    if isunix
        InScan = -1;
        Suppress = -1;
    
        % Turns on PTB debugging
        while ~any(InScan == [1 0])
            InScan = input('Scan? (1:Yes, 0:No): ');
        end
    
        while ~any(Suppress == [1 0])
            Suppress = input('Suppress? (1: Yes, 0:No): ');
        end
    else
        Responses = inputdlg({'Scan (1:Yes, 0:No):'});
        InScan = str2num(Responses{1});
        Suppress = 1;
    end

    if InScan == 0
        PsychDebugWindowConfiguration
    end

    PsychDefaultSetup(2); % default settings
    Screen('Preference', 'DefaultFontSize', 35);
    Screen('Preference', 'DefaultFontName', 'Arial');
    if Suppress
        Screen('Preference', 'SuppressAllWarnings', 1);
        Screen('Preference', 'Verbosity', 0);
    end
    Screens = Screen('Screens'); % get scren number
    ScreenNumber = max(Screens);

    % Define black and white
    White = WhiteIndex(ScreenNumber);
    Black = BlackIndex(ScreenNumber);
    Grey = White * 0.5;

    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Black);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    Refresh = Screen('GetFlipInterval', Window);
    ScanRect = [0 0 1024 768];
    [ScanCenter(1), ScanCenter(2)] = RectCenter(ScanRect);

    % blend
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % specify duration
    NumFrames = round(480/Refresh);

    KbEventFlush;
    
    % show directions while waiting for trigger '^'
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 35);
    Screen('TextStyle', Window, 0);
    DrawFormattedText(Window, ... 
        ['The next scan is resting state.\n'...
         'Stare at the crosshair for the entire duration.\n\n' ...
         'Waiting for ''^'' to continue.'], ...
        'center', 'center', Grey);
    Screen('Flip', Window);
    FlushEvents;
    ListenChar;
    while 1
        if CharAvail && GetChar == '^'
            break;
        end
    end

    % do the resting task   
    Screen('TextSize', Window, 100); 
    DrawFormattedText(Window, '+', 'center', 'center', Grey);
    BeginTime = Screen('Flip', Window);

    % end task
    Screen('TextSize', Window, 35);
    DrawFormattedText(Window, 'Goodbye!', 'center', 'center', Grey);
    fprintf(1, 'BeginTime: %0.2f\n', BeginTime);
    fprintf(1, 'EndTime:   %0.2f\n', BeginTime + 480 - 0.5 * Refresh);
    EndTime = Screen('Flip', Window, BeginTime + (NumFrames - 0.5) * Refresh); 
    WaitSecs(1.5);

    % close everything
    Screen('Close', Window);
    sca;
    Priority(0);

    TotalTime = EndTime - BeginTime;
    fprintf(1, 'Total duration: %0.2f seconds (%0.2f minutes)\n', ...
        TotalTime, TotalTime/60);
end
