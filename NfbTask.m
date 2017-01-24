function NfbTask(varargin)
% function NfbTask([Scan], [Participant], [StartRun], [EndRun],
%   [Testing], [Version])

try
    sca;
    DeviceIndex = [];

    if isempty(varargin)
        Responses = inputdlg({'Scan (1:Yes, 0:No):', ...
            'Participant ID:', ...
            'Start run: 1 - 4:', ...
            'End run: 1 - 4:', ...
            'Testing: (1:Yes, 0:No)', ...
            'Version: (1, 2, 3, 4)'});
        InScan = str2double(Responses{1});
        Participant = Responses{2};
        StartRun = str2double(Responses{3});
        EndRun = str2double(Responses{4});
        Testing = str2double(Responses{5});
        Version = str2double(Responses{6});
    elseif numel(varargin) == 6
        InScan = varargin{1};
        Participant = varargin{2};
        StartRun = varargin{3};
        EndRun = varargin{4};
        Testing = varargin{5};
        Version = varargin{6};
    else
        error('Invalid number of arguments.');
    end

    % make participant out directory
    OutDir = fullfile(pwd, 'NfbResponses', Participant);
    mkdir(OutDir);
    
    % start diary to log strange PTB behaviors
    OutName = sprintf('%s_Nfb_Diary_%s', Participant, ...
        datestr(now, 'yyyymmdd_HHMMSS'));
    DiaryFile = fullfile(OutDir, [OutName '.txt']);
    diary(DiaryFile);
    
    OptionText = [sprintf('*** OPTIONS ***\n') ...
        sprintf('OPTIONS: InScan      %d\n', InScan) ...
        sprintf('OPTIONS: Participant %s\n', Participant) ...
        sprintf('OPTIONS: StartRun    %d\n', StartRun) ...
        sprintf('OPTIONS: EndRun      %d\n', EndRun) ...
        sprintf('OPTIONS: Testing     %d\n', Testing) ...
        sprintf('OPTIONS: Version     %d\n', Version) ...
        sprintf('*** OPTIONS ***\n\n')];
    fprintf(1, '\n%s', OptionText);
    
    if InScan == 0
        PsychDebugWindowConfiguration
    end
    
    % print out options to text file
    OutName = sprintf('%s_Nfb_Options_%s', Participant, ...
        datestr(now, 'yyyymmdd_HHMMSS'));
    OptionFile = fullfile(OutDir, [OutName '.txt']);
    OptionFid = fopen(OptionFile, 'w');
    fprintf(OptionFid, OptionText);
    fclose(OptionFid);
    
    % read in design
    if Testing
        DesignFile = fullfile(pwd, 'NfbDebug', 'Development', 'NfbTesting.csv');
    else
        DesignFile = fullfile(pwd, 'NfbDebug', 'Development', 'NfbDesign.csv');
    end
    DesignFid = fopen(DesignFile, 'r');
    Tmp = textscan(DesignFid, '%f%f%s%s%f%f%f%f%f', ...
        'Delimiter', ',', 'Headerlines', 1);
    fclose(DesignFid);
    % more columns: InfuisonNum, InfOnset, J1Onset, WillImpOnset, J2Onset, Feed1Onset, 
    %               Feed2Onset, Feed3Onset, J3Onset, ImprovedOnset, J4Onset, WillImpResp, 
    %               WillImpRt, ImproveResp, ImprovedRt
    % split feedback into baseline and feedback later
    Design = cell(numel(Tmp{1}), numel(Tmp) + 15);
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
    TRIALNUM = 2;
    INFUSION = 3;
    FEEDBACK = 4;
    WAVEFORM = 5;
    JITTER1DUR = 6;
    JITTER2DUR = 7;
    JITTER3DUR = 8;
    JITTER4DUR = 9;
    INFUSIONNUM = 10;
    INFONSET = 11;
    J1ONSET = 12;
    WILLIMPROVEONSET = 13;
    J2ONSET = 14;
    FEED1ONSET = 15;
    FEED2ONSET = 16;
    FEED3ONSET = 17;
    J3ONSET = 18;
    IMPROVEDONSET = 19;
    J4ONSET = 20;
    WILLIMPROVERESP = 21;
    WILLIMPROVERT = 22;
    IMPROVEDRESP = 23;
    IMPROVEDRT = 24;

    % assign INFUSIONNUM
    for i = 1:size(Design, 1)
        if Design{i, INFUSION} == 'A'
            Design{i, INFUSIONNUM} = 1;
        elseif Design{i, INFUSION} == 'B'
            Design{i, INFUSIONNUM} = 2;
        elseif Design{i, INFUSION} == 'C'
            Design{i, INFUSIONNUM} = 3;
        elseif Design{i, INFUSION} == 'D'
            Design{i, INFUSIONNUM} = 4;
        else
            error('Unknown infusion: %s, row: %d', Design{i, INFUSION}, i);
        end
    end
    clear i

    % default color scheme (used in infusion and feedback)
    Colors = {
        [1 0 0];
        [7/255 255 255];
        [0 1 0];
        [1 1 0];
    };
   
    % set Colors color order based on Version 
    if Version == 1
        ColorOrder = [1 2 3 4];
    elseif Version == 2
        ColorOrder = [2 1 4 3];
    elseif Version == 3
        ColorOrder = [3 4 1 2];
    elseif Version == 4
        ColorOrder = [4 3 2 1];
    else
        sca;
        error('Unknown error version: %d\n', Version);
    end
    
    KbName('UnifyKeyNames');
    % Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'VisualDebugLevel', 3); % skip introduction Screen
    Screen('Preference', 'DefaultFontSize', 35);
    Screen('Preference', 'DefaultFontName', 'Arial');
    Screens = Screen('Screens'); % get screen number
    ScreenNumber = max(Screens);
    
    % Define commonly used colors
    White = WhiteIndex(ScreenNumber);
    Black = BlackIndex(ScreenNumber);
    Grey = White * 0.5;
    BgColor = [45 59 55] * 1/255;
    UnfilledColor = [38 41 26] * 1/255;
    BoxColor = [21 32 17] * 1/255;
    FilledColor = [41 249 64] * 1/255;
    
    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = Screen('OpenWindow', ScreenNumber, BgColor);
    Screen('ColorRange', Window, 1, [], 1);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    Refresh = Screen('GetFlipInterval', Window);
    ScanRect = [0 0 1024 768];
    [ScanCenter(1), ScanCenter(2)] = RectCenter(ScanRect);
    
    % blend
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % set up keyboard response
    KbNames = KbName('KeyNames');
    KeyNamesOfInterest = {'1!', '2@', '3#', '4$', '5%', '6^', '7&', '8*', ...
        '9(', '0)', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
    KeysOfInterest = zeros(1, 256);
    for i = 1:numel(KeyNamesOfInterest)
        KeysOfInterest(KbName(KeyNamesOfInterest{i})) = 1;
    end
    clear i
    KbQueueCreate(DeviceIndex, KeysOfInterest);
    TriggerKey = KbName('=+');

    %%% INFUSION SETUP %%%
    InfBgPng = {'InfBgA.png', 'InfBgB.png', 'InfBgC.png', 'InfBgD.png'};
    InfBgTextures = zeros(numel(InfBgPng), 1);
    for i = 1:numel(InfBgPng)
        FileName = fullfile(pwd, 'Images', 'Infusion', InfBgPng{i});
        Im = imread(FileName, 'png');
        InfBgTextures(i) = Screen('MakeTexture', Window, Im);
    end

    % get oval positions when filling for infusion
    Ovals = {
        [571.09 67] % PROTOCOL 196KJ ellipse center
        [571.09 180] % PROTOCOL 564D ellipse center
        [571.09 293] % CALIBRATION C ellipse center
        [571.09 406] % CALIBRATION D ellipse center
    };
    Ovals = ConvertCoordinates(ScanCenter, [XCenter YCenter], Ovals);
    for i = 1:size(Ovals, 1)
        FilledOvalRect{i, 1} = CenterRectOnPointd([0 0 68 68], Ovals{i}(1), Ovals{i}(2));
    end
   
    % get number box center
    InterfaceLoc = {
        [289.5 629] % number rectangle center [83 522 413 214]
    };
    InterfaceLoc = ConvertCoordinates(ScanCenter, [XCenter YCenter], ...
        InterfaceLoc);
    NumberRect = CenterRectOnPointd([83 522 83+413 522+214], InterfaceLoc{1}(1), ...
        InterfaceLoc{1}(2));

    % create Infusion number textures
    InfColors = {'Red', 'Blue', 'Green', 'Yellow'};
    InfNumbers = {'000', '033', '067', '100'};
    InfNumTextures = zeros(numel(InfColors), numel(InfNumbers));
    for i = 1:numel(InfColors)
        for k = 1:numel(InfNumbers)
            FName = fullfile(pwd, 'Images', 'Infusion', ...
                sprintf('%s_%s.png', InfColors{i}, InfNumbers{k}));
            Im = imread(FName, 'png');
            InfNumTextures(i, k) = Screen('MakeTexture', Window, Im);
        end
    end
    clear i k

    % get progression bar centers
    ProgressLoc = {
        [823 616.5] % box1 [763.99 386 224 170]
        [823 383.5] % box2 [763.99 561 224 170] 
        [823 150.5] % box3 [763.99 211 224 170]
    };
    ProgressLoc = ConvertCoordinates(ScanCenter, [XCenter YCenter], ...
        ProgressLoc);
    ProgressBox = [0 0 224 227];
    for i = 1:size(ProgressLoc, 1)
        ProgressRect{i, 1} = CenterRectOnPointd(ProgressBox, ProgressLoc{i}(1), ...
            ProgressLoc{i}(2));
    end
    
    %%% WILLIMPROVE SETUP %%%
    FileName = fullfile(pwd, 'Images', 'Questions', 'WillImprove.png');
    Im = imread(FileName, 'png');
    WillImproveTexture = Screen('MakeTexture', Window, Im);
    
    %%% FEEDBACK SETUP %%%
    % Feedback rect location; this is used as position reference for most
    % other drawn objects
    FName = fullfile(pwd, 'Images', 'FeedNumImages', 'Feedback.png');
    Im = imread(FName, 'png');
    FeedbackTexture = Screen('MakeTexture', Window, Im);

    % create feedback rect for signal drawing
    FeedbackRect = [0 0 923 750];
    OrigFeedbackRect = [0 0 920 750];
    FeedbackXCenter = 50.5 + XCenter;
    OrigFeedXCenter = 52 + XCenter;
    CenteredFeedback = CenterRectOnPointd(FeedbackRect, FeedbackXCenter, YCenter);
    CenteredOrigFeed = CenterRectOnPointd(OrigFeedbackRect, OrigFeedXCenter, YCenter);

    %%% IMPROVED SETUP %%%
    FileName = fullfile(pwd, 'Images', 'Questions',  'Improved.png');
    Im = imread(FileName, 'png');
    ImprovedTexture = Screen('MakeTexture', Window, Im);    
    
    %%% SIGNAL SETUP %%%
    Scale = 2; % move by this many points across signals
    FlipSecs = 2/60; % time to display signal
    WaitFrames = round(FlipSecs / Refresh); % display signal every this frame
    % set MaxX, this value determines the number of seconds to move from one
    % end of the screen to the other; FlipSecs and MaxX depend on each other
    MaxX = Scale*120;
    
    % create original and plotted ranges
    XRange = [0 (MaxX-1)];
    YRange = [-100 100];
    NewXRange = [CenteredOrigFeed(1) CenteredOrigFeed(3)];
    NewYRange = [CenteredFeedback(2) CenteredFeedback(4)];
    
    % dummy signals
    X = 0:(MaxX-1);
    % load Signal and Baselines
    FileName = fullfile(pwd, 'DebugScripts', 'Development', 'Waveforms.mat');
    load(FileName);

    % convert from old range values to new range values
    NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);

    % create values that appear as continuous lines when plotted
    NewX_Line = zeros(1, 2*(length(NewX)-1));
    NewX_Line(1:2:end) = NewX(1:end-1);
    NewX_Line(2:2:end) = NewX(2:end);
    
    % modify signals to allow continuous plotting between them
    for iRun = 1:numel(Signals)
        ModSignals{iRun} = cell(size(Signals{iRun}));
        ModBaselines{iRun} = cell(size(Baselines{iRun}));
        
        % add end of previous signal to next for continuous plotting between sections
        for i = 1:size(ModSignals{iRun}, 1)
            ModSignals{iRun}{i, 1} = Signals{iRun}{i, 1};
        
            for k = 2:size(ModSignals{iRun}, 2)
                BeginSig1 = length(ModSignals{iRun}{i, k - 1}) - MaxX + 1 + Scale;
                ModSignals{iRun}{i, k} = [ModSignals{iRun}{i, k - 1}(BeginSig1:end) ...
                    Signals{iRun}{i, k}];
            end
        end 
        clear i k
        
        for i = 1:size(ModBaselines{iRun}, 1)
            ModBaselines{iRun}{i, 1} = Baselines{iRun}{i, 1};
        
            for k = 2:size(ModBaselines{iRun}, 2)
                BeginSig1 = length(ModBaselines{iRun}{i, k - 1}) - MaxX + 1 + Scale;
                ModBaselines{iRun}{i, k} = [ModBaselines{iRun}{i, k - 1}(BeginSig1:end) ...
                    Baselines{iRun}{i, k}];
            end
        end
        clear i k
        
        % convert to new range  
        for i = 1:size(ModSignals{iRun}, 1)
            for k = 1:size(ModSignals{iRun}, 2)
                ModSignals{iRun}{i, k} = (ModSignals{iRun}{i, k} - YRange(1)) / ...
                    diff(YRange)*diff(NewYRange)+NewYRange(1);
                ModSignals{iRun}{i, k} = NewYRange(2) - ...
                    ModSignals{iRun}{i, k} + NewYRange(1);
            end
        end
        clear i k
        
        for i = 1:size(ModBaselines{iRun}, 1)
            for k = 1:size(ModBaselines{iRun}, 2)
                ModBaselines{iRun}{i, k} = (ModBaselines{iRun}{i, k} - YRange(1)) / ...
                    diff(YRange)*diff(NewYRange)+NewYRange(1);
                ModBaselines{iRun}{i, k} = NewYRange(2) - ...
                    ModBaselines{iRun}{i, k} + NewYRange(1);
            end
        end
        clear i k
        
        % convert to 'DrawLines' compatible  
        LineSignals{iRun} = cell(size(ModSignals{iRun}));
        for i = 1:size(LineSignals{iRun}, 1)
            for k = 1:size(LineSignals{iRun}, 2)
                LineSignals{iRun}{i, k} = zeros(1, 2*(length(ModSignals{iRun}{i, k})-1));
                LineSignals{iRun}{i, k}(1:2:end) = ModSignals{iRun}{i, k}(1:end-1);
                LineSignals{iRun}{i, k}(2:2:end) = ModSignals{iRun}{i, k}(2:end);
            end
        end
        clear i k
        
        LineBaselines{iRun} = cell(size(ModBaselines{iRun}));
        for i = 1:size(LineBaselines{iRun}, 1)
            for k = 1:size(LineBaselines{iRun}, 2)
                LineBaselines{iRun}{i, k} = zeros(1, 2*(length(ModBaselines{iRun}{i, k})-1));
                LineBaselines{iRun}{i, k}(1:2:end) = ModBaselines{iRun}{i, k}(1:end-1);
                LineBaselines{iRun}{i, k}(2:2:end) = ModBaselines{iRun}{i, k}(2:end);
            end
        end
        clear i k
    end
   
    HideCursor;
    ListenChar(-1);
    % define common times and number of frames
    FlipSeconds = (round((1:10)/Refresh) - 0.1) * Refresh;
    for i = StartRun:EndRun
        RunIdx = [Design{:, RUN}]' == i;
        RunParams = Design(RunIdx, :);
    
        % pre-populate RT and Response with NaN
        for k = 1:size(RunParams)
            RunParams{k, WILLIMPROVERESP} = nan;
            RunParams{k, WILLIMPROVERT} = nan;
            RunParams{k, IMPROVEDRESP} = nan;
            RunParams{k, IMPROVEDRT} = nan;
        end
        clear k;
        
        % handle file naming
        OutName = sprintf('%s_Nfb_V%d_Run_%02d_%s', Participant, Version, i, ...
            datestr(now, 'yyyymmdd_HHMMSS'));
        OutCsv = fullfile(OutDir, [OutName '.csv']);
        OutMat = fullfile(OutDir, [OutName '.mat']);
    
        % show directions while waiting for trigger '='
        Screen('TextFont', Window, 'Arial');
        Screen('TextSize', Window, 35);
        Screen('TextStyle', Window, 0);
        Screen('FillRect', Window, Black);
        DrawFormattedText(Window, ... 
            'These are the task directions.\n\n Waiting for ''='' to continue.', ...
            'center', 'center', White);
        Screen('Flip', Window);
        while 1
            [Pressed, Secs, KeyCode] = KbCheck;
            if Pressed && KeyCode(TriggerKey)
                break;
            end
        end
    
        Until = 0;
        Screen('FillRect', Window, BgColor);
        for k = 1:size(RunParams, 1)
            InfusionNum = RunParams{k, INFUSIONNUM};
            ColorIdx = ColorOrder(InfusionNum);
            TrialColor = Colors{ColorIdx};
        
            %%% INFUSION RUNNING CODE %%%
            Screen('DrawTexture', Window, InfBgTextures(InfusionNum));
            
            % draw numbers
            Screen('DrawTexture', Window, InfNumTextures(ColorIdx, 1), ...
                [], NumberRect);
           
            % fill condition 
            Screen('FillOval', Window, TrialColor, ...
                FilledOvalRect{InfusionNum}); 

            vbl = Screen('Flip', Window, Until, 1);
            if k == 1
                BeginTime = vbl;
            end
            RunParams{k, INFONSET} = vbl - BeginTime;

            if any(strcmp(RunParams{k, INFUSION}, {'A', 'B'}))
                for iInc = 2:size(InfNumTextures, 2)
                    %%% INFUSION RUNNING CODE %%%
                    
                    % draw numbers 
                    Screen('DrawTexture', Window, ...
                        InfNumTextures(ColorIdx, iInc), [], NumberRect);
                   
                    % fill rectangle
                    Screen('FillRect', Window, TrialColor, ...
                        ProgressRect{iInc - 1, 1});

                    vbl = Screen('Flip', Window, vbl + FlipSeconds(1), 1);
                end
            end
            
            %%% JITTER1 %%%
            Screen('FillRect', Window, BgColor);
            if any(strcmp(RunParams{k, INFUSION}, {'A', 'B'}))
                vbl = Screen('Flip', Window, vbl + FlipSeconds(1));
            else
                vbl = Screen('Flip', Window, vbl + FlipSeconds(4));
            end
            RunParams{k, J1ONSET} = vbl - BeginTime;
    
            %%% WILLIMPROVE RUNNING CODE %%%
            Screen('DrawTexture', Window, WillImproveTexture);
            ContVbl = Screen('Flip', Window, vbl + (RunParams{k, JITTER1DUR} - 0.1) * Refresh);
            KbQueueStart(DeviceIndex);
            RunParams{k, WILLIMPROVEONSET} = ContVbl - BeginTime;
        
            %%% JITTER2 %%%
            Screen('FillRect', Window, BgColor);
            vbl = Screen('Flip', Window, ContVbl + FlipSeconds(2));
            RunParams{k, J2ONSET} = vbl - BeginTime;
    
            KbQueueStop(DeviceIndex);
            [DidRespond, TimeKeysPressed] = KbQueueCheck(DeviceIndex);
            if DidRespond
                TimeKeysPressed(TimeKeysPressed == 0) = nan;
                [RT, Idx] = min(TimeKeysPressed);
                RunParams{k, WILLIMPROVERESP} = KbNames{Idx};
                RunParams{k, WILLIMPROVERT} = RT - ContVbl;
            end
            KbQueueFlush(DeviceIndex);
    
            fprintf(1, 'RESPONSE: Run              %d\n', i);
            fprintf(1, 'RESPONSE: Trial            %d\n', k);
            fprintf(1, 'RESPONSE: Infusion         %s\n', RunParams{k, INFUSION});
            fprintf(1, 'RESPONSE: InfRT            %0.4f\n', RunParams{k, WILLIMPROVERT});
            fprintf(1, 'RESPONSE: InfResponse      %s\n', RunParams{k, WILLIMPROVERESP});
            
            %%% FEEDBACK RUNNING CODE %%%
            if strcmp(RunParams{k, FEEDBACK}, 'Signal')
                Waveforms = LineSignals{i}(RunParams{k, WAVEFORM}, :);
            else
                Waveforms = LineBaselines{i}(RunParams{k, WAVEFORM}, :);
            end
    
            for iSig = 1:numel(Waveforms)
                Begin = 1;
                for iEnd = (2*(MaxX-1)):(2*Scale):length(Waveforms{iSig})
                    % Draw feedback background
                    Screen('DrawTexture', Window, FeedbackTexture);
    
                    % draw feedback line
                    Screen('DrawLines', Window, ...
                        [NewX_Line CenteredFeedback(1) CenteredFeedback(3); ...
                        Waveforms{iSig}(Begin:iEnd) sum(NewYRange)/2 sum(NewYRange)/2], ...
                        [repmat(4, length(Begin:iEnd)/2, 1); 1], ...
                        [repmat(TrialColor', 1, iEnd-Begin+1) [1 1 1; 1 1 1]']);
                    Screen('DrawingFinished', Window);

                    if Begin == 1
                        if iSig == 1
                            Until = vbl + (RunParams{k, JITTER2DUR} - 0.1) * Refresh;
                        else
                            Until = vbl + (WaitFrames - 0.1) * Refresh;
                        end
                        vbl = Screen('Flip', Window, Until);
    
                        if iSig == 1
                            RunParams{k, FEED1ONSET} = vbl - BeginTime;
                        elseif iSig == 2
                            RunParams{k, FEED2ONSET} = vbl - BeginTime;
                        else
                            RunParams{k, FEED3ONSET} = vbl - BeginTime;
                        end
                    else
                        % can try no duration here to see what happens
                        % but will need duration if I plan to show signal every nth frame
                        % with n > 1, so might as well keep it for now
                        vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.1) * Refresh);
                    end
                    Begin = Begin + 2 * Scale;
                end
            end
            clear iSig iEnd
    
            %%% JITTER 3 %%%
            Screen('FillRect', Window, BgColor);
            vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.1) * Refresh);
            RunParams{k, J3ONSET} = vbl - BeginTime;
            
            %%% IMPROVED %%%
            Screen('DrawTexture', Window, ImprovedTexture);
            KbQueueStart(DeviceIndex);
            ImpVbl = Screen('Flip', Window, vbl + (RunParams{k, JITTER3DUR} - 0.1) * Refresh);
            RunParams{k, IMPROVEDONSET} = ImpVbl - BeginTime;
        
            %%% JITTER4 %%%
            % Screen('FillRect', Window, BgColor);
            vbl = Screen('Flip', Window, ImpVbl + FlipSeconds(2));
            KbQueueStop(DeviceIndex);
            [DidRespond, TimeKeysPressed] = KbQueueCheck(DeviceIndex);
            if DidRespond
                TimeKeysPressed(TimeKeysPressed == 0) = nan;
                [RT, Idx] = min(TimeKeysPressed);
                RunParams{k, IMPROVEDRESP} = KbNames{Idx};
                RunParams{k, IMPROVEDRT} = RT - ImpVbl;
            end
            KbQueueFlush(DeviceIndex);

            fprintf(1, 'RESPONSE: ImprovedRT       %0.4f\n', RunParams{k, IMPROVEDRT});
            fprintf(1, 'RESPONSE: ImprovedResponse %s\n\n', RunParams{k, IMPROVEDRESP});

            RunParams{k, J4ONSET} = vbl - BeginTime;
            Until = vbl + (RunParams{k, JITTER4DUR} - 0.1) * Refresh;
        end
        WaitSecs('UntilTime', Until);
        % now write out run design
        save(OutMat, 'RunParams');
        OutFid = fopen(OutCsv, 'w');
        fprintf(OutFid, ...
            ['Participant,', ...
            'Version,', ...
            'Run,', ...
            'TrialNum,', ...
            'Infusion,', ...
            'InfusionNum,', ...
            'Feedback,', ...
            'Waveform,', ...
            'Jitter1Dur,', ...
            'Jitter2Dur,', ...
            'Jitter3Dur,', ...
            'Jitter4Dur,', ...
            'InfOnset,', ...
            'J1Onset,', ...
            'WillImpOnset,', ...
            'J2Onset,', ...
            'Feed1Onset,', ...
            'Feed2Onset,', ...
            'Feed3Onset,', ...
            'J3Onset,', ...
            'ImprovedOnset,', ...
            'J4Onset,', ...
            'WillImpResp,', ...
            'WillImpRt,', ...
            'ImprovedResp,', ...
            'ImprovedRt\n']);
        for DesignIdx = 1:size(RunParams, 1)
            fprintf(OutFid, '%s,', Participant);
            fprintf(OutFid, '%d,', Version);
            fprintf(OutFid, '%d,', i);
            fprintf(OutFid, '%d,', RunParams{DesignIdx, TRIALNUM});
            fprintf(OutFid, '%s,', RunParams{DesignIdx, INFUSION});
            fprintf(OutFid, '%d,', RunParams{DesignIdx, INFUSIONNUM});
            fprintf(OutFid, '%s,', RunParams{DesignIdx, FEEDBACK});
            fprintf(OutFid, '%d,', RunParams{DesignIdx, WAVEFORM});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, JITTER1DUR} * Refresh);
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, JITTER2DUR} * Refresh);
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, JITTER3DUR} * Refresh);
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, JITTER4DUR} * Refresh);
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, INFONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, J1ONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, WILLIMPROVEONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, J2ONSET}); 
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, FEED1ONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, FEED2ONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, FEED3ONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, J3ONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, IMPROVEDONSET});
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, J4ONSET});
    
            % handle resposne now
            Response = RunParams{DesignIdx, WILLIMPROVERESP};
            if ischar(Response)
                if any(strcmp({'1', '1!'}, Response))
                    Response = 1;
                elseif any(strcmp({'2', '2@'}, Response))
                    Response = 2;
                elseif any(strcmp({'3', '3#'}, Response))
                    Response = 3;
                elseif any(strcmp({'4', '4$'}, Response))
                    Response = 4;
                elseif any(strcmp({'5', '5%'}, Response))
                    Response = 5;
                elseif any(strcmp({'6', '6^'}, Response))
                    Response = 6;
                elseif any(strcmp({'7', '7&'}, Response))
                    Response = 7;
                elseif any(strcmp({'8', '8*'}, Response))
                    Response = 8;
                elseif any(strcmp({'9', '9('}, Response))
                    Response = 9;
                else
                    Response = nan;
                end
            end
            fprintf(OutFid, '%d,', Response);
            fprintf(OutFid, '%0.4f,', RunParams{DesignIdx, WILLIMPROVERT});
        
            % handle resposne now
            Response = RunParams{DesignIdx, IMPROVEDRESP};
            if ischar(Response)
                if any(strcmp({'1', '1!'}, Response))
                    Response = 1;
                elseif any(strcmp({'2', '2@'}, Response))
                    Response = 2;
                elseif any(strcmp({'3', '3#'}, Response))
                    Response = 3;
                elseif any(strcmp({'4', '4$'}, Response))
                    Response = 4;
                elseif any(strcmp({'5', '5%'}, Response))
                    Response = 5;
                elseif any(strcmp({'6', '6^'}, Response))
                    Response = 6;
                elseif any(strcmp({'7', '7&'}, Response))
                    Response = 7;
                elseif any(strcmp({'8', '8*'}, Response))
                    Response = 8;
                elseif any(strcmp({'9', '9('}, Response))
                    Response = 9;
                else
                    Response = nan;
                end
            end
            fprintf(OutFid, '%d,', Response);
            fprintf(OutFid, '%0.4f\n', RunParams{DesignIdx, IMPROVEDRT});
        end
        fclose(OutFid);
        
        fprintf(1, '\n');
    end
    
    Screen('TextSize', Window, 35);
    Screen('TextFont', Window, 'Arial');
    Screen('TextStyle', Window, 0);
    DrawFormattedText(Window, 'Goodbye!', 'center', 'center', White);
    Screen('Flip', Window);
    WaitSecs(1.5);
    
    % close everything
    KbQueueRelease(DeviceIndex);
    sca;
    ListenChar(0);
    ShowCursor;
    Priority(0);
    diary off
    close all
    clear all
catch err
    % close everything
    KbQueueRelease(DeviceIndex);
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
