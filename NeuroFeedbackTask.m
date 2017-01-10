function NeuroFeedbackTask()

    sca;
    clear all;
    DeviceIndex = [];
    
    if isunix
        InScan = -1;
        StartRun = -1;
        EndRun = -1;
        Testing = -1;
        Suppress = -1;
    
        % Turns on PTB debugging
        while ~any(InScan == [1 0])
            InScan = input('Scan? (1:Yes, 0:No): ');
        end
    
        Participant = input('Participant ID: ', 's');
    
        while ~any(StartRun == [1 2])
            StartRun = input('Start run: 1 - 2: ');
        end
    
        while ~any(EndRun == [1 2])
            EndRun = input('End run: 1 - 2: ');
        end
    
        % Determines csv used
        while ~any(Testing == [1 0])
            Testing = input('Testing? (1:Yes, 0:No): ');
        end
    
        while ~any(Suppress == [1 0])
            Suppress = input('Suppress? (1: Yes, 0:No): ');
        end

    else
        Responses = inputdlg({'Scan (1:Yes, 0:No):', ...
            'Participant ID:', 'Start run: 1 - 2:', 'End run: 1 - 2:'});
        InScan = str2num(Responses{1});
        Participant = Responses{2};
        StartRun = str2num(Responses{3});
        EndRun = str2num(Responses{4});
        Testing = 0;
        Suppress = 1;
    end
    
    if InScan == 0
        PsychDebugWindowConfiguration
    end
    
    OutDir = fullfile(pwd, 'Responses', Participant);
    mkdir(OutDir);
    
    % read in design
    if Testing
        DesignFid = fopen('TestOrder.csv', 'r');
    else
        DesignFid = fopen('Design.csv', 'r');
    end
    Tmp = textscan(DesignFid, '%f%f%s%s%f%f%f', ...
        'Delimiter', ',', 'Headerlines', 1);
    fclose(DesignFid);
    % more columns: InfuisonNum, InfOnset, WillImpOnset, J1Onset, Feed1Onset, Feed2Onset, Feed3Onset, ImprovedOnset, J2Onset, WillImpResp, WillImpRt, ImproveResp, ImprovedRt
    % split feedback into baseline and feedback later
    Design = cell(numel(Tmp{1}), numel(Tmp) + 13);
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
    INFUSIONNUM = 8;
    INFONSET = 9;
    WILLIMPROVEONSET = 10;
    J1ONSET = 11;
    FEED1ONSET = 12;
    FEED2ONSET = 13;
    FEED3ONSET = 14;
    IMPROVEDONSET = 15;
    J2ONSET = 16;
    WILLIMPROVERESP = 17;
    WILLIMPROVERT = 18;
    IMPROVEDRESP = 19;
    IMPROVEDRT = 20;

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
    
    PsychDefaultSetup(2); % default settings
    % Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
    Screen('Preference', 'DefaultFontSize', 35);
    Screen('Preference', 'DefaultFontName', 'Arial');
    % Screen('Preference', 'TextAntiAliasing', 2);
    % Screen('Preference', 'TextAlphaBlending', 1);
    if Suppress
        Screen('Preference', 'SuppressAllWarnings', 1);
        Screen('Preference', 'Verbosity', 0);
    end
    Screens = Screen('Screens'); % get scren number
    ScreenNumber = max(Screens);
    
    % Define black and white
    White = WhiteIndex(ScreenNumber);
    Black = BlackIndex(ScreenNumber);
    Grey = White * 0.5;
    BgColor = [44 58 55] * 1/255;
    UnfilledColor = [38 41 26] * 1/255;
    BoxColor = [21 32 17] * 1/255;
    FilledColor = [41 249 64] * 1/255;
    
    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, BgColor);
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
    KeyNamesOfInterest = {'1!', '2@', '1', '2'};
    KeysOfInterest = zeros(1, 256);
    for i = 1:numel(KeyNamesOfInterest)
        KeysOfInterest(KbName(KeyNamesOfInterest{i})) = 1;
    end
    clear i
    KbQueueCreate(DeviceIndex, KeysOfInterest);

    %%% INFUSION SETUP %%%
    Ovals = {
        [535.09 67] % PROTOCOL 196KJ ellipse center
        [535.09 180] % PROTOCOL 564D ellipse center
        [535.09 293] % CALIBRATION C ellipse center
        [535.09 406] % CALIBRATION D ellipse center
    };
    Ovals = ConvertCoordinates(ScanCenter, [XCenter YCenter], Ovals);
    FilledOvals = Ovals;
    for i = 1:size(Ovals, 1)
        OvalRect{i, 1} = CenterRectOnPointd([0 0 70 70], Ovals{i}(1), Ovals{i}(2));
        FilledOvalRect{i, 1} = CenterRectOnPointd([0 0 68 68], Ovals{i}(1), Ovals{i}(2));
    end
    
    Screen('TextSize', Window, 46);
    Screen('TextStyle', Window, 1);
    OvalText = {
        'PROTOCOL 196KJ';
        'PROTOCOL 564D';
        'CALIBRATION C';
        'CALIBRATION D';
    };
    TextLeftRef = ConvertCoordinates(ScanCenter, [XCenter YCenter], ...
        {[45 38 407.54 56.78]});
    for i = 1:size(OvalText, 1)
        OvalTextRect{i, 1} = Screen('TextBounds', Window, OvalText{i});
        OvalTextRect{i, 1} = AlignRect(OvalTextRect{i}, OvalRect{i}, 'center');
        OvalTextRect{i, 1} = AlignRect(OvalTextRect{i}, TextLeftRef{1}, 'left');
    end
    
    InterfaceLoc = {
        [253.5 629] % number rectangle center [47 522 413 214]
        % [707.18 714.20] % mL/h center [621 669 172.07 88.88] font=72 pt
        % [672.11 720.46] % mL/h center [617 691 109.93 56.78] font=46 pt
        % [309.05 586.91] % 888 background center [60 424 496.61 324.58]
        % [362.93 586.91] % 888 filled center [167 424 388.38 324.58]
        % [913 384.5] % bar background [832.99 32 160 705]
        [876 383.5] % bar background [759 31 234 705]
    };
    InterfaceLoc = ConvertCoordinates(ScanCenter, [XCenter YCenter], ...
        InterfaceLoc);
    NumberRect = CenterRectOnPointd([47 522 47+413 522+214], InterfaceLoc{1}(1), ...
        InterfaceLoc{1}(2));
    ProgressBgRect = CenterRectOnPointd([759 31 759+234 31+705], InterfaceLoc{2}(1), ...
        InterfaceLoc{2}(2));
    
    Screen('TextFont', Window, 'digital-7');
    Screen('TextSize', Window, 250);
    Screen('TextStyle', Window, 0);
    BgNumRect = Screen('TextBounds', Window, '888');
    BgNumRect = AlignRect(BgNumRect, NumberRect, 'center');
    
    Screen('TextSize', Window, 46);
    Screen('TextFont', Window, 'Arial');
    Screen('TextStyle', Window, 0);
    UnitRect = Screen('TextBounds', Window, 'mL/h');
    UnitRect = AlignRect(UnitRect, NumberRect, 'bottom');
    UnitRect = AlignRect(UnitRect, ...
        [(XCenter-(ScanCenter(1)-480)) 0 (XCenter-(ScanCenter(1)-480)) 0], ...
        'left');
    
    ProgressLoc = {
        [876 646] % box1 [763.99 561 224 170] 
        [876 471] % box2 [763.99 386 224 170]
        [876 296] % box3 [763.99 211 224 170]
        [876 121] % box4 [763.99 36 224 170]
        % [913 699.5] % box1 [838 667 150 65]
        % [913 629.5] % box2 [838 596.99 150 65]
        % [913 559.5] % box3 [838 527 150 64]
        % [913 489.5] % box4 [838 456.99 150 65]
        % [913 419.5] % box5 [838 387 150 65]
        % [913 349.5] % box6 [838 317 150 65]
        % [913 279.5] % box7 [838 246.99 150 65]
        % [913 209.5] % box8 [838 177 150 65]
        % [913 139.5] % box9 [838 106.99 150 65]
        % [913 69.5] % box10 [838 37 150 65]
    };
    ProgressLoc = ConvertCoordinates(ScanCenter, [XCenter YCenter], ...
        ProgressLoc);
    ProgressBox = [0 0 224 170];
    for i = 1:size(ProgressLoc, 1)
        ProgressRect{i, 1} = CenterRectOnPointd(ProgressBox, ProgressLoc{i}(1), ...
            ProgressLoc{i}(2));
    end
    
    % open texture
    InfTexture = Screen('MakeTexture', Window, zeros(Rect(4), Rect(3)));
    Screen('FillRect', InfTexture, BgColor);
    
    % draw onto texture first
    for i = 1:size(OvalRect, 1)
        Screen('FillOval', InfTexture, Black, OvalRect{i});
        Screen('FrameOval', InfTexture, White, OvalRect{i}, 2);
    end
    
    Screen('FillRect', InfTexture, BoxColor, NumberRect);
    Screen('FillRect', InfTexture, BoxColor, ProgressBgRect);
    
    for i = 1:size(ProgressRect, 1)
        Screen('FillRect', InfTexture, UnfilledColor, ProgressRect{i});
    end

    InfInc = 3/11;
    
    %%% WILLIMPROVE SETUP %%%
    WillImproveTexture = Screen('MakeTexture', Window, zeros(Rect(4), Rect(3)));
    Screen('FillRect', WillImproveTexture, BgColor);

    % "WillImp\nInfusion?"
    Screen('TextSize', WillImproveTexture, 100);
    WillImpText = 'Will improve?';
    WillImpRect = Screen('TextBounds', WillImproveTexture, WillImpText);
    WillImpRect = CenterRectOnPoint(WillImpRect, XCenter, YCenter - (384 - 768/4));
    DrawFormattedText(WillImproveTexture, WillImpText, 'center', 'center', ...
        White, [], [], [], [], [], WillImpRect);

    % get "YES" and "NO" size
    Screen('TextStyle', WillImproveTexture, 1);
    YesRect = Screen('TextBounds', Window, 'YES');
    YesRect = CenterRectOnPoint(YesRect, XCenter - (512 - 1024/4), YCenter);
    DrawFormattedText(WillImproveTexture, 'YES', 'center', 'center', ...
        White, [], [], [], [], [], YesRect);

    NoRect = Screen('TextBounds', Window, 'NO');
    NoRect = CenterRectOnPoint(NoRect, XCenter - (512 - 1024*3/4), YCenter);
    DrawFormattedText(WillImproveTexture, 'NO', 'center', 'center', ...
        White, [], [], [], [], [], NoRect);
    
    % get "Improved?" size
    OldSize = Screen('TextSize', Window, 100);
    ImprovedText = 'Improved?';
    ImprovedRect = Screen('TextBounds', Window, ImprovedText);
    ImprovedRect = CenterRectOnPoint(ImprovedRect, XCenter, YCenter - (384 - 768/4));
    
    Screen('FillRect', Window, Black);
    Screen('TextSize', Window, OldSize);
    
    %%% FEEDBACK SETUP %%%
    % Feedback rect location; this is used as position reference for most
    % other drawn objects
    FeedbackTexture = Screen('MakeTexture', Window, zeros(Rect(4), Rect(3)));

    FeedbackRect = [0 0 920 750];
    FeedbackXCenter = 52 + XCenter;
    CenteredFeedback = CenterRectOnPoint(FeedbackRect, FeedbackXCenter, YCenter);
    RefX = CenteredFeedback(1);
    RefY = CenteredFeedback(2);
    Screen('FillRect', FeedbackTexture, [BgColor; UnfilledColor]', ...
        [Rect' CenteredFeedback']);
    
    % set "Neurofeedback Signal" label location
    [NeuroTexture NeuroBox] = MakeTextTexture(Window, ...
        'Amplitude', BgColor, [], 55, White);
    NeuroXLoc = RefX - 69 - 5;
    NeuroLoc = CenterRectOnPoint(NeuroBox, NeuroXLoc, YCenter);
    Screen('DrawTexture', FeedbackTexture, NeuroTexture, [], NeuroLoc, -90);
    
    % draw feedback number labels
    OldFont = Screen('TextFont', FeedbackTexture, 'digital-7');
    Screen('DrawText', FeedbackTexture, '100', RefX - 57, RefY - 6, White);
    Screen('DrawText', FeedbackTexture, '50', RefX - 38, RefY + 167, White);
    Screen('DrawText', FeedbackTexture, '0', RefX - 19, RefY + 362, White);
    Screen('DrawText', FeedbackTexture, '-50', RefX - 50, RefY + 548, White);
    Screen('DrawText', FeedbackTexture, '-100', RefX - 69, RefY + 731, White);
    Screen('TextFont', FeedbackTexture, OldFont);
    
    % make a frame for my testing purposes
    Frame = [0 0 1025 769];
    CenteredFrame = CenterRectOnPoint(Frame, XCenter, YCenter);
    
    % now experiment with drawing signal
    Scale = 2; % move by this many points across signals
    FlipSecs = 2/60; % time to display signal
    WaitFrames = round(FlipSecs / Refresh); % display signal every this frame
    % set MaxX, this value determines the number of seconds to move from one
    % end of the screen to the other; FlipSecs and MaxX depend on each other
    MaxX = Scale*120;
    
    % create original and plotted ranges
    XRange = [0 (MaxX-1)];
    YRange = [-100 100];
    NewXRange = [CenteredFeedback(1) CenteredFeedback(3)];
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
   
    for i = StartRun:EndRun
        RunIdx = [Design{:, RUN}]' == i;
        RunDesign = Design(RunIdx, :);
    
        % pre-populate RT and Response with NaN
        for k = 1:size(RunDesign)
            RunDesign{k, WILLIMPROVERESP} = nan;
            RunDesign{k, WILLIMPROVERT} = nan;
            RunDesign{k, IMPROVEDRESP} = nan;
            RunDesign{k, IMPROVEDRT} = nan;
        end
        clear k;
    
        KbEventFlush;
        
        % handle file naming
        OutName = sprintf('%s_Run_%02d_%s', Participant, i, ...
            datestr(now, 'yyyymmdd_HHMMSS'));
        OutCsv = fullfile(OutDir, [OutName '.csv']);
        OutMat = fullfile(OutDir, [OutName '.mat']);
    
        % show directions while waiting for trigger '^'
        DrawFormattedText(Window, ... 
            'These are the task directions.\n\n Waiting for ''^'' to continue.', ...
            'center', 'center', White);
        Screen('Flip', Window);
        FlushEvents;
        ListenChar;
        while 1
            if CharAvail && GetChar == '^'
                break;
            end
        end
    
        Until = 0;
        for k = 1:size(RunDesign, 1)
        
            %%% INFUSION RUNNING CODE %%%
            Screen('DrawTexture', Window, InfTexture);
            
            % draw infusion text
            Screen('TextFont', Window, 'Arial');
            Screen('TextSize', Window, 46);
            Screen('TextStyle', Window, 1);
            for iText = 1:size(OvalText, 1)
                Screen('DrawText', Window, OvalText{iText}, OvalTextRect{iText}(1), ...
                    OvalTextRect{iText}(2), White);
            end
            
            Screen('TextFont', Window, 'digital-7');
            Screen('TextSize', Window, 250);
            Screen('TextStyle', Window, 0);
            Screen('DrawText', Window, '888', BgNumRect(1), BgNumRect(2), ...
                UnfilledColor);
            if any(strcmp(RunDesign{k, INFUSION}, {'A', 'B'}))
                Screen('DrawText', Window, '150', BgNumRect(1), BgNumRect(2), ...  
                    FilledColor);
            else
                Screen('DrawText', Window, '  0', BgNumRect(1), BgNumRect(2), ...  
                    FilledColor);
            end
            
            Screen('TextFont', Window, 'Arial');
            Screen('TextSize', Window, 46);
            Screen('TextStyle', Window, 0);
            Screen('DrawText', Window, 'mL/h', UnitRect(1), UnitRect(2), ...
                White);
            
            Screen('FillOval', Window, FilledColor, ...
                FilledOvalRect{Design{k, INFUSIONNUM}}); 
            Screen('FrameRect', Window, White, CenteredFrame);
            vbl = Screen('Flip', Window, Until, 1);
            if k == 1
                BeginTime = vbl;
            end
            RunDesign{k, INFONSET} = vbl - BeginTime;

            if any(strcmp(RunDesign{k, INFUSION}, {'A', 'B'}))
                for iInc = 1:size(ProgressRect, 1)
                    Screen('FillRect', Window, FilledColor, ProgressRect{iInc});
                    vbl = Screen('Flip', Window, vbl + (36 - 0.5) * Refresh, 1);
                end
            end
    
            %%% WILLIMPROVE RUNNING CODE %%%
            Screen('DrawTexture', Window, WillImproveTexture);
            if any(strcmp(RunDesign{k, INFUSION}, {'A', 'B'}))
                ContVbl = Screen('Flip', Window, vbl + (36 - 0.5) * Refresh);
            else
                ContVbl = Screen('Flip', Window, vbl + 3 - 0.5 * Refresh);
            end
            KbQueueStart(DeviceIndex);
            RunDesign{k, WILLIMPROVEONSET} = ContVbl - BeginTime;
        
            %%% JITTER1 %%%
            Screen('FillRect', Window, BgColor);
            vbl = Screen('Flip', Window, ContVbl + 2 - 0.5 * Refresh);
    
            KbQueueStop(DeviceIndex);
            [DidRespond, TimeKeysPressed] = KbQueueCheck(DeviceIndex);
            if DidRespond
                TimeKeysPressed(TimeKeysPressed == 0) = nan;
                [RT, Idx] = min(TimeKeysPressed);
                RunDesign{k, WILLIMPROVERESP} = KbNames{Idx};
                RunDesign{k, WILLIMPROVERT} = RT - ContVbl;
            end
            KbQueueFlush(DeviceIndex);
    
            fprintf(1, 'Run:              %d\n', i);
            fprintf(1, 'Trial:            %d\n', k);
            fprintf(1, 'Infusion:         %s\n', RunDesign{k, INFUSION});
            fprintf(1, 'InfRT:            %0.4f\n', RunDesign{k, WILLIMPROVERT});
            fprintf(1, 'InfResponse:      %s\n', RunDesign{k, WILLIMPROVERESP});
            RunDesign{k, J1ONSET} = vbl - BeginTime;
            
            %%% FEEDBACK RUNNING CODE %%%
            if strcmp(RunDesign{k, FEEDBACK}, 'Signal')
                Waveforms = LineSignals{i}(RunDesign{k, WAVEFORM}, :);
            else
                Waveforms = LineBaselines{i}(RunDesign{k, WAVEFORM}, :);
            end
    
            for iSig = 1:numel(Waveforms)
                Begin = 1;
                for iEnd = (2*(MaxX-1)):(2*Scale):length(Waveforms{iSig})
                    % Draw feedback background
                    Screen('DrawTexture', Window, FeedbackTexture);
    
                    % draw feedback line
                    Screen('DrawLines', Window, ...
                        [NewX_Line NewXRange(1) NewXRange(2); ...
                        Waveforms{iSig}(Begin:iEnd) sum(NewYRange)/2 sum(NewYRange)/2], ...
                        [repmat(4, length(Begin:iEnd)/2, 1); 1], ...
                        [repmat(FilledColor', 1, iEnd-Begin+1) [1 1 1; 1 1 1]']);
                    Screen('DrawingFinished', Window);

                    if Begin == 1
                        if iSig == 1
                            Until = vbl + RunDesign{k, JITTER1DUR} - 0.5 * Refresh;
                        else
                            Until = vbl + (WaitFrames - 0.5) * Refresh;
                        end
    
                        vbl = Screen('Flip', Window, Until);
    
                        if iSig == 1
                            RunDesign{k, FEED1ONSET} = vbl - BeginTime;
                        elseif iSig == 2
                            RunDesign{k, FEED2ONSET} = vbl - BeginTime;
                        else
                            RunDesign{k, FEED3ONSET} = vbl - BeginTime;
                        end
                    else
                        % can try no duration here to see what happens
                        % but will need duration if I plan to show signal every nth frame
                        % with n > 1, so might as well keep it for now
                        vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5) * Refresh);
                    end
                    Begin = Begin + 2 * Scale;
                end
            end
            clear iSig iEnd
    
            %%% IMPROVED %%%
            Screen('FillRect', Window, BgColor);
            Screen('TextSize', Window, 100);
            Screen('TextStyle', Window, 0);
            DrawFormattedText(Window, ImprovedText, 'center', 'center', ...
                White, [], [], [], [], [], ImprovedRect);
            Screen('TextStyle', Window, 1);
            DrawFormattedText(Window, 'YES', 'center', 'center', ...
                White, [], [], [], [], [], YesRect);
            DrawFormattedText(Window, 'NO', 'center', 'center', ...
                White, [], [], [], [], [], NoRect);
            ImpVbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5) * Refresh);
            KbQueueStart(DeviceIndex);
            RunDesign{k, IMPROVEDONSET} = ImpVbl - BeginTime;
        
            %%% JITTER2 %%%
            % Screen('FillRect', Window, BgColor);
            vbl = Screen('Flip', Window, ImpVbl + 2 - 0.5 * Refresh);
            KbQueueStop(DeviceIndex);
            [DidRespond, TimeKeysPressed] = KbQueueCheck(DeviceIndex);
            if DidRespond
                TimeKeysPressed(TimeKeysPressed == 0) = nan;
                [RT, Idx] = min(TimeKeysPressed);
                RunDesign{k, IMPROVEDRESP} = KbNames{Idx};
                RunDesign{k, IMPROVEDRT} = RT - ImpVbl;
            end
            KbQueueFlush(DeviceIndex);

            fprintf(1, 'ImprovedRT:       %0.4f\n', RunDesign{k, IMPROVEDRT});
            fprintf(1, 'ImprovedResponse: %s\n\n', RunDesign{k, IMPROVEDRESP});

            RunDesign{k, J2ONSET} = vbl - BeginTime;
            Until = vbl + RunDesign{k, JITTER2DUR} - 0.5 * Refresh;
        end
        WaitSecs('UntilTime', Until);
        % now write out run design
        save(OutMat, 'RunDesign');
        OutFid = fopen(OutCsv, 'w');
        fprintf(OutFid, ...
            ['Participant,', ...
            'Run,', ...
            'TrialNum,', ...
            'Infusion,', ...
            'InfusionNum,', ...
            'Feedback,', ...
            'Waveform,', ...
            'Jitter1Dur,', ...
            'Jitter2Dur,', ...
            'InfOnset,', ...
            'WillImpOnset,', ...
            'J1Onset,', ...
            'Feed1Onset,', ...
            'Feed2Onset,', ...
            'Feed3Onset,', ...
            'ImprovedOnset,', ...
            'J2Onset,', ...
            'WillImpResp,', ...
            'WillImpRt,', ...
            'ImprovedResp,', ...
            'ImprovedRt\n']);
        for DesignIdx = 1:size(RunDesign, 1)
            fprintf(OutFid, '%s,', Participant);
            fprintf(OutFid, '%d,', i);
            fprintf(OutFid, '%d,', RunDesign{DesignIdx, TRIALNUM});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, INFUSION});
            fprintf(OutFid, '%d,', RunDesign{DesignIdx, INFUSIONNUM});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, FEEDBACK});
            fprintf(OutFid, '%d,', RunDesign{DesignIdx, WAVEFORM});
            fprintf(OutFid, '%0.1f,', RunDesign{DesignIdx, JITTER1DUR});
            fprintf(OutFid, '%0.1f,', RunDesign{DesignIdx, JITTER2DUR});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, INFONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, WILLIMPROVEONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, J1ONSET}); 
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, FEED1ONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, FEED2ONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, FEED3ONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, IMPROVEDONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, J2ONSET});
    
            % handle resposne now
            Response = RunDesign{DesignIdx, WILLIMPROVERESP};
            if ischar(Response)
                if any(strcmp({'1', '1!'}, Response))
                    Response = 1;
                elseif any(strcmp({'2', '2@'}, Response))
                    Response = 2;
                else
                    Response = nan;
                end
            end
            fprintf(OutFid, '%d,', Response);
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, WILLIMPROVERT});
        
            % handle resposne now
            Response = RunDesign{DesignIdx, IMPROVEDRESP};
            if ischar(Response)
                if any(strcmp({'1', '1!'}, Response))
                    Response = 1;
                elseif any(strcmp({'2', '2@'}, Response))
                    Response = 2;
                else
                    Response = nan;
                end
            end
            fprintf(OutFid, '%d,', Response);
            fprintf(OutFid, '%0.4f\n', RunDesign{DesignIdx, IMPROVEDRT});
        end
        fclose(OutFid);
        
        fprintf(1, '\n');
    end
    
    Screen('TextSize', Window, 35);
    DrawFormattedText(Window, 'Goodbye!', 'center', 'center');
    Screen('Flip', Window);
    WaitSecs(3);
    
    % close everything
    KbQueueRelease(DeviceIndex);
    Screen('Close', WillImproveTexture);
    Screen('Close', FeedbackTexture);
    Screen('Close', InfTexture);
    Screen('Close', Window);
    sca;
    Priority(0);
end
