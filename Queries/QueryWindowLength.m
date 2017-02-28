clear all;

try
    % setup up diary
    OutDir = fullfile(pwd, 'QueryScanner');
    mkdir(OutDir);
    OutFile = fullfile(OutDir, 'QueryFeedback.txt');
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
    
    % blend
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Define commonly used colors
    White = [1 1 1];
    Black = [0 0 0];
    Gray = White * 0.5;
    BgColor = [45 59 55] * 1/255;
    UnfilledColor = [38 41 26] * 1/255;
    BoxColor = [21 32 17] * 1/255;
    FilledColor = [41 249 64] * 1/255;
    Screen('FillRect', Window, BgColor);
    
    % set up keys of interest
    KbNames = KbName('KeyNames');
    EscapeKey = KbName('ESCAPE');
    TabKey = KbName('tab');
    LeftArrowKey = KbName('LeftArrow');
    RightArrowKey = KbName('RightArrow');
    
    % initialize bookkeeping variables
    Mode = 'Continuous';
    Flip = 0;
    RightX = 0;
    
    % prepare for display
    HideCursor;
    
    % initialize screen display
    Screen('FrameRect', Window, [1 1 1], Rect);
    Screen('DrawLines', Window, ...
        [0 RightX; YCenter YCenter], ...
        5, [1 0 0]);
    
    Str = [sprintf('Right X Pixel: %d\n', RightX), ...
           sprintf('Line length:  %d\n', RightX - 0), ...
           sprintf('Move right line with left/right arrow keys\n'), ...
           sprintf('Mode %s (change with TAB)\n', Mode), ...
           sprintf('Quit with ESC\n')];
    DrawFormattedText(Window, Str, [], [], FilledColor);
    Screen('Flip', Window);
    
    while 1
        [Pressed, Secs, KeyCode] = KbCheck;
        if Pressed
            if KeyCode(EscapeKey)
                break;
            elseif KeyCode(TabKey)
                if strcmp(Mode, 'Continuous')
                    Mode = 'Discrete';
                else
                    Mode = 'Continuous';
                end
                KbReleaseWait;
                Flip = 1;
            elseif KeyCode(LeftArrowKey)
                RightX = RightX - 1;
                Flip = 1;
                
                if strcmp(Mode, 'Discrete')
                    KbReleaseWait;
                end
            elseif KeyCode(RightArrowKey)
                RightX = RightX + 1;
                Flip = 1;
                
                if strcmp(Mode, 'Discrete')
                    KbReleaseWait;
                end
            end
            
            if Flip
                Screen('FrameRect', Window, [1 1 1], Rect);
                Screen('DrawLines', Window, ...
                    [0 RightX; YCenter YCenter], ...
                    5, [1 0 0]);

                Str = [sprintf('Right X Pixel: %d\n', RightX), ...
                       sprintf('Line length:  %d\n', RightX - 0), ...
                       sprintf('Move right line with left/right arrow keys\n'), ...
                       sprintf('Mode %s (change with TAB)\n', Mode), ...
                       sprintf('Quit with ESC\n')];
                DrawFormattedText(Window, Str, [], [], FilledColor);
                Screen('Flip', Window);
            end
        end
    end

    sca;
    ShowCursor;
    Priority(0);
    diary off
catch err
    sca;
    ShowCursor;
    Priority(0);
    fprintf(1, '%s\n', err.message);
    diary off
    rethrow(err);
end

