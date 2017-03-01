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
    ScreenNumber = max(Screens);
    Responses = inputdlg({'Screen:'}, 'ScreenNumber', 1, ...
         {sprintf('%d', ScreenNumber)});
    ScreenNumber = str2double(Responses{1});
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
    
    %%% FEEDBACK SETUP %%%.
    % Feedback rect location; this is used as position reference for most
    % other drawn objects
    FName = fullfile(pwd, '..', 'NfbImages', 'FeedNumImages', 'Feedback.png');
    Im = imread(FName, 'png');
    FeedbackTexture = Screen('MakeTexture', Window, Im);
    
    % create feedback rect for signal drawing
    FeedbackRect = [0 0 920 750];
    BiggerFeedback = [0 0 921 751];
    FeedbackXCenter = 52 + XCenter;
    BiggerXCenter = 51.5 + XCenter;
    CenteredFeedback = CenterRectOnPoint(FeedbackRect, FeedbackXCenter, YCenter);
    CenteredBigger = CenterRectOnPointd(BiggerFeedback, BiggerXCenter, YCenter);
   
    % create original and plotted ranges
    Scale = 2;
    MaxX = Scale*120;
    XRange = [0 (MaxX-1)];
    YRange = [-100 100];
    NewXRange = [CenteredFeedback(1) CenteredFeedback(3)];
    NewYRange = [CenteredFeedback(2) CenteredFeedback(4)];
    
    % set up keys of interest
    KbNames = KbName('KeyNames');
    EscapeKey = KbName('ESCAPE');
    TabKey = KbName('tab');
    LeftArrowKey = KbName('LeftArrow');
    RightArrowKey = KbName('RightArrow');
    
    % initialize bookkeeping variables
    Mode = 'Continuous';
    Flip = 0;
    LeftX = NewXRange(1);
    
    % prepare for display
    HideCursor;
    
    % initialize screen display
    Screen('DrawTexture', Window, FeedbackTexture);
    Screen('FrameRect', Window, [1 1 1], ...
        [Rect' CenteredFeedback' CenteredBigger']);
    Screen('DrawLines', Window, ...
        [LeftX NewXRange(2); sum(NewYRange)/2 sum(NewYRange)/2], ...
        5, [1 0 0;1 0 0]');
    
    Str = [sprintf('Left X Pixel: %d\n', LeftX), ...
           sprintf('Line length:  %d\n', NewXRange(2) - LeftX), ...
           sprintf('Move left line with left/right arrow keys\n'), ...
           sprintf('Mode %s (change with TAB)\n', Mode), ...
           sprintf('Quit with ESC\n')];
    if LeftX == NewXRange(1)
        Str = [Str, ...
            sprintf('\nSignal line length\n')];
    end
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
                LeftX = LeftX - 1;
                Flip = 1;
                
                if strcmp(Mode, 'Discrete')
                    KbReleaseWait;
                end
            elseif KeyCode(RightArrowKey)
                LeftX = LeftX + 1;
                Flip = 1;
                
                if strcmp(Mode, 'Discrete')
                    KbReleaseWait;
                end
            end
            
            if Flip
                Screen('DrawTexture', Window, FeedbackTexture);
                Screen('FrameRect', Window, [1 1 1], ...
                    [Rect' CenteredFeedback' CenteredBigger']);
                
                Screen('DrawLines', Window, ...
                    [LeftX NewXRange(2); sum(NewYRange)/2 sum(NewYRange)/2], ...
                    5, [1 0 0;1 0 0]');

                Str = [sprintf('Left X Pixel: %d\n', LeftX), ...
                       sprintf('Line length:  %d\n', NewXRange(2) - LeftX), ...
                       sprintf('Move left line with left/right arrow keys\n'), ...
                       sprintf('Mode %s (change with TAB)\n', Mode), ...
                       sprintf('Quit with ESC\n')];
                if LeftX == NewXRange(1)
                    Str = [Str, ...
                        sprintf('\nSignal line length\n')];
                end
                DrawFormattedText(Window, Str, [], [], FilledColor);
                Screen('Flip', Window);
                Flip = 0;
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

