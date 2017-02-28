function RestingTask(varargin)
% function RestingTask([InScan], [Participant])

try
    sca;
    DeviceIndex = [];
    
    if isempty(varargin)
        Responses = inputdlg({'Scan (1:Yes, 0:No):', ...
            'Participant ID:', ...
            'Screen:'}, ...
            '', 1, {'1', '', '1'});
        InScan = str2double(Responses{1});
        Participant = Responses{2};
        ScreenNumber = str2double(Responses{3});
    elseif numel(varargin) == 2
        InScan = varargin{1};
        Participant = varargin{2};
        ScreenNumber = varargin{3};
    else
        error('ERROR: Invalid number of arguments.');
    end

    OutDir = fullfile('Resting', Participant);
    mkdir(OutDir);
    
    % start diary to log strange PTB behaviors
    OutName = sprintf('%s_Diary_%s', Participant, ...
        datestr(now, 'yyyymmdd_HHMMSS'));
    DiaryFile = fullfile(OutDir, [OutName '.txt']);
    diary(DiaryFile);
    
    if InScan == 0
        PsychDebugWindowConfiguration
    end

    KbName('UnifyKeyNames');
    if ~IsLinux()
        Screen('Preference', 'SkipSyncTests', 2);
    end
    Screen('Preference', 'VisualDebugLevel', 3); % skip introduction Screen
    Screen('Preference', 'DefaultFontSize', 35);
    Screen('Preference', 'DefaultFontName', 'Arial');
    Screens = Screen('Screens'); % get scren number
    Offset = 0.5;

    % Define black and white
    White = [1 1 1];
    Black = [0 0 0];
    Grey = White * 0.7;

    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = Screen('OpenWindow', ScreenNumber, Black);
    Screen('ColorRange', Window, 1, [], 1);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    Refresh = Screen('GetFlipInterval', Window);
    ScanRect = [0 0 1024 768];
    [ScanCenter(1), ScanCenter(2)] = RectCenter(ScanRect);
    if InScan == 1
        HideCursor(ScreenNumber);
    end

    % blend
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % specify duration
    NumFrames = round(480/Refresh);

    % specify trigger key
    TriggerKey = KbName('=+');
    
    % show directions while waiting for trigger '^'
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 35);
    Screen('TextStyle', Window, 0);
    DrawFormattedText(Window, ... 
        ['This is resting state scan.\n'...
         'Stare at the crosshair while it displays.\n\n' ...
         'Waiting for scanner signal ''='' to continue.'], ...
        'center', 'center', Grey);
    Screen('Flip', Window);
    while 1
        [Pressed, Secs, KeyCode] = KbCheck(DeviceIndex);
        if Pressed && KeyCode(TriggerKey)
            break;
        end
    end

    % do the resting task   
    Screen('TextSize', Window, 100); 
    DrawFormattedText(Window, '+', 'center', 'center', Grey);
    BeginTime = Screen('Flip', Window);

    % end task
    Screen('TextSize', Window, 35);
    DrawFormattedText(Window, 'End resting state.', 'center', 'center', Grey);
    EndTime = Screen('Flip', Window, BeginTime + (NumFrames - Offset) * Refresh); 
    WaitSecs(1);

    % close everything
    sca;
    ShowCursor;
    Priority(0);

    TotalTime = EndTime - BeginTime;
    fprintf(1, 'Total duration: %0.2f seconds (%0.2f minutes)\n', ...
        TotalTime, TotalTime/60);
    
    diary off
catch err
    sca;
    ShowCursor;
    Priority(0);
    fprintf(1, '%s\n', err.message);
    diary off
    rethrow(err);
end
