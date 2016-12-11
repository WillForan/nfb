function RevisedNeuroFeedbackTask()

    sca;
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
    Tmp = textscan(DesignFid, '%f%f%s%s%f%f', ...
        'Delimiter', ',', 'Headerlines', 1);
    fclose(DesignFid);
    % more columns: AntOnset, J1Onset, FeedOnset, J2Onset, AntResponse, AntRT
    % split feedback into baseline and feedback later
    Design = cell(numel(Tmp{1}), numel(Tmp) + 6);
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
    ANTICIPATION = 3;
    FEEDBACK = 4;
    JITTER1DUR = 5;
    JITTER2DUR = 6;
    ANTONSET = 7;
    J1ONSET = 8;
    FEEDONSET = 9;
    J2ONSET = 10;
    ANTRESPONSE = 11;
    ANTRT = 12;
    
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
    % might need the code below after in scanning testing
    % if InScan
    %     Screen('Resolution', Window, 1024, 768);
    % end
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    Refresh = Screen('GetFlipInterval', Window);
    
    % blend
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    %%% ANTICIPATION SETUP %%%
    % get "NEXT INFUSION" size
    OldSize = Screen('TextSize', Window, 60);
    NextRect = Screen('TextBounds', Window, 'NEXT INFUSION');
    NextRect = CenterRectOnPointd(NextRect, XCenter, YCenter - 350);
    Screen('TextSize', Window, OldSize);
    
    % get "Continue infusion?" size
    OldSize = Screen('TextSize', Window, 60);
    ContinueRect = Screen('TextBounds', Window, 'Continue infusion?');
    ContinueRect = CenterRectOnPointd(ContinueRect, XCenter, YCenter + 150);
    Screen('TextSize', Window, OldSize);
    
    % get "YES" size
    OldSize = Screen('TextSize', Window, 70);
    OldStyle = Screen('TextStyle', Window, 1);
    YesRect = Screen('TextBounds', Window, 'YES');
    YesRect = CenterRectOnPointd(YesRect, ContinueRect(1), ContinueRect(4) + 75);
    Screen('TextSize', Window, OldSize);
    Screen('TextStyle', Window, OldStyle);
    
    % get "NOT" size
    OldSize = Screen('TextSize', Window, 70);
    OldSyle = Screen('TextStyle', Window, 1);
    NoRect = Screen('TextBounds', Window, 'NOT');
    NoRect = CenterRectOnPointd(NoRect, ContinueRect(3), ContinueRect(4) + 75);
    Screen('TextSize', Window, OldSize);
    Screen('TextStyle', Window, OldStyle);
    
    % set up keyboard response
    KbNames = KbName('KeyNames');
    KeyNamesOfInterest = {'1!', '2@', '1', '2'};
    KeysOfInterest = zeros(1, 256);
    for i = 1:numel(KeyNamesOfInterest)
        KeysOfInterest(KbName(KeyNamesOfInterest{i})) = 1;
    end
    clear i
    KbQueueCreate(DeviceIndex, KeysOfInterest);
    
    %%% FEEDBACK SETUP %%%
    % Feedback rect location; this is used as position reference for most
    % other drawn objects
    FeedbackRect = [0 0 750 750];
    FeedbackXCenter = 119 + XCenter; 
    FeedbackYCenter = YCenter;
    CenteredFeedback = CenterRectOnPointd(FeedbackRect, ...
        FeedbackXCenter, FeedbackYCenter);
    RefX = CenteredFeedback(1);
    RefY = CenteredFeedback(2);
    
    % set "Neurofeedback Signal" label location
    [NeuroTexture NeuroBox] = MakeTextTexture(Window, ...
        'Neurofeedback Signal', Grey, [], 55);
    NeuroXLoc = RefX - 69 - 5;
    NeuroLoc = CenterRectOnPointd(NeuroBox, NeuroXLoc, YCenter);
    
    % set dose rect location
    BarRect = [0 0 50 750];
    BarXCenter = RefX - 69 -5 - NeuroBox(4);
    BarYCenter = YCenter;
    CenteredBar = CenterRectOnPointd(BarRect, ...
        BarXCenter, BarYCenter);
    [DoseX, DoseY] = RectCenter(CenteredBar);
    
    % set "% dose administered" label location
    [DoseTexture DoseBox] = MakeTextTexture(Window, ...
        '% dose administered', Grey, [], 55);
    DoseXLoc = CenteredBar(1) - 60;
    DoseLoc = CenterRectOnPointd(DoseBox, DoseXLoc, YCenter);
    
    % create dose level rect
    DoseLevelRect = [0 0 50 5];
    
    % create changing time dose rect
    PerDoseRect = [0 0 48 0];
    PerDoseRect = CenterRectOnPointd(PerDoseRect, ...
        DoseX, CenteredBar(4) - 1);
    OrigPerDoseY = PerDoseRect(2);
    
    % make a frame for my testing purposes
    % Frame = [0 0 1025 769];
    % CenteredFrame = CenterRectOnPointd(Frame, XCenter, YCenter);
    
    % now experiment with drawing signal
    Scale = 2; % move by this many points across signals
    FlipSecs = 1/20; % time to display signal
    WaitFrames = round(FlipSecs / Refresh); % display signal every this frame
    % set MaxX, this value determines the number of seconds to move from one
    % end of the screen to the other; FlipSecs and MaxX depend on each other
    MaxX = Scale*80;
    
    % create original and plotted ranges
    XRange = [0 MaxX];
    YRange = [-100 100];
    NewXRange = [CenteredFeedback(1) CenteredFeedback(3)];
    NewYRange = [CenteredFeedback(2) CenteredFeedback(4)];
    
    % dummy signals
    X = 0:(MaxX-1);
    Noise = -99 + (99+99).*rand(1, Scale*4*20 + Scale*10*20);
    % Line1 = 0:(100/119):100;
    % Steep = 1.33*Line1;
    % Slow = 0.75*Line1;
    % Slope = zeros(1, 120);
    % Slope(1:2:end) = Steep(1:2:end);
    % Slope(2:2:end) = Steep(2:2:end);
    % Slope(Slope > 100) = 100;
    % Signal = [(10 - -10) + (-10*rand(1, 4*60)) ...
    %     Slope ...
    %     (98 - 85) + 85*rand(1, 5*60)];
    
    % convert from old range values to new range values
    NewX = (X-XRange(1))/diff(XRange)*diff(NewXRange)+NewXRange(1);
    % NewSignal = (Signal-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
    % NewSignal = NewYRange(2) - NewSignal + NewYRange(1);
    NewNoise = (Noise-YRange(1))/diff(YRange)*diff(NewYRange)+NewYRange(1);
    NewNoise = NewYRange(2) - NewNoise + NewYRange(1);
    
    % create values that appear as continuous lines when plotted
    NewX_Line = zeros(1, 2*(length(NewX)-1));
    NewX_Line(1:2:end) = NewX(1:end-1);
    NewX_Line(2:2:end) = NewX(2:end);
    % NewSignal_Line =  zeros(1, 2*(length(NewSignal)-1));
    % NewSignal_Line(1:2:end) = NewSignal(1:end-1);
    % NewSignal_Line(2:2:end) = NewSignal(2:end);
    NewNoise_Line =  zeros(1, 2*(length(NewNoise)-1));
    NewNoise_Line(1:2:end) = NewNoise(1:end-1);
    NewNoise_Line(2:2:end) = NewNoise(2:end);
    
    % do bar movment calculation here
    % NumPoints = (length(NewSignal_Line) - (2*(MaxX-1)))/2;
    NumPoints = (length(NewNoise_Line) - (2*(MaxX-1)))/2;
    Numpoints = (length(Noise) - (2*(MaxX-1)))/2;
    Increment = (750 - 1)/(NumPoints/Scale);
    
    for i = StartRun:EndRun
        RunIdx = [Design{:, RUN}]' == i;
        RunDesign = Design(RunIdx, :);
    
        % pre-populate RT and Response with NaN
        for k = 1:size(RunDesign)
            RunDesign{k, ANTRESPONSE} = nan;
            RunDesign{k, ANTRT} = nan;
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
        BeginTime = GetSecs;
        for k = 1:size(RunDesign, 1)
        
            %%% ANTICIPATION RUNNING CODE %%%
    
            % set timer color and prompt text
            if strcmp(RunDesign{k, ANTICIPATION}, 'Infusion')
                TimerColor = [1 0 0];
                PromptText = 'NEXT INUFSION';
            else
                TimerColor = [1 1 1];
                PromptText = 'NEXT NO INFUSION';
            end
    
            for iSec = 5:-1:1
                % prompttext
                Screen('TextSize', Window, 60);
                DrawFormattedText(Window, PromptText, 'center', 'center',  ...
                    [0 1 0], [], [], [], [], [], NextRect);
            
                % Time text
                Screen('TextSize', Window, 200);
                Screen('TextStyle', Window, 1);
                DrawFormattedText(Window, sprintf('00:%02d', iSec), ...
                    'center', 'center', TimerColor);
                Screen('TextStyle', Window, 0);
            
                if iSec < 3
                    Screen('TextSize', Window, 60);
                    DrawFormattedText(Window, 'Continue infusion?', 'center', 'center', ...
                        White, [], [], [], [], [], ContinueRect);
            
                    Screen('TextSize', Window, 70);
                    Screen('TextStyle', Window, 1);
                    DrawFormattedText(Window, 'YES', 'center', 'center', ...
                        White, [], [], [], [], [], YesRect);
                    DrawFormattedText(Window, 'NOT', 'center', 'center', ...
                        White, [], [], [], [], [], NoRect);
                    Screen('TextStyle', Window, 0);
                end
            
                if iSec == 5
                    vbl = Screen('Flip', Window, Until);
                    RunDesign{k, ANTONSET} = vbl - BeginTime;
                else
                    vbl = Screen('Flip', Window, vbl + 1 - Refresh);
                    if iSec == 2
                        KbQueueStart(DeviceIndex);
                        ResponseOnset = vbl;
                    end
                end
            
            end
            clear iSec
            
        
            %%% JITTER1 %%%
            Screen('FillRect', Window, Black);
            vbl = Screen('Flip', Window, vbl + 1 - Refresh);
    
            KbQueueStop(DeviceIndex);
            [DidRespond, TimeKeysPressed] = KbQueueCheck(DeviceIndex);
            if DidRespond
                TimeKeysPressed(TimeKeysPressed == 0) = nan;
                [RT, Idx] = min(TimeKeysPressed);
                RunDesign{k, ANTRESPONSE} = KbNames{Idx};
                RunDesign{k, ANTRT} = RT - ResponseOnset;
            end
            KbQueueFlush(DeviceIndex);
    
            fprintf(1, 'Run: %d, Trial: %d, RT: %0.4f, Response: %s\n', ...
                i, k, RunDesign{k, ANTRT}, RunDesign{k, ANTRESPONSE});
            RunDesign{k, J1ONSET} = vbl - BeginTime;
            
            %%% FEEDBACK RUNNING CODE %%%
            
            % set Window text values to be safe
            Screen('TextSize', Window, 35);
            Screen('TextFont', Window, 'Arial');
            Screen('TextStyle', Window, 0);
            Screen('FillRect', Window, Grey);

            if strcmp(RunDesign{k, ANTICIPATION}, 'Infusion')
                DoseLevelRect = CenterRectOnPointd(DoseLevelRect, ...
                    DoseX, CenteredBar(2) - 1);
            else
                DoseLevelRect = CenterRectOnPointd(DoseLevelRect, ...
                    DoseX, CenteredBar(4) - 1);
            end

            Begin = 1;
            for iSig = (2*(MaxX-1)):(2*Scale):length(NewNoise_Line)
            
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
            
                % draw graph text labels
                Screen('DrawTextures', Window, ...
                    [NeuroTexture DoseTexture], [], ...
                    [NeuroLoc' DoseLoc'], ...
                    -90);
            
                % draw dose number labels
                Screen('DrawText', Window, ...
                    '100', CenteredBar(1) - 57, RefY - 6, Black);
                Screen('DrawText', Window, ...
                    '0', CenteredBar(1) - 19, RefY + 731);
                
                % draw feedback and dose rects
                Screen('FillRect', Window, ...
                [0 0 0; 0 0 0; 1 0 0 ; 0.5 0.5 1]', ... 
                [CenteredFeedback' CenteredBar' PerDoseRect' DoseLevelRect']);
            
                % draw feedback line
                Screen('DrawLines', Window, ...
                    [NewX_Line NewXRange(1) NewXRange(2); ...
                    NewNoise_Line(Begin:iSig) sum(NewYRange)/2 sum(NewYRange)/2], ...
                    5, [repmat([1 0 0]', 1, iSig-Begin+1) [1 1 1; 1 1 1]']);
            
                % frame for testing purposes
                % Screen('FrameRect', Window, Black, CenteredFrame);
            
                % do flip here
                if Begin == 1
                    vbl = Screen('Flip', Window, vbl + RunDesign{k, JITTER1DUR} - Refresh);
                    RunDesign{k, FEEDONSET} = vbl - BeginTime;
                else
                    % can try no duration here to see what happens
                    % but will need duration if I plan to show signal everyth nth frame
                    % with n > 1, so might as well keep it for now
                    vbl = Screen('Flip', Window, vbl + (WaitFrames - 0.5)*Refresh);
                    % vbl = Screen('Flip', Window);
                end
           
                if strcmp(RunDesign{k, ANTICIPATION}, 'Infusion')
                    PerDoseRect(2) = PerDoseRect(2) - Increment;
                end
                Begin = Begin + 2 * Scale;
            end
            clear iSig
            PerDoseRect(2) = OrigPerDoseY;
        
            %%% JITTER2 %%%
            Screen('FillRect', Window, Black);
            vbl = Screen('Flip', Window);
            RunDesign{k, J2ONSET} = vbl - BeginTime;
            Until = vbl + RunDesign{k, JITTER2DUR} - Refresh;
            Screen('FillRect', Window, Grey);
        end
        WaitSecs('UntilTime', Until);
        % now write out run design
        save(OutMat, 'RunDesign');
        OutFid = fopen(OutCsv, 'w');
        fprintf(OutFid, ...
            ['Participant,', ...
            'Run,', ...
            'TrialNum,', ...
            'Anticipation,', ...
            'Feedback,', ...
            'Jitter1Dur,', ...
            'Jitter2Dur,', ...
            'AntOnset,', ...
            'J1Onset,', ...
            'FeedOnset,', ...
            'J2Onset,', ...
            'AntResponse,', ...
            'AntRt\n']);
        for DesignIdx = 1:size(RunDesign, 1)
            fprintf(OutFid, '%s,', Participant);
            fprintf(OutFid, '%d,', i);
            fprintf(OutFid, '%d,', RunDesign{DesignIdx, TRIALNUM});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, ANTICIPATION});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, FEEDBACK});
            fprintf(OutFid, '%0.1f,', RunDesign{DesignIdx, JITTER1DUR});
            fprintf(OutFid, '%0.1f,', RunDesign{DesignIdx, JITTER2DUR});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, ANTONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, J1ONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, FEEDONSET});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, J2ONSET});
        
            % handle resposne now
            Response = RunDesign{DesignIdx, ANTRESPONSE};
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
            fprintf(OutFid, '%0.4f\n', RunDesign{DesignIdx, ANTRT});
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
