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
    % more columns: AntOnset, ContinueOnset, J1Onset, Feed1Onset, Feed2Onset, Feed3Onset, ImprovedOnset, J2Onset, ContinueResp, ContinueRt, ImproveResp, ImprovedRt
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
    INFONSET = 8;
    CONTINUEONSET = 9;
    J1ONSET = 10;
    FEED1ONSET = 11;
    FEED2ONSET = 12;
    FEED3ONSET = 13;
    IMPROVEDONSET = 14;
    J2ONSET = 15;
    CONTINUERESP = 16;
    CONTINUERT = 17;
    IMPROVEDRESP = 18;
    IMPROVEDRT = 19;
    
    PsychDefaultSetup(2); % default settings
    Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
    Screen('Preference', 'DefaultFontSize', 35);
    Screen('Preference', 'DefaultFontName', 'Arial');
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
    
    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Grey);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    Refresh = Screen('GetFlipInterval', Window);
    
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
    InfGreyRect = [0 0 430 690];
    InfGreyRectCenter = CenterRectOnPointd(InfGreyRect, XCenter, YCenter);
    
    InfBlackRect = [0 0 300 560];
    InfBlackRectCenter = CenterRectOnPointd(InfBlackRect, XCenter, YCenter);
    
    InfFillRect = [0 0 300 0];
    InfFillRectCentered = CenterRectOnPointd(InfFillRect, XCenter, InfBlackRectCenter(4));
    OrigInfFillRectCentered = InfFillRectCentered;
    InfFillRefreshes = 3 * round(1 / Refresh);
    InfFillInc = 560 / (InfFillRefreshes - 1);
    
    %%% TEXT (Continue/Improved:Instrumental) SETUP %%%
    % get "Continue\nInfusion?" size
    OldSize = Screen('TextSize', Window, 100);
    ContinueText = 'Continue\nInfusion?';
    [~, ~, ContinueRect] = DrawFormattedText(Window, ...
        ContinueText, 'center', 'center', White);
    ContinueRect = CenterRectOnPointd(ContinueRect, XCenter, YCenter - 135);
    
    % get "YES" and "NO" size
    Screen('TextStyle', Window, 1);
    [~, ~, YesRect] = DrawFormattedText(Window, ...
        'YES', 'center', 'center', White);
    YesRect = CenterRectOnPointd(YesRect, XCenter - 200, YCenter);
    [~, ~, NoRect] = DrawFormattedText(Window, ...
        'NO', 'center', 'center', White);
    NoRect = CenterRectOnPointd(NoRect, XCenter + 200, YCenter);
    
    % get "Improved?" size
    Screen('TextStyle', Window, 0);
    ImprovedText = 'Improved?';
    [~, ~, ImprovedRect] = DrawFormattedText(Window, ...
        ImprovedText, 'center', 'center', White);
    ImprovedRect = CenterRectOnPointd(ImprovedRect, XCenter, YCenter - 95);
    
    Screen('FillRect', Window, Black);
    Screen('TextSize', Window, OldSize);
    
    %%% FEEDBACK SETUP %%%
    % Feedback rect location; this is used as position reference for most
    % other drawn objects
    FeedbackRect = [0 0 920 750];
    FeedbackXCenter = 52 + XCenter;
    CenteredFeedback = CenterRectOnPointd(FeedbackRect, FeedbackXCenter, YCenter);
    RefX = CenteredFeedback(1);
    RefY = CenteredFeedback(2);
    
    % set "Neurofeedback Signal" label location
    [NeuroTexture NeuroBox] = MakeTextTexture(Window, ...
        'Neurofeedback Signal', Grey, [], 55);
    NeuroXLoc = RefX - 69 - 5;
    NeuroLoc = CenterRectOnPointd(NeuroBox, NeuroXLoc, YCenter);
    
    % make a frame for my testing purposes
    Frame = [0 0 1025 769];
    CenteredFrame = CenterRectOnPointd(Frame, XCenter, YCenter);
    
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
    % load FeedbackSigs and NoFeedbackSigs
    load('./DebugScripts/Development/Waveforms.mat');
    
    % modify signals to allow continuous plotting between them
    ModFeedSigs = cell(size(FeedbackSigs));
    ModNoFeedSigs = cell(size(NoFeedbackSigs));
    for i = 1:size(ModFeedSigs, 1)
        ModFeedSigs{i, 1} = FeedbackSigs{i, 1};
    
        for k = 2:size(ModFeedSigs, 2)
            BeginSig1 = length(FeedbackSigs{i, k - 1}) - MaxX + 1 + Scale;
            ModFeedSigs{i, k} = [FeedbackSigs{i, k - 1}(BeginSig1:end) ...
                FeedbackSigs{i, k}];
        end
    end 
    clear i k
    
    for i = 1:size(ModNoFeedSigs, 1)
        ModNoFeedSigs{i, 1} = NoFeedbackSigs{i, 1};
    
        for k = 2:size(ModNoFeedSigs, 2)
            BeginSig1 = length(NoFeedbackSigs{i, k - 1}) - MaxX + 1 + Scale;
            ModNoFeedSigs{i, k} = [NoFeedbackSigs{i, k - 1}(BeginSig1:end) ...
                NoFeedbackSigs{i, k}];
        end
    end
    clear i k
    
    % convert from old range values to new range values
    NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
    
    for i = 1:size(ModFeedSigs, 1)
        for k = 1:size(ModFeedSigs, 2)
            ModFeedSigs{i, k} = (ModFeedSigs{i, k} - YRange(1)) / ...
                diff(YRange)*diff(NewYRange)+NewYRange(1);
            ModFeedSigs{i, k} = NewYRange(2) - ModFeedSigs{i, k} + NewYRange(1);
        end
    end
    clear i k
    
    for i = 1:size(ModNoFeedSigs, 1)
        for k = 1:size(ModNoFeedSigs, 2)
            ModNoFeedSigs{i, k} = (ModNoFeedSigs{i, k} - YRange(1)) / ...
                diff(YRange)*diff(NewYRange)+NewYRange(1);
            ModNoFeedSigs{i, k} = NewYRange(2) - ModNoFeedSigs{i, k} + NewYRange(1);
        end
    end
    clear i k
    
    % create values that appear as continuous lines when plotted
    NewX_Line = zeros(1, 2*(length(NewX)-1));
    NewX_Line(1:2:end) = NewX(1:end-1);
    NewX_Line(2:2:end) = NewX(2:end);
    
    LineFeedbackSigs = cell(size(ModFeedSigs));
    for i = 1:size(LineFeedbackSigs, 1)
        for k = 1:size(LineFeedbackSigs, 2)
            LineFeedbackSigs{i, k} = zeros(1, 2*(length(ModFeedSigs{i, k})-1));
            LineFeedbackSigs{i, k}(1:2:end) = ModFeedSigs{i, k}(1:end-1);
            LineFeedbackSigs{i, k}(2:2:end) = ModFeedSigs{i, k}(2:end);
        end
    end
    clear i k
    
    LineNoFeedbackSigs = cell(size(ModNoFeedSigs));
    for i = 1:size(LineNoFeedbackSigs, 1)
        for k = 1:size(LineNoFeedbackSigs, 2)
            LineNoFeedbackSigs{i, k} = zeros(1, 2*(length(ModNoFeedSigs{i, k})-1));
            LineNoFeedbackSigs{i, k}(1:2:end) = ModNoFeedSigs{i, k}(1:end-1);
            LineNoFeedbackSigs{i, k}(2:2:end) = ModNoFeedSigs{i, k}(2:end);
        end
    end
    clear i k
    
    for i = StartRun:EndRun
        RunIdx = [Design{:, RUN}]' == i;
        RunDesign = Design(RunIdx, :);
    
        % pre-populate RT and Response with NaN
        for k = 1:size(RunDesign)
            RunDesign{k, CONTINUERESP} = nan;
            RunDesign{k, CONTINUERT} = nan;
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
            'center', 'center');
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
            Screen('FillRect', Window, ...
                [0.5 0.5 0.5; 0 0 0; 1 0 0]', ...
                [InfGreyRectCenter' InfBlackRectCenter' InfFillRectCentered']);
            InfVbl = Screen('Flip', Window, Until);
            if k == 1
                BeginTime = InfVbl;
            end
            RunDesign{k, INFONSET} = InfVbl - BeginTime;
    
            if strcmp(RunDesign{k, INFUSION}, 'Yes')
                for iInc = 2:InfFillRefreshes
                    InfFillRectCentered(2) = InfFillRectCentered(2) - InfFillInc;
                    Screen('FillRect', Window, ...
                        [0.5 0.5 0.5; 0 0 0; 1 0 0]', ...
                        [InfGreyRectCenter' InfBlackRectCenter' InfFillRectCentered']);
                    Screen('Flip', Window);
                end
                InfFillRectCentered = OrigInfFillRectCentered;
            end
            clear iInc
    
            %%% CONTINUE RUNNING CODE %%%
            DrawFormattedText(Window, ContinueText, 'center', 'center', ...
                White, [], [], [], [], [], ContinueRect);
            DrawFormattedText(Window, 'YES', 'center', 'center', ...
                White, [], [], [], [], [], YesRect);
            DrawFormattedText(Window, 'NO', 'center', 'center', ...
                White, [], [], [], [], [], NoRect);
            if strcmp(RunDesign{k, INFUSION}, 'Yes')
                ContVbl = Screen('Flip', Window);
            else
                ContVbl = Screen('Flip', Window, InfVbl + 3 - 0.5 * Refresh);
            end
            KbQueueStart(DeviceIndex);
            RunDesign{k, CONTINUEONSET} = ContVbl - BeginTime;
        
            %%% JITTER1 %%%
            Screen('FillRect', Window, Black);
            vbl = Screen('Flip', Window, ContVbl + 2);
    
            KbQueueStop(DeviceIndex);
            [DidRespond, TimeKeysPressed] = KbQueueCheck(DeviceIndex);
            if DidRespond
                TimeKeysPressed(TimeKeysPressed == 0) = nan;
                [RT, Idx] = min(TimeKeysPressed);
                RunDesign{k, CONTINUERESP} = KbNames{Idx};
                RunDesign{k, CONTINUERT} = RT - ContVbl;
            end
            KbQueueFlush(DeviceIndex);
    
            fprintf(1, 'Run: %d, Trial: %d, RT: %0.4f, Response: %s\n', ...
                i, k, RunDesign{k, CONTINUERT}, RunDesign{k, CONTINUERESP});
            RunDesign{k, J1ONSET} = vbl - BeginTime;
            
            %%% FEEDBACK RUNNING CODE %%%
            
            % set Window text values to be safe
            Screen('TextSize', Window, 35);
            Screen('TextFont', Window, 'Arial');
            Screen('TextStyle', Window, 0);
    
            if strcmp(RunDesign{k, FEEDBACK}, 'None')
                % Draw feedback background
                % Draw rectangles
                Screen('FillRect', Window, ...
                    [0.5 0.5 0.5; 0 0 0]', ...
                    [Rect' CenteredFeedback']);
                
                % Draw "Neurofeedback Signal"
                Screen('DrawTexture', Window, NeuroTexture, [], NeuroLoc, -90);
                
                % draw feedback number labels
                Screen('DrawText', Window, ...
                    '100', RefX - 57, RefY - 6, Black);
                Screen('DrawText', Window, ...
                    '50', RefX - 38, RefY + 167, Black);
                Screen('DrawText', Window, ...
                    '0', RefX - 19, RefY + 362, Black);
                Screen('DrawText', Window, ...
                    '-50', RefX - 50, RefY + 548, Black);
                Screen('DrawText', Window, ...
                    '-100', RefX - 69, RefY + 731, Black);
                % end feedback background
    
                vbl = Screen('Flip', Window, ...
                    vbl + RunDesign{k, JITTER1DUR} - 0.5 * Refresh);
    
                RunDesign{k, FEED1ONSET} = vbl - BeginTime;
                RunDesign{k, FEED2ONSET} = nan;
                RunDesign{k, FEED3ONSET} = nan;
            else
                if strcmp(RunDesign{k, FEEDBACK}, 'Positive')
                    Signals = LineFeedbackSigs(RunDesign{k, WAVEFORM}, :);
                else
                    Signals = LineNoFeedbackSigs(RunDesign{k, WAVEFORM}, :);
                end
    
                for iSig = 1:numel(Signals)
                    Begin = 1;
                    for iEnd = (2*(MaxX-1)):(2*Scale):length(Signals{iSig})
                        % Draw feedback background
                        % Draw rectangles
                        Screen('FillRect', Window, ...
                            [0.5 0.5 0.5; 0 0 0]', ...
                            [Rect' CenteredFeedback']);
                        
                        % Draw "Neurofeedback Signal"
                        Screen('DrawTexture', Window, NeuroTexture, [], NeuroLoc, -90);
                        
                        % draw feedback number labels
                        Screen('DrawText', Window, ...
                            '100', RefX - 57, RefY - 6, Black);
                        Screen('DrawText', Window, ...
                            '50', RefX - 38, RefY + 167, Black);
                        Screen('DrawText', Window, ...
                            '0', RefX - 19, RefY + 362, Black);
                        Screen('DrawText', Window, ...
                            '-50', RefX - 50, RefY + 548, Black);
                        Screen('DrawText', Window, ...
                            '-100', RefX - 69, RefY + 731, Black);
                        % end feedback background
    
                        % draw feedback line
                        Screen('DrawLines', Window, ...
                            [NewX_Line NewXRange(1) NewXRange(2); ...
                            Signals{iSig}(Begin:iEnd) sum(NewYRange)/2 sum(NewYRange)/2], ...
                            [repmat(4, length(Begin:iEnd)/2, 1); 1], ...
                            [repmat([1 0 0]', 1, iEnd-Begin+1) [1 1 1; 1 1 1]']);
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
                            % vbl = Screen('Flip', Window);
                        end
                        Begin = Begin + 2 * Scale;
                    end
                end
            end
            clear iSig iEnd
    
            %%% IMPROVED %%%
            DrawFormattedText(Window, ImprovedText, 'center', 'center', ...
                White, [], [], [], [], [], ContinueRect);
            DrawFormattedText(Window, 'YES', 'center', 'center', ...
                White, [], [], [], [], [], YesRect);
            DrawFormattedText(Window, 'NO', 'center', 'center', ...
                White, [], [], [], [], [], NoRect);
            if strcmp(RunDesign{k, FEEDBACK}, 'None')
                ImpVbl = Screen('Flip', Window, vbl + 10 - 0.5 * Refresh);
            else
                ImpVbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5) * Refresh);
            end
            KbQueueStart(DeviceIndex);
            RunDesign{k, IMPROVEDONSET} = ImpVbl - BeginTime;
        
            %%% JITTER2 %%%
            Screen('FillRect', Window, Black);
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
            'Feedback,', ...
            'Waveform,', ...
            'Jitter1Dur,', ...
            'Jitter2Dur,', ...
            'InfOnset,', ...
            'ContinueOnset,', ...
            'J1Onset,', ...
            'Feed1Onset,', ...
            'Feed2Onset,', ...
            'Feed3Onset,', ...
            'ImprovedOnset,', ...
            'J2Onset,', ...
            'ContinueResp,', ...
            'ContinueRt,', ...
            'ImprovedResp,', ...
            'ImprovedRt\n']);
        for DesignIdx = 1:size(RunDesign, 1)
            fprintf(OutFid, '%s,', Participant);
            fprintf(OutFid, '%d,', i);
            fprintf(OutFid, '%d,', RunDesign{DesignIdx, TRIALNUM});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, INFUSION});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, FEEDBACK});
            fprintf(OutFid, '%d,', RunDesign{DesignIdx, WAVEFORM});
            fprintf(OutFid, '%0.1f,', RunDesign{DesignIdx, JITTER1DUR});
            fprintf(OutFid, '%0.1f,', RunDesign{DesignIdx, JITTER2DUR});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, INFONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, CONTINUEONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, J1ONSET}); fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, FEED1ONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, FEED2ONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, FEED3ONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, IMPROVEDONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, J2ONSET});
    
            % handle resposne now
            Response = RunDesign{DesignIdx, CONTINUERESP};
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
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, CONTINUERT});
        
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
    
    DrawFormattedText(Window, 'Goodbye!', 'center', 'center');
    Screen('Flip', Window);
    WaitSecs(3);
    
    % close everything
    KbQueueRelease(DeviceIndex);
    sca;
    Priority(0);
    
    
    % we will be working in 1024 x 768 resolution
    % orignal FeedbackBoxResolution:
    %   LeftLocation = round(0.232 * 600) = 139
    %   BottomLocation = round(0.135 * 600) = 81
    %   RightLocation = round(0.752 * 600) + 139 = 590
    %   TopLocation = round(0.752 * 600) + 81 = 532
    %   LtoRPixels = 451
    %   BtoTPixels = 451
    %   LOffsetFromMid = 139 - 300 = -161
    %   BOffsetFromMid = 81 - 300 = -219
    %   OriginalSpeed = 451/4 = 112 pixels/second
    %   56% of screen^2
    
    % *** NEW FEEDBACK RESOLUTION = 750 x 750
    %   LeftLocation = 
    
    % original BarResolution
    %   LeftLocation = round(0.1 * 600) = 60
    %   BottomLocation = round(0.135 * 600) = 81
    %   RightLocation = round(0.032 * 600) + 60 = 79
    %   TopLocation = round(0.752 * 600) + 81 = 532
    %   LtoRPixels = 19
    %   BtoTPixels = 451
    
    % original resolution was set at 800 x 600
    % original figure resolution was set at 600 x 600
    % assume resolution is 1024 x 768; let's start off with this
    % matlab position = [left bottom width height]
    % PTB position = [leftbegin bottombegin rightend topend]
    
    % CenterRectOnPointd
end
