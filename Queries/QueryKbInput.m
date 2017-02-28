clear all;

try
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
    [Window, Rect] = Screen('OpenWindow', ScreenNumber, [0 0 0]);
    Screen('ColorRange', Window, 1, [], 1);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    [Refresh] = Screen('GetFlipInterval', Window);
    
    KbNames = KbName('KeyNames');
    EscapeKey = KbName('ESCAPE');
    SignalKey = KbName('6^');
    LeftShift = KbName('LeftShift');
    RightShift = KbName('RightShift');
    KbReleaseWait;
    
    % set up text properties
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 50);
    Screen('TextColor', Window, [1 1 1]);
    
    % initialize screen
    DrawFormattedText(Window, 'Waiting for keyboard input...', 'center', 'center');
    Screen('Flip', Window);

    OutIndex = 1;    
    fprintf(1, '\n*** QueryKbInput INFORMATION ***\n');
    while 1
        [Pressed, Secs, KeyCode] = KbCheck;
        if Pressed
            if KeyCode(EscapeKey)
                break;
            elseif KeyCode(SignalKey) && (KeyCode(LeftShift) || KeyCode(RightShift))
                fprintf(1, 'Signal triggered\n');
                fprintf(1, 'Exiting\n');
                break;
            end
            fprintf(1, '%s\n', KbNames{find(KeyCode)});
            KeysPressed = KbNames(find(KeyCode));
            Str = '';
            for i = 1:numel(KeysPressed)
                Str = [Str, KeysPressed{i}, ' '];
                OutText{OutIndex} = Str;
                OutIndex = OutIndex + 1;
            end
            Str = strcat(Str, '\n\nPress ESC to quit.\n');
            DrawFormattedText(Window, Str, 'center', 'center');
            Screen('Flip', Window);
            KbReleaseWait;
        end
    end
    fprintf(1, '\n*** QueryKbInput INFORMATION ***\n');

    OutDir = fullfile(pwd, 'QueryScanner');
    mkdir(OutDir);
    Outfile = fullfile(OutDir, 'QueryKbInput.txt');
    Fid = fopen(Outfile, 'w');
    for i = 1:numel(OutText)
        fprintf(Fid, '%s\n', OutText{i});
    end
    fclose(Fid);

    sca;
    ShowCursor;
    Priority(0);
catch err
    fclose('all');
    ShowCursor;
    sca;
    Priority(0);

    OutDir = fullfile(pwd, 'QueryScanner');
    mkdir(OutDir);
    Outfile = fullfile(OutDir, 'QueryKbInput.txt');
    Fid = fopen(Outfile, 'w');
    fprintf(Fid, 'ERROR: %s\n', err.message);
    fclose(Fid);

    rethrow(err);
end

