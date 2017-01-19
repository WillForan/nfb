clear all;

try
    % hide intro screens
    Screen('Preference', 'VisualDebugLevel', 3);
    
    % enter default setup
    PsychDefaultSetup(2);

    % screen initialization and refresh
    Screens = Screen('Screens'); % get scren number
    ScreenNumber = max(Screens);
    [Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, [0 0 0]);
    Screen('ColorRange', Window, 1, [], 1);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    [Refresh] = Screen('GetFlipInterval', Window);

    % set up text properties
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 100);
    Screen('TextColor', Window, [1 1 1]);

    % now draw on screen
    Until = 0;
    for i = [3 2 1]
        OutText = ['No problems with screen detected.\n' ...
                   'This will close in ' num2str(i) ' seconds.\n'];
        DrawFormattedText(Window, OutText, 'center', 'center');
        Vbl = Screen('Flip', Window, Until);
        Until = Vbl + 1 - Refresh * 0.5;
    end
    WaitSecs('UntilTime', Until);

    % print diagnostic file
    OutDir = fullfile(pwd, 'QueryScanner');
    mkdir(OutDir);
    Outfile = fullfile(OutDir, 'QueryScreen.txt');
    Fid = fopen(Outfile, 'w');
    fprintf(Fid, 'No problems detected with screen.\n');
    fclose(Fid);

    % now close everything
    ShowCursor;
    sca;
    ListenChar(0);
    Priority(0);
catch
    ShowCursor;
    sca;
    ListenChar(0);
    Priority(0);
    err = psychlasterror;

    % print diagnostic file
    OutDir = fullfile(pwd, 'QueryScanner');
    mkdir(OutDir);
    Outfile = fullfile(OutDir, 'QueryScreen.txt');
    Fid = fopen(Outfile, 'w');
    fprintf(Fid, 'There were problems with screen.\n');
    fprintf(Fid, 'Message:    %s\n', err.message);
    fprintf(Fid, 'Identifier: %s\n', err.identifier);
    fclose(Fid);

    psychrethrow(psychlasterror);
end


               
