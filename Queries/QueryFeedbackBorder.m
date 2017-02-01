clear all;

try
    % setup up diary
    OutDir = fullfile(pwd, 'QueryScanner');
    mkdir(OutDir);
    OutFile = fullfile(OutDir, 'QueryFeedback.txt');
    if exist(OutFile, 'file') == 2
        delete(OutFile);
    end
    diary(OutFile);
    
    % change preferences
    % Screen('Preference', 'SkipSyncTests', 2);
    Screen('Preference', 'VisualDebugLevel', 3);
    
    % screen initialization and refresh
    Screens = Screen('Screens'); % get scren number
    ScreenNumber = max(Screens);
    [Window, Rect] = Screen('OpenWindow', ScreenNumber);
    Screen('ColorRange', Window, 1, [], 1);
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect);
    [Refresh] = Screen('GetFlipInterval', Window);
    
    % blend
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Define commonly used colors
    White = [1 1 1];
    Black = [0 0 0];
    Gray = White * 0.5;
    BgColor = [45 59 55] * 1/255;
    UnfilledColor = [38 41 26] * 1/255;
    BoxColor = [21 32 17] * 1/255;
    FilledColor = [41 249 64] * 1/255;
    Screen('FillRect', Window, BgColor);
    
    %%% FEEDBACK SETUP %%%
    % Feedback rect location; this is used as position reference for most
    % other drawn objects
    FName = fullfile(pwd, '../', 'NfbImages', 'FeedNumImages', 'Feedback.png');
    Im = imread(FName, 'png');
    FeedbackTexture = Screen('MakeTexture', Window, Im);

    % create feedback rect for signal drawing
    FeedbackRect = [0 0 923 750];
    OrigFeedbackRect = [0 0 920 750];
    FeedbackXCenter = 50.5 + XCenter;
    OrigFeedXCenter = 52 + XCenter;
    CenteredFeedback = CenterRectOnPointd(FeedbackRect, FeedbackXCenter, YCenter);
    CenteredOrigFeed = CenterRectOnPointd(OrigFeedbackRect, OrigFeedXCenter, YCenter);

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
    FileName = fullfile(pwd, '../', 'NfbDebug', 'Development', 'Waveforms.mat');
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
    
    % set up keys of interest
    KbName('UnifyKeyNames');
    KbNames = KbName('KeyNames');
    EscapeKey = KbName('ESCAPE');
    TabKey = KbName('tab');
    LeftArrowKey = KbName('LeftArrow');
    RightArrowKey = KbName('RightArrow');
    PlusKey = KbName('=+');
    MinusKey = KbName('-_');
    
    % initialize bookkeeping variables
    WaveformStage = 1;
    Position = 1;
    StageBegin = 1;
    StageEnd = (2*(MaxX-1));
    Mode = 'Continuous';
    Waveforms = LineSignals{1}(1, :); % 3 stages
    Stage = 1;
    Flip = 0;
    BorderSize = 1;
    NumStages = numel(Waveforms);
    
    % get number of screens for each stage
    SignalScreens = zeros(numel(LineSignals), 1);
    for i = 1:numel(Waveforms)
        OffScreen = length(Waveforms{i}) - 2*(MaxX-1);
        SignalScreens(i) = floor((OffScreen - ...
            mod(OffScreen, 2*Scale))/(2*Scale)) + 1;
    end
    clear i
    
    % prepare for display
    HideCursor;
    % ListenChar(-1);
    
    % initialize screen display
    Screen('DrawTexture', Window, FeedbackTexture);
    Screen('DrawLines', Window, ...
        [NewX_Line CenteredFeedback(1) CenteredFeedback(3); ...
        Waveforms{Stage}(StageBegin:StageEnd) sum(NewYRange)/2 sum(NewYRange)/2], ...
        [repmat(4, (StageEnd - StageBegin + 1)/2, 1); 1], ...
        [repmat([1 0 0]', 1, StageEnd-StageBegin+1) [1 1 1;1 1 1]']);
    % Screen('FrameRect', Window, White, CenteredFeedback);
    Screen('FrameRect', Window, White, Rect, BorderSize);
    DrawFormattedText(Window, ...
        [sprintf('Position:   %d\n', Position), ...
         sprintf('Stage:      %d\n', Stage), ...
         sprintf('StageBegin: %d\n', StageBegin), ...
         sprintf('StageEnd:   %d\n', StageEnd), ...
         sprintf('BorderSize: %d\n\n', BorderSize), ...
         sprintf('Move signal with left/right arrow keys\n'), ...
         sprintf('Increase/decrease border size: =+/-_\n'), ...
         sprintf('Mode %s (change with TAB)\n', Mode), ...
         sprintf('Quit with ESC\n')], [], [], FilledColor);
    Screen('Flip', Window);
    
    while 1
        [Pressed, Secs, KeyCode] = KbCheck;
        if Pressed
            if KeyCode(EscapeKey)
                break;
            elseif KeyCode(TabKey)
                if strcmp(Mode, 'Continuous')
                    Mode = 'Discrete';
                else
                    Mode = 'Continuous';
                end
                KbReleaseWait;
                Flip = 1;
            elseif KeyCode(LeftArrowKey)
                if Position > 1
                    Position = Position - 1;
                    
                    if StageBegin == 1
                        Stage = Stage - 1;
                        SignalLength = length(Waveforms{Stage});
                        StageEnd = SignalLength - ...
                            mod(SignalLength - 2*(MaxX-1), 2*Scale);
                        StageBegin = StageEnd - 2 * (MaxX - 1) + 1;
                    else
                        StageBegin = StageBegin - 2 * Scale ;
                        StageEnd = StageEnd - 2 * Scale;
                    end
                    Flip = 1;
                    
                    if strcmp(Mode, 'Discrete')
                        KbReleaseWait;
                    end
                end
            elseif KeyCode(RightArrowKey)
                if Position < sum(SignalScreens)
                    Position = Position + 1;
                    
                    if Position > sum(SignalScreens(1:Stage))
                        StageBegin = 1;
                        StageEnd = 2*(MaxX-1);
                        Stage = Stage + 1;
                    else
                        StageBegin = StageBegin + 2 * Scale;
                        StageEnd = StageEnd + 2 * Scale;
                    end
                    Flip = 1;
                end
                
                if strcmp(Mode, 'Discrete')
                    KbReleaseWait;
                end
            elseif KeyCode(PlusKey)
                BorderSize = BorderSize + 1;
                Flip = 1;
                if strcmp(Mode, 'Discrete')
                    KbReleaseWait;
                end
            elseif KeyCode(MinusKey) &&  BorderSize > 1
                BorderSize = BorderSize - 1;
                Flip = 1;
                if strcmp(Mode, 'Discrete')
                    KbReleaseWait;
                end
            end
            
            if Flip
                Screen('DrawTexture', Window, FeedbackTexture);

                
                % draw feedback line
                Screen('DrawLines', Window, ...
                    [NewX_Line CenteredFeedback(1) CenteredFeedback(3); ...
                    Waveforms{Stage}(StageBegin:StageEnd) sum(NewYRange)/2 sum(NewYRange)/2], ...
                    [repmat(4, (StageEnd - StageBegin + 1)/2, 1); 1], ...
                    [repmat([1 0 0]', 1, StageEnd-StageBegin+1) [1 1 1; 1 1 1]']);
                % Screen('FrameRect', Window, White, CenteredFeedback);
                Screen('FrameRect', Window, White, Rect, BorderSize);
                DrawFormattedText(Window, ...
                    [sprintf('Position:   %d\n', Position), ...
                     sprintf('Stage:      %d\n', Stage), ...
                     sprintf('StageBegin: %d\n', StageBegin), ...
                     sprintf('StageEnd:   %d\n', StageEnd), ...
                     sprintf('BorderSize: %d\n\n', BorderSize), ...
                     sprintf('Move signal with left/right arrow keys\n'), ...
                     sprintf('Increase/decrease border size: =+/-_\n'), ...
                     sprintf('Mode %s (change with TAB)\n', Mode), ...
                     sprintf('Quit with ESC\n')], [], [], FilledColor);
                Screen('Flip', Window);
                Flip = 0;
            end
        end
    end

    sca;
    ShowCursor;
    ListenChar(0);
    Priority(0);
    diary off
catch err
    sca;
    ShowCursor;
    ListenChar(0);
    Priority(0);
    fprintf(1, '%s\n', err.message);
    diary off
    rethrow(err);
end

