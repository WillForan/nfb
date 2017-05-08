function ScTask(varargin)
% function SogcialCognitionTask([Scan], [Participant], [Run1], [Order1], [Run2],
%   [Order2], [Testing])

try
    sca;
    DeviceIndex = [];

    Screens = Screen('Screens'); 
    if isempty(varargin)
        Responses = inputdlg({'Scan (1:Yes, 0:No):', ...
            'Participant ID:', ...
            'Run1: 1 - 5:', ...
            'Run1 Order: 1 - 2:', ...
            'Run2: 1 - 5:', ...
            'Run2 Order: 1 - 2:', ...
            'Testing: (1:Yes, 0:No)', ...
            'Screen:'}, ...
            'OPTIONS', 1, ...
            {'1', '', '', '1', '', '2', '0', sprintf('%d', max(Screens))});
        InScan = str2double(Responses{1});
        Participant = Responses{2};
        if isempty(Responses{5})
            Runs = [str2double(Responses{3}) str2double(Responses{4})];
        else
            Runs = [str2double(Responses{3}) str2double(Responses{4});
                    str2double(Responses{5}) str2double(Responses{6})];
        end
        Testing = str2double(Responses{7});
        ScreenNumber = str2double(Responses{8});
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
        ScreenNumber = str2double(Responses{8});
    else
        error('Invalid number of arguments.');
    end

    % list expected onsets
    ExpectedOnsets = [579.5167 586.7333 581.5 585.1833 581.6833];

    if InScan == 0
        PsychDebugWindowConfiguration
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
        sprintf('OPTIONS: InScan       %d\n', InScan) ...
        sprintf('OPTIONS: Participant  %s\n', Participant) ...
        sprintf('OPTIONS: Run1         %d\n', Runs(1, 1)) ...
        sprintf('OPTIONS: Run1 Order   %d\n', Runs(1, 2))];

    if size(Runs, 1) == 2
        OptionText = [OptionText ...
            sprintf('OPTIONS: Run2         %d\n', Runs(2, 1)) ...
            sprintf('OPTIONS: Run2 Order   %d\n', Runs(2, 2))];
    else
        OptionText = [OptionText ...
            sprintf('OPTIONS: Run2         NA') ...
            sprintf('OPTIONS: Run2 Order   NA')];
    end

    OptionText = [OptionText ...
        sprintf('OPTIONS: Testing      %d\n', Testing) ...
        sprintf('OPTIONS: Screen       %d\n', ScreenNumber) ...
        sprintf('*** OPTIONS ***\n\n')];
    fprintf(1, '\n%s', OptionText);
    
    % read in design
    if Testing
        DesignFile = fullfile(pwd, 'ScDebug', 'Development', 'ScTestOrder.csv');
    else
        DesignFile = fullfile(pwd, 'ScDebug', 'Development', 'ScDesign.csv');
    end
    DesignFid = fopen(DesignFile, 'r');
    Tmp = textscan(DesignFid, '%f%f%f%f%f%f%s%s%d%s%s%d%s', ...
        'Delimiter', ',', 'Headerlines', 1);
    fclose(DesignFid);
    % more columns: ActualIsi, ContextOnset, FaceOnset, JitterOnset, 
    %               FaceResponse, FaceResponseText, FaceRT 
    Design = cell(numel(Tmp{1}), numel(Tmp) + 7);
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
    CONTEXTFILE = 10;
    FACEFILE = 11;
    FACENUM = 12;
    GENDER = 13;
    ACTUALISI = 14;
    CONTEXTONSET = 15;
    FACEONSET = 16;
    JITTERONSET = 17;
    FACERESPONSE = 18;
    FACERESPONSETEXT = 19;
    FACERT = 20;
    
    KbName('UnifyKeyNames');
    if ~IsLinux()
        Screen('Preference', 'SkipSyncTests', 2);
    end
    Screen('Preference', 'VisualDebugLevel', 3);
    Screens = Screen('Screens');
    Offset = 0.5;
    
    % Define black and white
    White = [1 1 1];
    Black = [0 0 0];
    Grey = White * 0.5;
    
    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = Screen('OpenWindow', ScreenNumber, Black); 
    Screen('ColorRange', Window, 1, [], 1);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect); % get the center of the coordinate Window
    Refresh = Screen('GetFlipInterval', Window);
    ScanRect = [0 0 1024 768];
    [ScanCenter(1), ScanCenter(2)] = RectCenter(ScanRect);
    ScanCentered = CenterRectOnPoint(ScanRect, XCenter, YCenter);
    if InScan == 1
        HideCursor(ScreenNumber);
    end

    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % set up keyboard
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
    ConfirmKeyNames = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', ...
        'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', ...
        'y', 'z'};
    RightResponses = {'1!', '2@', '3#', '4$', '5%', '1', '2', '3', '4', '5'};
    LeftResponses = {'6^', '7&', '8*', '9(', '0)', '6', '7', '8', '9', '0'};

    % calculate ISI duration in terms of flip interval
    for i = 1:size(Design, 1)
        Design{i, ACTUALISI} = round(Design{i, ISI}/Refresh) * Refresh;
    end
    
    % set default text type for window
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 35);
    Screen('TextColor', Window, White);

    % preload images and assign values for bar and text location
    fprintf(1, 'NOTIFICATION: Preloading images. This will take some time.\n');
    for k = 1:size(Runs, 1)
        iOrder = Runs(k, 2);
        iRun = Runs(k, 1);

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

    % load rate backgrounds
    FName = fullfile(pwd, 'ScImages', 'Backgrounds', 'YesNoFaceBackground.png');
    Im = imread(FName, 'png');
    FaceBgTexture(1) = Screen('MakeTexture', Window, Im);

    FName = fullfile(pwd, 'ScImages', 'Backgrounds', 'NoYesFaceBackground.png');
    Im = imread(FName, 'png');
    FaceBgTexture(2) = Screen('MakeTexture', Window, Im);

    % calculate face center
    FaceCenter = [512 312];
    FaceCenter(1) = XCenter - (ScanCenter(1) - FaceCenter(1));
    FaceCenter(2) = YCenter - (ScanCenter(2) - FaceCenter(2));

    FlipSeconds = (round((1:10)/Refresh) - Offset) * Refresh;
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

        % show directions while waiting for trigger '='
        DrawFormattedText(Window, ... 
            ['Proceeding with the next set of pictures.\n', ...
            'Waiting for scanner signal ''='' to continue.'], ...
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
                    RunParams{k - 1, FACERT} = RT - FaceVbl;
                end
                KbQueueFlush(DeviceIndex);

                fprintf(1, 'RESPONSE: FaceRT       %0.4f\n', ...
                    RunParams{k - 1, FACERT});
                fprintf(1, 'RESPONSE: FaceResponse %s\n\n', ...
                    RunParams{k - 1, FACERESPONSE});
            end
            RunParams{k, CONTEXTONSET} = vbl - BeginTime;

            %%% FACE %%%
            if mod(Runs(i, 2), 2)
                Screen('DrawTexture', Window, FaceBgTexture(1));
            else
                Screen('DrawTexture', Window, FaceBgTexture(2));
            end
            FaceRect = Screen('Rect', TexFace{i}{k});
            if strcmp(RunParams{k, FACEFILE}, '27M_H.png')
                FaceRect = FaceRect / 2.2;
            end
            FaceRect = CenterRectOnPoint(FaceRect, FaceCenter(1), FaceCenter(2));
            Screen('DrawTexture', Window, TexFace{i}{k}, [], FaceRect);
            FaceVbl = Screen('Flip', Window, vbl + FlipSeconds(3));
            KbQueueStart(DeviceIndex);
            RunParams{k, FACEONSET} = vbl - BeginTime;

            %%% JITTER %%%
            Screen('DrawTexture', Window, JitterTexture);
            vbl = Screen('Flip', Window, FaceVbl + FlipSeconds(2));
            RunParams{k, JITTERONSET} = vbl - BeginTime;
            Until = vbl + RunParams{k, ACTUALISI} - Offset * Refresh;
        end

        % record last response after last jitter
        KbQueueStop(DeviceIndex);
        [Pressed, FirstPress] = KbQueueCheck(DeviceIndex);
        if Pressed
            FirstPress(FirstPress == 0) = nan;
            [RT, Idx] = min(FirstPress);
            RunParams{k, FACERESPONSE} = KbNames{Idx};
            RunParams{k, FACERT} = RT - FaceVbl;
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
            'ContextFile,', ...
            'FaceFile,', ...
            'FaceNum,', ...
            'Gender,', ...
            'ActualIsi,', ...
            'ContextOnset,', ...
            'FaceOnset,', ...
            'JitterOnset,', ...
            'FaceResponseNum,', ...
            'FaceResponseText,', ...
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
            fprintf(OutFid, '%s,', RunParams{DesignIdx, CONTEXTFILE});
            fprintf(OutFid, '%s,', RunParams{DesignIdx, FACEFILE});
            fprintf(OutFid, '%d,', RunParams{DesignIdx, FACENUM});
            fprintf(OutFid, '%s,', RunParams{DesignIdx, GENDER});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, ACTUALISI});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, CONTEXTONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, FACEONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, JITTERONSET});
    
            % handle response now
            Response = RunParams{DesignIdx, FACERESPONSE};
            if ischar(Response)
                Response = find(strcmp(KeyNamesOfInterest, Response));
                if ~isempty(Response)
                    Response = mod(Response, 10);
                else
                    Response = nan;
                end
            end
            fprintf(OutFid, '%d,', Response);

            if mod(Runs(i, 2), 2)
                if any(strcmp(LeftResponses, RunParams{DesignIdx, FACERESPONSE}))
                    RunParams{DesignIdx, FACERESPONSETEXT} = 'Positive';
                elseif any(strcmp(RightResponses, RunParams{DesignIdx, FACERESPONSE}))
                    RunParams{DesignIdx, FACERESPONSETEXT} = 'Negative';
                else
                    RunParams{DesignIdx, FACERESPONSETEXT} = 'NaN';
                end
            else
                if any(strcmp(LeftResponses, RunParams{DesignIdx, FACERESPONSE}))
                    RunParams{DesignIdx, FACERESPONSETEXT} = 'Negative';
                elseif any(strcmp(RightResponses, RunParams{DesignIdx, FACERESPONSE}))
                    RunParams{DesignIdx, FACERESPONSETEXT} = 'Positive';
                else
                    RunParams{DesignIdx, FACERESPONSETEXT} = 'NaN';
                end
            end
            fprintf(OutFid, '%s,', RunParams{DesignIdx, FACERESPONSETEXT});
    
            fprintf(OutFid, '%0.4f\n', RunParams{DesignIdx, FACERT});
        end
        fclose(OutFid);
        fprintf(1, '\n');

        % print out previous run information
        fprintf(1, 'NOTIFICATION: Completed SC run %d.\n', i);
        fprintf(1, 'NOTIFICATION: Used paradigm %d.\n', Runs(i, 1));
        fprintf(1, 'NOTIFICATION: Used run order %d.\n', Runs(i, 2));
        fprintf(1, 'NOTIFICATION: Using offset %0.2f.\n', Offset);
        fprintf(1, 'NOTIFICATION: Participant number %s.\n', Participant);
        if Testing == 0 
            fprintf(1, 'NOTIFICATION: Last trial onset %0.4f.\n', ...
                RunParams{end, JITTERONSET});
            fprintf(1, 'NOTIFICATION: Expected last trial onset %0.4f.\n', ...
                ExpectedOnsets(Runs(i, 1)));
        end

        % confirmation screen
        if i ~= size(Runs, 1)
            Screen('FillRect', Window, Black);
            Screen('TextSize', Window, 50);
            Screen('TextFont', Window, 'Arial');
            Screen('TextStyle', Window, 0);
            DrawFormattedText(Window, ...
                [sprintf('End image set %d.\n', i) ...
                'Waiting for confirmation.'], ...
                'center', 'center', White);
            vbl = Screen('Flip', Window, Until);
            fprintf(1, ['NOTIFICATION: End run %d. ' ...
                'Press any button (a-z) to move to signal waiting screen.\n'], i);

            KbEventFlush;
            InLoop = 1;
            while InLoop
                [Pressed, Secs, KeyCode] = KbCheck;
                if Pressed
                    BitPressed = find(KeyCode);
                    for iBit = BitPressed
                        if any(strcmp(KbNames{iBit}, ConfirmKeyNames))
                            InLoop = 0;
                        end
                    end
                end
            end
        end
    end

    %%% GODYBE %%%
    Screen('TextSize', Window, 50);
    Screen('TextFont', Window, 'Arial');
    Screen('TextStyle', Window, 0);
    DrawFormattedText(Window, ...
        sprintf('End image set %d.', i), ...
        'center', 'center', White);
    Screen('Flip', Window, Until);
    WaitSecs(1.25);
    
    % close everything
    KbQueueRelease();
    sca;
    ShowCursor;
    Priority(0);
    diary off
    close all
    clear all
catch err
    % close everything
    KbQueueRelease();
    sca;
    ShowCursor;
    Priority(0);
    fclose('all');
    close all
    fprintf(1, '%s\n', err.message);
    diary off
    rethrow(err);
end
end

