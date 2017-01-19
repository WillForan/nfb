clear all;
PsychDebugWindowConfiguration

try
    % change preferences
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'VisualDebugLevel', 3);

    % screen initialization and refresh
    Screens = Screen('Screens'); % get scren number
    ScreenNumber = max(Screens);
    [Window, Rect] = Screen('OpenWindow', ScreenNumber);
    Info = Screen('GetWindowInfo', Window);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    [Refresh] = Screen('GetFlipInterval', Window);
    OutIndex = 1;

    % print header
    OutText{OutIndex} = sprintf('\n*** QueryDevices INFORMATION ***\n');
    OutIndex = OutIndex + 1;

    % get version
    OutText{OutIndex} = sprintf('%s\n\n', PsychtoolboxVersion);
    OutIndex = OutIndex + 1;

    % get all screens information
    for i = ScreenNumber
        Hz = Screen('FrameRate', i);
        SRect = Screen('Rect', i);

        OutText{OutIndex} = sprintf('Screen %d, FrameRate:  %0.2f Hz\n', ...
            i, Hz);
        OutIndex = OutIndex + 1;

        OutText{OutIndex} = sprintf('Screen %d, Resolution: %d x %d\n', ...
            i, SRect(3), SRect(4));
        OutIndex = OutIndex + 1;
    end
    clear i;
    OutText{OutIndex} = sprintf('\n');
    OutIndex = OutIndex + 1;
    
    % get screen information
    OutText{OutIndex} = [sprintf('Screen refresh rate: %0.4f Hz\n', 1/Refresh) ...
        sprintf('Screen resolution  : %d x %d\n\n', Rect(3), Rect(4))];
    OutIndex = OutIndex + 1;
    
    % get devices devices 
    [indices, names, infos] = GetKeyboardIndices;
    for i = 1:numel(indices)
        OutText{OutIndex} = sprintf('%d:%s\n', indices(i), names{i});
        OutIndex = OutIndex + 1;
    end
    OutText{OutIndex}  = sprintf('\n');
    OutIndex = OutIndex + 1;
    
    % get graphics card
    OutText{OutIndex} = sprintf('GLRenderer: %s\n', Info.GLRenderer);
    OutIndex = OutIndex + 1;
    OutText{OutIndex} = sprintf('GLVersion : %s\n', Info.GLVersion);
    OutIndex = OutIndex + 1;
    
    % close output
    OutText{OutIndex} = sprintf('*** QueryDevices INFORMATION ***\n\n');

    OutDir = fullfile(pwd, 'QueryScanner');
    mkdir(OutDir);
    OutFile = fullfile(OutDir, 'QueryDevices.txt');
    Fid = fopen(OutFile, 'w');
    fprintf(1, '\n');
    for i = 1:numel(OutText)
        fprintf(1, '%s', OutText{i});
        fprintf(Fid, '%s', OutText{i});
    end
    fprintf(1, '\n');
    fclose(Fid);

    sca;
    ShowCursor;
    ListenChar(0);
    Priority(0);
catch err
    ShowCursor;
    sca;
    ListenChar(0);
    Priority(0);

    % print error text file
    OutDir = fullfile(pwd, 'QueryScanner');
    mkdir(OutDir);
    OutFile = fullfile(OutDir, 'QueryDevices.txt');
    Fid = fopen(OutFile, 'w');
    fprintf(1, 'ERROR: %s\n', err.message);
    fclose(Fid);

    rethrow(err);
end

