clear all;

try
    % change preferences
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'VisualDebugLevel', 3);

    % screen initialization and refresh
    Screens = Screen('Screens'); % get scren number
    ScreenNumber = max(Screens);
    [Window, Rect] = Screen('OpenWindow', ScreenNumber, [0 0 0]);
    Screen('ColorRange', Window, 1, [], 1);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    [Refresh] = Screen('GetFlipInterval', Window);
    
    KbName('UnifyKeyNames');
    KbNames = KbName('KeyNames');
    EscapeKey = KbName('ESCAPE');
    SignalKey = KbName('6^');
    LeftShift = KbName('LeftShift');
    RightShift = KbName('RightShift');
    KbReleaseWait;
    
    % set up text properties
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 100);
    Screen('TextColor', Window, [1 1 1]);
    
    % initialize screen
    DrawFormattedText(Window, 'Waiting for keyboard input...', 'center', 'center');
    Screen('Flip', Window);

    ListenChar(2);
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
    ListenChar(0);
    Priority(0);
catch
    ShowCursor;
    sca;
    ListenChar(0);
    Priority(0);
    fclose('all');
    psychrethrow(psychlasterror);
end

