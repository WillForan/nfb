function SocialCognitionTask(varargin)
% function SogcialCognitionTask([Scan], [Participant], [Run1], [Run2],
%   [Testing], [Version])

try
    sca;
    DeviceIndex = [];

    if empty(varargin)
        Responses = inputdlg({'Scan (1:Yes, 0:No):', ...
            'Participant ID:', ...
            'Run1: 1 - 5:', ...
            'Run2: 1 - 5:', ...
            'Testing: (1:Yes, 0:No)'});
        InScan = str2double(Responses{1});
        Participant = Responses{2};
        Runs = [str2double(Responses{3}) str2double(Responses{4})];
        Testing = str2double(Responses{5});
    elseif numel(varargin) == 5
        InScan = varargin{1};
        Participant = varargin{2};
        Runs = [varargin{3} varargin{4}];
        Testing = varargin{5};
    else
        error('Invalid number of arguments.');
    end

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
        DesignFile = fullfile(pwd, 'ScDebu', 'Development', 'ScDesign.csv');
    end
    DesignFid = fopen(DesignFile, 'r');
    Tmp = textscan(DesignFid, '%f%f%f%f%s%f%s%s%s%s%s%s%s', ...
        'Delimiter', ',', 'Headerlines', 1);
    fclose(DesignFid);
    % more columns: FaceOnset,FaceResponse,FaceRT,ContextOnset
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
    BLOCK = 2;
    TRIAL = 3;
    BLOCKSPLIT = 4;
    CONDITION = 5;
    FACENUM = 6;
    FACEGENDER = 7;
    FACEEXPRESSION = 8;
    FACEFILENAME = 9;
    FACERACE = 10;
    CONTEXTCATEGORY = 11;
    CONTEXTSUBCATEGORY = 12;
    CONTEXTFILENAME = 13;
    FACEONSET = 14;
    FACERESPONSE = 15;
    FACERT = 16;
    CONTEXTONSET = 17;
    
    PsychDefaultSetup(2); % default settings
    Screen('Preference', 'VisualDebugLevel', 1); % skip introduction Screen
    if ~Suppress
        Screen('Preference', 'SuppressAllWarnings', 1);
        Screen('Preference', 'Verbosity', 0);
    end
    Screens = Screen('Screens'); % get scren number
    ScreenNumber = max(Screens);
    
    % Define black and white
    White = [1 1 1];
    Black = [0 0 0];
    Grey = White * 0.5;
    
    % we want X = Left-Right, Y = top-bottom
    [Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, Black); % open Window on Screen
    PriorityLevel = MaxPriority(Window);
    Priority(PriorityLevel);
    [XCenter, YCenter] = RectCenter(Rect); % get the center of the coordinate Window
    Refresh = Screen('GetFlipInterval', Window);
    
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', Window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % set up keyboard
    KbName('UnifyKeyNames');
    KbNames = KbName('KeyNames');
    KeyNamesOfInterest = {'1!', '2@', '3#', '4$', '5%', ...
        '6^', '7&', '8*', '9(', '0)', ...
        '1', '2', '3', '4', '5', ...
        '6', '7', '8', '9', '0'};
    % KeyNamesOfInterest = { '1', '2', '3', '4', '5', ...
    %     '6', '7', '8', '9', '0'};
    KeysOfInterest = zeros(1, 256);
    for i = 1:numel(KeyNamesOfInterest)
        KeysOfInterest(KbName(KeyNamesOfInterest{i})) = 1;
    end
    clear i
    KbQueueCreate(DeviceIndex, KeysOfInterest);
    
    % set default text type for window
    Screen('TextFont', Window, 'Arial');
    Screen('TextSize', Window, 50);
    Screen('TextColor', Window, White);

    % preload images and assign values for bar and text location
    PictureY = 0;
    fprintf(1, 'Preloading images. This will take some time.\n');
    for iRun = 1:2
        RunIdx = [Design{:, RUN}]' == iRun;
        RunDesign = Design(RunIdx, :);
        for iTrial = 1:size(RunDesign, 1)
            Context = fullfile(pwd, 'Contextual', RunDesign{iTrial, CONTEXTCATEGORY}, ...
                RunDesign{iTrial, CONTEXTSUBCATEGORY}, RunDesign{iTrial, CONTEXTFILENAME});
            Face = fullfile(pwd, 'Faces', RunDesign{iTrial, FACEGENDER}, ...
                RunDesign{iTrial, FACEFILENAME});

            TmpContext = imread(Context, 'jpg');
            TmpFace = imread(Face, 'png');

            if size(TmpFace, 1) > PictureY
                PictureY = size(TmpFace, 1);
            end

            TexContext{iRun}{iTrial} = Screen('MakeTexture', Window, TmpContext);
            TexFace{iRun}{iTrial} = Screen('MakeTexture', Window, TmpFace);
        end
    end
    clear iRun iTrial

    PictureX = 256;
    ImBotLoc = floor(PictureY/2) + YCenter;
    ImRightLoc = floor(PictureX/2) + XCenter;
    ImLeftLoc = XCenter - ceil(PictureX/2);
    FromXBar = ImLeftLoc - 90;
    FromYBar = ImBotLoc + 15;
    ToXBar = ImRightLoc + 90;
    ToYBar = FromYBar;

    % run the experiment
    for i = StartRun:EndRun
        RunIdx = [Design{:, RUN}]' == i;
        RunDesign = Design(RunIdx, :);

        % pre-populate RT and Response with NaN
        for k = 1:size(RunDesign)
            RunDesign{k, FACERESPONSE} = nan;
            RunDesign{k, FACERT} = nan;
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
    
        Stop = 0; 
        for k = 1:size(RunDesign, 1)
            % Tex = Screen('MakeTexture', Window, ImContext{i}{k});
            Screen('DrawTexture', Window, TexContext{i}{k});
            ContextVbl = Screen('Flip', Window, Stop);
            if k == 1
                BeginTime = ContextVbl;
            end
            RunDesign{k, CONTEXTONSET} = ContextVbl - BeginTime;

            % Tex = Screen('MakeTexture', Window, ImFace{i}{k});
            Screen('DrawTexture', Window, TexFace{i}{k});
            CondVbl = Screen('Flip', Window, ContextVbl + 2 - Refresh * 0.5, 1);
            RunDesign{k, FACEONSET} = CondVbl - BeginTime;

            % [PictureY, PictureX] = size(ImFace{i}{k});
            Screen('FillRect', Window, [0 0 0.5], ...
                [FromXBar FromYBar ToXBar (ToYBar + 15)]);
            Screen('DrawText', Window, 'Negative', FromXBar - 203, FromYBar - 15); 
            Screen('DrawText', Window, 'Positive', ToXBar + 3, FromYBar - 15); 
            BarVbl = Screen('Flip', Window, CondVbl + 1 - Refresh * 0.5);
            % Screen('Close', Tex);

            KbQueueStart(DeviceIndex);
            Stop = BarVbl + 4 - Refresh * 0.5;
            while GetSecs < Stop
                [Pressed, FirstPress] = KbQueueCheck(DeviceIndex);
                if Pressed
                    FirstPress(FirstPress == 0) = nan;
                    [RT, Idx] = min(FirstPress);
                    RunDesign{k, FACERESPONSE} = KbNames{Idx};
                    RunDesign{k, FACERT} = RT - BarVbl;
                    break;
                end
                WaitSecs(0.01);
            end
            KbQueueStop(DeviceIndex);
            KbQueueFlush(DeviceIndex);
            fprintf(1, 'Run: %d, Trial: %d, RT: %0.4f, Response: %s\n', ...
                i, k, RunDesign{k, FACERT}, RunDesign{k, FACERESPONSE});
        end
        WaitSecs('UntilTime', Stop);
    
        % now write out run design
        save(OutMat, 'RunDesign');
        OutFid = fopen(OutCsv, 'w');
        fprintf(OutFid, ...
            ['Participant,', ...
            'Run,', ...
            'BlockNum,', ...
            'TrialNum,', ...
            'BlockSplit,', ...
            'Condition,', ...
            'FaceNum,', ...
            'FaceGender,', ...
            'FaceExpression,', ...
            'FaceFileName,', ...
            'FaceRace,', ...
            'ContextCategory,', ...
            'ContextSubCategory,', ...
            'ContextFileName,', ...
            'FaceOnset,', ...
            'FaceResponse,', ...
            'FaceRt,', ...
            'ContextOnset\n']);
        for DesignIdx = 1:size(RunDesign, 1)
            fprintf(OutFid, '%s,', Participant);
            fprintf(OutFid, '%d,', i);
            fprintf(OutFid, '%d,', RunDesign{DesignIdx, BLOCK});
            fprintf(OutFid, '%d,', RunDesign{DesignIdx, TRIAL});
            fprintf(OutFid, '%d,', RunDesign{DesignIdx, BLOCKSPLIT});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, CONDITION});
            fprintf(OutFid, '%d,', RunDesign{DesignIdx, FACENUM});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, FACEGENDER});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, FACEEXPRESSION});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, FACEFILENAME});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, FACERACE});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, CONTEXTCATEGORY});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, CONTEXTSUBCATEGORY});
            fprintf(OutFid, '%s,', RunDesign{DesignIdx, CONTEXTFILENAME});
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, FACEONSET});
    
            % handle resposne now
            Response = RunDesign{DesignIdx, FACERESPONSE};
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
    
            fprintf(OutFid, '%0.4f,', RunDesign{DesignIdx, FACERT});
            fprintf(OutFid, '%0.4f\n', RunDesign{DesignIdx, CONTEXTONSET});
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
end

