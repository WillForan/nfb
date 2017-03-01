clear all;
PsychDebugWindowConfiguration

try
    KbReleaseWait;

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
    [Window, Rect] = Screen('OpenWindow', ScreenNumber, [0 0 0]);
    Screen('ColorRange', Window, 1, [], 1);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    [Refresh] = Screen('GetFlipInterval', Window);
    
    KbNames = KbName('KeyNames');

    % set up text properties
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 50);
    Screen('TextColor', Window, [1 1 1]);

    % create KbQueue
    KbQueueCreate([]);

    DrawFormattedText(Window, ['Waiting for scanner trigger\n\n' ...
        'Do NOT press any other buttons on input computer'], 'center', 'center');
    BeginTime = Screen('Flip', Window);

    KbQueueStart([]);

    while 1
        [Pressed, TimeKeysPressed] = KbQueueCheck([]);
        if Pressed
            % get keys
            TimeKeysPressed(TimeKeysPressed == 0) = nan;
            [TimeKeysPressed, Reorder] = sort(TimeKeysPressed);
            KeysPressed = KbNames(Reorder(~isnan(TimeKeysPressed)));
            TimeKeysPressed(isnan(TimeKeysPressed)) = [];
            for i = 1:numel(KeysPressed)
                FirstKeySet{i, 1} = KeysPressed{i};
                FirstKeySet{i, 2} = TimeKeysPressed(i) - BeginTime;
            end
            clear i
            
            DrawFormattedText(Window, ['Trigger found\n\n' ...
                'Waiting 2 seconds. Do NOT press anything in the mean time.'], ...
                'center', 'center');
            Screen('Flip', Window);
            WaitSecs(2);
            KbQueueStop([]);
            break;
        end
    end

    [Pressed, TimeKeysPressed] = KbQueueCheck([]);
    KbQueueRelease([]);
    TimeKeysPressed(TimeKeysPressed == 0) = nan;
    [TimeKeysPressed, Reorder] = sort(TimeKeysPressed);
    KeysPressed = KbNames(Reorder(~isnan(TimeKeysPressed)));
    TimeKeysPressed(isnan(TimeKeysPressed)) = [];
    for i = 1:numel(KeysPressed)
        SecondKeySet{i, 1} = KeysPressed{i};
        SecondKeySet{i, 2} = TimeKeysPressed(i) - BeginTime;
    end
    clear i

    OutDir = fullfile(pwd, 'QueryScanner');
    mkdir(OutDir);
    Outfile = fullfile(OutDir, 'QueryTrigger.txt');
    Fid = fopen(Outfile, 'w');

    fprintf(Fid, '*** First key set ***\n');
    for i = 1:size(FirstKeySet, 1)
        fprintf(Fid, '%s %0.4f\n', FirstKeySet{i, 1}, FirstKeySet{i, 2});
    end
    clear i

    fprintf(Fid, '*** Second key set ***\n');
    if exist('SecondKeySet')
        for i = 1:size(SecondKeySet, 1)
            fprintf(Fid, '%s %0.4f\n', SecondKeySet{i, 1}, SecondKeySet{i, 2});
        end
    end
    clear i
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
    Outfile = fullfile(OutDir, 'QueryTrigger.txt');
    Fid = fopen(Outfile, 'w');
    fprintf(Fid, 'ERROR: %s\n', err.message);
    fclose(Fid);

    rethrow(err);
end
