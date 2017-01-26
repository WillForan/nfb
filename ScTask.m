function ScTask(varargin)
% function SogcialCognitionTask([Scan], [Participant], [Run1], [Order1], [Run2],
%   [Order2], [Testing])

try
    sca;
    DeviceIndex = [];

    if isempty(varargin)
        Responses = inputdlg({'Scan (1:Yes, 0:No):', ...
            'Participant ID:', ...
            'Run1: 1 - 5:', ...
            'Run1 Order: 1 - 2:', ...
            'Run2: 1 - 5:', ...
            'Run2 Order: 1 - 2:', ...
            'Testing: (1:Yes, 0:No)'}, '', 1, {'', '', '', '1', '', '2', ''});
        InScan = str2double(Responses{1});
        Participant = Responses{2};
        if isempty(Responses{5})
            Runs = [str2double(Responses{3}) str2double(Responses{4})];
        else
            Runs = [str2double(Responses{3}) str2double(Responses{4});
                    str2double(Responses{5}) str2double(Responses{6})];
        end
        Testing = str2double(Responses{7});
    elseif numel(varargin) == 7
        InScan = varargin{1};
        Participant = varargin{2};
        if isempty(varargin{5})
            Runs = [varargin{3} varargin{4}];
        else
            Runs = [varargin{3} varargin{4};
                    varargin{5} varargin{6}];
        end
        Testing = varargin{7};
    else
        error('Invalid number of arguments.');
    end

    if InScan == 0
        PsychDebugWindowConfiguration
    else
        HideCursor;
        ListenChar(-1);
    end
    
    OutDir = fullfile(pwd, 'ScResponses', Participant);
    mkdir(OutDir);

    % start diary to log strange PTB behaviors
    OutName = sprintf('%s_Sc_Diary_%s', Participant, ...
        datestr(now, 'yyyymmdd_HHMMSS'));
    DiaryFile = fullfile(OutDir, [OutName '.txt']);
    diary(DiaryFile);

    % print out options
    OptionText = [sprintf('*** OPTIONS ***\n') ...
        sprintf('OPTIONS: InScan      %d\n', InScan) ...
        sprintf('OPTIONS: Participant %s\n', Participant) ...
        sprintf('OPTIONS: Run1        %d\n', Runs(1)) ...
        sprintf('OPTIONS: Run2        %d\n', Runs(2)) ...
        sprintf('OPTIONS: Testing     %d\n', Testing) ...
        sprintf('*** OPTIONS ***\n\n')];
    fprintf(1, '\n%s', OptionText);
    
    % read in design
    if Testing
        DesignFile = fullfile(pwd, 'ScDebug', 'Development', 'ScTestOrder.csv');
    else
        DesignFile = fullfile(pwd, 'ScDebug', 'Development', 'ScDesign.csv');
    end
    DesignFid = fopen(DesignFile, 'r');
    Tmp = textscan(DesignFid, '%f%f%f%f%f%f%s%s%d%s%s%s', ...
        'Delimiter', ',', 'Headerlines', 1);
    fclose(DesignFid);
    % more columns: ActualIsi, ContextOnset,FaceOnset,JitterOnset,FaceResponse,FaceRT
    Design = cell(numel(Tmp{1}), numel(Tmp) + 4);
    for i = 1:numel(Tmp)
        for k = 1:numel(Tmp{1})
            if iscell(Tmp{i})
                Design{k, i} = Tmp{i}{k};
            else
                Design{k, i} = Tmp{i}(k);
            end
        end
    end
    clear Tmp i k
    
    % assign constants
    RUN = 1;
    TRIAL = 2;
    CONDITION = 3;
    ONSET = 4;
    DURATION = 5;
    ISI = 6;
    CONTEXT = 7;
    EMOTION = 8;
    ORDER = 9;
    GENDER = 10;
    FACEFILE = 11;
    CONTEXTFILE = 12;
    ACTUALISI = 13;
    CONTEXTONSET = 14;
    FACEONSET = 15;
    JITTERONSET = 16;
    FACERESPONSE = 17;
    FACERT = 18;
    
    PsychDefaultSetup(2); 
    Screen('Preference', 'VisualDebugLevel', 3);
    Screens = Screen('Screens');
    ScreenNumber = max(Screens);
    
    % Define black and white
    White = [1 1 1];
    Black = [0 0 0];
    Grey = White * 0.5;
    
    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Black); 
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect); % get the center of the coordinate Window
    Refresh = Screen('GetFlipInterval', Window);
    ScanRect = [0 0 1024 768];
    [ScanCenter(1), ScanCenter(2)] = RectCenter(ScanRect);
    ScanCentered = CenterRectOnPoint(ScanRect, XCenter, YCenter);

    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % set up keyboard
    KbName('UnifyKeyNames');
    KbNames = KbName('KeyNames');
    KeyNamesOfInterest = {'1!', '2@', '3#', '4$', '5%', ...
        '6^', '7&', '8*', '9(', '0)', ...
        '1', '2', '3', '4', '5', ...
        '6', '7', '8', '9', '0'};
    KeysOfInterest = zeros(1, 256);
    for i = 1:numel(KeyNamesOfInterest)
        KeysOfInterest(KbName(KeyNamesOfInterest{i})) = 1;
    end
    clear i
    KbQueueCreate(DeviceIndex, KeysOfInterest);
    TriggerKey = KbName('=+');

    % calculate ISI duration in terms of flip interval
    for i = 1:size(Design, 1)
        Design{i, ACTUALISI} = round(Design{i, ISI}/Refresh) * Refresh;
    end
    
    % set default text type for window
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 50);
    Screen('TextColor', Window, White);

    % preload images and assign values for bar and text location
    fprintf(1, 'Preloading images. This will take some time.\n');
    for iOrder = 1:length(Runs)
        iRun = Runs(iOrder);

        OrderIdx = [Design{:, ORDER}]' == iOrder;
        RunIdx = OrderIdx & [Design{:, RUN}]' == iRun;

        RunParams = Design(RunIdx, :);
        for iTrial = 1:size(RunParams, 1)
            Context = fullfile(pwd, 'ScImages', RunParams{iTrial, CONTEXT}, ...
                RunParams{iTrial, CONTEXTFILE});
            Face = fullfile(pwd, 'ScImages', 'Faces', RunParams{iTrial, FACEFILE});

            TmpContext = imread(Context, 'jpg');
            TmpFace = imread(Face, 'png');

            TexContext{iOrder}{iTrial} = Screen('MakeTexture', Window, TmpContext);
            TexFace{iOrder}{iTrial} = Screen('MakeTexture', Window, TmpFace);
        end
    end
    clear iRun iTrial iOrder

    % load crosshair background
    FName = fullfile(pwd, 'ScImages', 'Backgrounds', 'JitterBackground.png');
    Im = imread(FName, 'png');
    JitterTexture = Screen('MakeTexture', Window, Im);

    % load rate background
    FName = fullfile(pwd, 'ScImages', 'Backgrounds', 'FaceBackground.png');
    Im = imread(FName, 'png');
    FaceBgTexture = Screen('MakeTexture', Window, Im);

    % calculate face center
    FaceCenter = [512 312];
    FaceCenter(1) = XCenter - (ScanCenter(1) - FaceCenter(1));
    FaceCenter(2) = YCenter - (ScanCenter(2) - FaceCenter(2));

    FlipSeconds = (round((1:10)/Refresh) - 0.1) * Refresh;
    % run the experiment
    for i = 1:size(Runs, 1)
        OrderIdx = [Design{:, ORDER}]' == Runs(i, 2);
        RunIdx = OrderIdx & [Design{:, RUN}]' == Runs(i, 1);
        RunParams = Design(RunIdx, :);

        % pre-populate RT and Response with NaN
        for k = 1:size(RunParams)
            RunParams{k, FACERESPONSE} = nan;
            RunParams{k, FACERT} = nan;
        end
        clear k;

        % handle file naming
        OutName = sprintf('%s_Order_%02d_Run_%02d_%s', Participant, ...
            Runs(i, 2), Runs(i, 1), datestr(now, 'yyyymmdd_HHMMSS'));
        OutCsv = fullfile(OutDir, [OutName '.csv']);
        OutMat = fullfile(OutDir, [OutName '.mat']);

        % show directions while waiting for trigger '^'
        DrawFormattedText(Window, ... 
            'These are the task directions.\n\n Waiting for ''='' to continue.', ...
            'center', 'center');
        Screen('Flip', Window);
        while 1
            [Pressed, Secs, KeyCode] = KbCheck;
            if Pressed && KeyCode(TriggerKey)
                break;
            end
        end

        % initial crosshair display
        Screen('DrawTexture', Window, JitterTexture);
        BeginTime = Screen('Flip', Window);
        Until = BeginTime + RunParams{1, ONSET}; 
        for k = 1:size(RunParams, 1)
            %%% CONTEXT %%%
            Screen('DrawTexture', Window, TexContext{i}{k});
            vbl = Screen('Flip', Window, Until);
            if k > 1
                % record responses
                KbQueueStop(DeviceIndex);
                [Pressed, FirstPress] = KbQueueCheck(DeviceIndex);
                if Pressed
                    FirstPress(FirstPress == 0) = nan;
                    [RT, Idx] = min(FirstPress);
                    RunParams{k - 1, FACERESPONSE} = KbNames{Idx};
                    RunParams{k - 1, FACERT} = RT - RunParams{k - 1, FACEONSET};
                end
                KbQueueFlush(DeviceIndex);

                fprintf(1, 'RESPONSE: FaceRT       %0.4f\n', RunParams{k - 1, FACERT});
                fprintf(1, 'RESPONSE: FaceResponse %s\n\n', RunParams{k - 1, FACERESPONSE});
            end
            RunParams{k, CONTEXTONSET} = vbl - BeginTime;

            %%% FACE %%%
            Screen('DrawTexture', Window, FaceBgTexture);
            FaceRect = Screen('Rect', TexFace{i}{k});
            if strcmp(RunParams{k, FACEFILE}, '27M_H.png')
                FaceRect = FaceRect / 2.2;
            end
            FaceRect = CenterRectOnPoint(FaceRect, FaceCenter(1), FaceCenter(2));
            Screen('DrawTexture', Window, TexFace{i}{k}, [], FaceRect);
            vbl = Screen('Flip', Window, vbl + FlipSeconds(3));
            KbQueueStart(DeviceIndex);
            RunParams{k, FACEONSET} = vbl - BeginTime;

            %%% JITTER %%%
            Screen('DrawTexture', Window, JitterTexture);
            vbl = Screen('Flip', Window, vbl + FlipSeconds(2));
            RunParams{k, JITTERONSET} = vbl - BeginTime;
            Until = vbl + RunParams{k, ACTUALISI} - 0.1 * Refresh;
        end

        % record last response after last jitter
        WaitSecs('UntilTime', Until);
        KbQueueStop(DeviceIndex);
        [Pressed, FirstPress] = KbQueueCheck(DeviceIndex);
        if Pressed
            FirstPress(FirstPress == 0) = nan;
            [RT, Idx] = min(FirstPress);
            RunParams{k, FACERESPONSE} = KbNames{Idx};
            RunParams{k, FACERT} = RT - RunParams{k, FACEONSET};
        end
        KbQueueFlush(DeviceIndex);
        fprintf(1, 'RESPONSE: FaceRT       %0.4f\n', RunParams{k, FACERT});
        fprintf(1, 'RESPONSE: FaceResponse %s\n\n', RunParams{k, FACERESPONSE});
    
        % now write out run design
        save(OutMat, 'RunParams');
        OutFid = fopen(OutCsv, 'w');
        fprintf(OutFid, ...
            ['Participant,', ...
            'Order,', ...
            'Run,', ...
            'Trial,', ...
            'Condition,', ...
            'Onset,', ...
            'Duration,', ...
            'ISI,', ...
            'Context,', ...
            'Emotion,', ...
            'Gender,', ...
            'FaceFile,', ...
            'ContextFile,', ...
            'ActualIsi,', ...
            'ContextOnset,', ...
            'FaceOnset,', ...
            'JitterOnset,', ...
            'FaceResponse,', ...
            'FaceRt\n']);
        for DesignIdx = 1:size(RunParams, 1)
            fprintf(OutFid, '%s,', Participant);
            fprintf(OutFid, '%d,', Runs(i, 2));
            fprintf(OutFid, '%d,', Runs(i, 1));
            fprintf(OutFid, '%d,', RunParams{DesignIdx, TRIAL});
            fprintf(OutFid, '%d,', RunParams{DesignIdx, CONDITION});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, ONSET});
            fprintf(OutFid, '%d,', RunParams{DesignIdx, DURATION});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, ISI});
            fprintf(OutFid, '%s,', RunParams{DesignIdx, CONTEXT});
            fprintf(OutFid, '%s,', RunParams{DesignIdx, EMOTION});
            fprintf(OutFid, '%s,', RunParams{DesignIdx, GENDER});
            fprintf(OutFid, '%s,', RunParams{DesignIdx, FACEFILE});
            fprintf(OutFid, '%s,', RunParams{DesignIdx, CONTEXTFILE});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, ACTUALISI});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, CONTEXTONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, FACEONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, JITTERONSET});
    
            % handle resposne now
            Response = RunParams{DesignIdx, FACERESPONSE};
            if ischar(Response)
                if any(strcmp(KeyNamesOfInterest(1:10), Response))
                    Response = find(strcmp(KeyNamesOfInterest(1:10), Response));
                elseif any(strcmp(KeyNamesOfInterest(11:end), Response, Response))
                    Response = find(strcmp(KeyNamesOfInterest(11:end), Response));
                else
                    Response = nan;
                end
    
                if Response == 10
                    Response = 0;
                end
            end
            fprintf(OutFid, '%d,', Response);
    
            fprintf(OutFid, '%0.4f\n', RunParams{DesignIdx, FACERT});
        end
        fclose(OutFid);
    
        fprintf(1, '\n');
    end

    %%% GODYBE %%%
    DrawFormattedText(Window, 'Goodbye!', 'center', 'center');
    Screen('Flip', Window);
    WaitSecs(1.25);
    
    % close everything
    KbQueueRelease();
    sca;
    ListenChar(0);
    ShowCursor;
    Priority(0);
    diary off
    close all
    clear all
catch err
    % close everything
    KbQueueRelease();
    sca;
    ListenChar(0);
    ShowCursor;
    Priority(0);
    fclose('all');
    close all
    fprintf(1, '%s\n', err.message);
    diary off
    rethrow(err);
end
end

