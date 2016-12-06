function MakeMovies(fps, density, MovieFlag)
% funciton MakeMovie(fps, density)
%
%   INPUT
%       fps     - scalar, frames per second used to record
%       density - scalar, plot density

    Main3(fps, density, MovieFlag);
    % NewMain(fps, density, MovieFlag);
    % Experiment(fps, density, MovieFlag);
    % TrainingMain(fps, density, MovieFlag);

end

function Run_InitialScreen(Feedback, Dose, Signal, ...
                           fps, PlotSeconds, density, ...
                           AviObj, MovieFlag)

    MaxX = (fps * PlotSeconds * density) - 1;
    set(Feedback, 'visible', 'on');
    set(Dose, 'visible', 'on');

    % initialize SignalPlot, so x axis displays over it
    SignalPlot = plot(Feedback, MaxX+1, Signal(1), 'r',...
                                'linewidth', 2);

    % plot x axis which is just a white line
    tmp = plot(Feedback, 0:MaxX, zeros(1, MaxX+1), 'w-', ...
                         'linewidth', 2);

    Counter = 0;
    if MovieFlag ~= 0
        writeVideo(AviObj, getframe(gcf));
    end

    for i = 1:(MaxX + 1)
        % update signal
        set(SignalPlot, 'XData', (MaxX-i+1):MaxX, 'YData', Signal(1:i));
        % write movies
        if MovieFlag ~= 0 && mod(Counter, density) == 0
            writeVideo(AviObj, getframe(gcf));
        elseif mod(Counter, density) == 0
            pause(1/fps);
        end
        Counter = Counter + 1;
    end

    if length(Signal) > MaxX
        for i = 2:(length(Signal)-MaxX)
            % update signal
            set(SignalPlot, 'YData', Signal(i:(i+MaxX)));

            % write movies
            if MovieFlag ~= 0 && mod(Counter, density) == 0
                writeVideo(AviObj, getframe(gcf));
            elseif mod(Counter, density) == 0
                pause(1/fps);
            end
            Counter = Counter + 1;
        end
    end

    cla(Feedback);
    set(Feedback, 'visible', 'off');
end

function [InfusionType Counter Expectations] = Init_AnticipationScreen()

    InfusionType = uicontrol('style', 'text', ...
                             'units', 'normalized', ...
                             'position', [0.03 0.817 0.948 0.098], ...
                             'foregroundcolor', 'green', ...
                             'fontsize', 40, ...
                             'fontweight', 'bold', ...
                             'backgroundcolor', [0.0 0.0 0.0], ...
                             'visible', 'off');

    Counter = uicontrol('style', 'text', ...
                        'units', 'normalized', ...
                        'position', [0.202 0.422 0.622 0.243], ...
                        'foregroundcolor', 'red', ...
                        'fontsize', 100, ...
                        'fontweight', 'bold', ...
                        'backgroundcolor', [0.0 0.0 0.0], ...
                        'visible', 'off');

    Expectations = uicontrol('style', 'text', ...
                             'string', 'Rate your expected change in mood', ...
                             'units', 'normalized', ...
                             'position', [0 0.13 1 0.202], ...
                             'foregroundcolor', 'white', ...
                             'fontsize', 40, ...
                             'fontweight', 'bold', ...
                             'backgroundcolor', [0.0 0.0 0.0], ....
                             'visible', 'off');
end

function Run_AnticipationScreen(InfusionType, Counter, Expectations, ...
                                fps, seconds, InfusionLabel, AviObj, MovieFlag)
% function Run_AnticipationScreen(InfusionType, Counter, Expecations, fps, seconds)
%
%   INPUT
%       InfusionType     - handle to InfusionType graphics
%       Counter          - handle to Counter graphics
%       Expectations     - handle to Expectations graphics
%       fps              - frames per seconds
%       seconds          - total seconds anticipation screen is displayed

    if InfusionLabel == 1
        InfusionString = 'NEXT INFUSION';
        set(Counter, 'foregroundcolor', 'red');
    elseif InfusionLabel == 2
        InfusionString = 'NEXT NO INFUSION';
        set(Counter, 'foregroundcolor', 'white');
    else
        error('Invalid InfusionLabel %d\n', InfusionLabel);
    end

    SecondsDisp = sprintf('00:%02d', seconds);

    set(InfusionType, 'visible', 'on', ...
                      'string', InfusionString);
    set(Counter, 'visible', 'on', ...
                 'string', SecondsDisp);

    ExpecVisible = false;

    for i = 1:seconds
        for k = 1:fps
            if MovieFlag
                writeVideo(AviObj, getframe(gcf));
            else
                pause(1/fps);
            end
        end

        % handle question visibility
        if ~ExpecVisible && seconds - i <= 4
            set(Expectations, 'visible', 'on');
            ExpecVisible = true;
        end

        % handle timer
        SecondsDisp = sprintf('00:%02d', seconds - i);
        set(Counter, 'string', SecondsDisp);
    end

    set(InfusionType, 'visible', 'off');
    set(Counter, 'visible', 'off');
    set(Expectations, 'visible', 'off');
end

function [Dose Feedback] = Init_FeedbackScreen(fps, PlotSeconds, density)
% This initiation creates a feedback screen with the dose bar and feedback plot.

    MaxX = (fps * PlotSeconds * density) - 1;

    % set up dose administered
    Dose = axes('position', [0.1 0.135 0.032 0.752], ...
                'YLim', [0 100], ...
                'YTick', [0 100], ...
                'FontSize', 16, ...
                'xtick', [], ...
                'color', [0 0 0], ...
                'visible', 'off');
    yDose = ylabel(Dose, '% dose administered', ...
                         'fontsize', 20, ...
                         'fontname', 'arial');
    CurYPos = get(yDose, 'Position');
    set(yDose, 'Position', [-1.25 CurYPos(2) CurYPos(3)]);
    hold;

    % set up feed back plot    
    Feedback = axes('position', [0.232 0.135 0.752 0.752], ...
                    'YLim', [-100 100], ...
                    'XLim', [0 MaxX], ...
                    'YTick', [-100 -50 0 50 100], ...
                    'FontSize', 16, ...
                    'xtick', [], ...
                    'color', [0 0 0], ...
                    'visible', 'off');
    yFeedBack = ylabel(Feedback, 'Neurofeedback Signal', ...
                                 'fontsize', 20, ...
                                 'fontname', 'arial');
    CurYPos = get(yFeedBack, 'Position');
    set(yFeedBack, 'Position', [-10 CurYPos(2) CurYPos(3)]);
    % -6.5
    hold;
end

function [Feedback] = Init_FeedbackScreen2(fps, PlotSeconds, density)
% This initiation creates a feedback screen with the feedback plot only.
    MaxX = (fps * PlotSeconds * density) - 1;

    % set up feed back plot    
    % position [0.08 0.035 0.84 0.93]
    Feedback = axes('position', [0.102 0.035 0.84 0.93], ...
                    'YLim', [-100 100], ...
                    'XLim', [0 MaxX], ...
                    'YTick', [-100 -50 0 50 100], ...
                    'FontSize', 16, ...
                    'xtick', [], ...
                    'color', [0 0 0], ...
                    'visible', 'off');
    yFeedBack = ylabel(Feedback, 'Neurofeedback Signal', ...
                                 'fontsize', 20, ...
                                 'fontname', 'arial');
    CurYPos = get(yFeedBack, 'Position');
    set(yFeedBack, 'Position', [-6.5 CurYPos(2) CurYPos(3)]);
    % -6.5
    hold;
end

function Run_FeedbackScreen(Dose, Feedback, ...
                            fps, PlotSeconds, density, ...
                            InfusionLabel, Signal, MaxDose, TotalDur, FeedbackDur, ...
                            AviObj, MovieFlag)
% function Run_FeedbackScreen(Dose, Feedback, fps, PlotSeconds, density)
%   INPUT
%       Dose        - handle to Dose graphics
%       Feedback    - handle to Feedback graphics
%       fps         - frames per second
%       PlotSeconds - number of seconds for one point to scroll from beginning to end of screen
%       density     - density of plot (unused right now)
%
% This function requires Init_FeedbackScreen to be run first. In this version, the dose bar moves
% for a subset time of the full feedback time. Text appears at the very begininng indicating
% what type of infusion is being administered. Text appears at the end of the infusion time
% prompting the end of infusion type. After the subset of time, text appears on the feedback
% plot telling the subject to rate their improvement. During this time, the signal is being
% displayed near baseline.

    % handle InfusionLabel
    if InfusionLabel == 1
        InfusionType = '   INFUSION';
    elseif InfusionLabel == 2
        InfusionType = 'NO INFUSION';
    else
        error('Invalid InfusionLabel %d\n', InfusionLabel);
    end

    MaxX = (fps * PlotSeconds * density) - 1;
    set(Dose, 'visible', 'on');
    set(Feedback, 'visible', 'on');
    fprintf(1, '%s\n', InfusionType);
    InfusionText = text(0.025*MaxX, 90, sprintf('%s', InfusionType), ...
                                        'FontSize', 20, ...
                                        'FontName', 'Helvetica', ...
                                        'color', 'green');

    % plot dose bar
    DoseBar = plot(Dose, [0 1], [MaxDose MaxDose], ...
                   'Color', [0 191/255 1], ...
                   'Linewidth', 8);
    DoseAreaY = [0 0];
    DoseArea = area(Dose, [0 1], DoseAreaY, 'FaceColor', 'red');

    % now plot signal
    SignalPlot = plot(Feedback, 0:MaxX, Signal(1:MaxX+1), 'r',...
                                'linewidth', 2);

    % plot x axis which is just a white line
    tmp = plot(Feedback, 0:MaxX, zeros(1, MaxX+1), 'w-', ...
                         'linewidth', 2);

    Counter = 0;
    DoseFlag = true;
    InfuseTextFlag = true;
    RateFlag = true;
    if InfusionLabel == 1 || InfusionLabel == 2
        EndInfuseTextFlag = true;
    elseif InfusionLabel == 3
        EndInfuseTextFlag = false;
    end

    if MovieFlag ~= 0
        writeVideo(AviObj, getframe(gcf));
    end
    fprintf('%s\n', get(InfusionText, 'visible'));

    for i = 2:(length(Signal)-MaxX)
        % update signal
        set(SignalPlot, 'YData', Signal(i:(i+MaxX)));

        % flash infusion text; create 3 complete flashes
        if InfuseTextFlag && i < 3*fps*density
            if mod(i, 1/8*fps*density) == 0 
                if strcmp(get(InfusionText, 'visible'), 'on')
                    set(InfusionText, 'visible', 'off');
                else
                    set(InfusionText, 'visible', 'on');
                end
            end
        elseif InfuseTextFlag
            set(InfusionText, 'visible', 'off');
            if InfusionLabel == 1 
                set(InfusionText, 'string', 'STOP    INFUSION');
            elseif InfusionLabel == 2
                set(InfusionText, 'string', 'STOP NO INFUSION');
            elseif InfusionLabel == 3
                set(InfusionText, 'string', 'Rate improvement');
            end
            InfuseTextFlag = false;
        end

        % handle dose bar
        if DoseFlag && DoseAreaY(1) <= MaxDose
            DoseAreaY = DoseAreaY + (1/(fps*FeedbackDur*density))*MaxDose;
            set(DoseArea, 'YData', DoseAreaY);
        elseif DoseFlag
            set(DoseArea, 'YData', [0 0]);
            set(DoseBar, 'YData', [0 0]);
            DoseFlag = false;
        end

        % flash end infusion text; create 3 complete flashes
        if EndInfuseTextFlag && i > FeedbackDur*fps*density && i < (FeedbackDur+3)*fps*density
            if mod(i, 1/8*fps*density) == 0
                if strcmp(get(InfusionText, 'visible'), 'on')
                    set(InfusionText, 'visible', 'off');
                else
                    set(InfusionText, 'visible', 'on');
                end
            end
        elseif EndInfuseTextFlag && i > (FeedbackDur+3)*fps*density
            set(InfusionText, 'visible', 'off', ...
                              'string', 'Rate improvement');
        end

        % handle "Rate improvement" text
        if RateFlag && i > (FeedbackDur+6)*fps*density+1 && i < (FeedbackDur+9)*fps*density
            set(InfusionText, 'color', 'white', ...
                              'visible', 'on');
        elseif RateFlag && i > (FeedbackDur+9)*fps*density
            set(InfusionText, 'visible', 'off');
            RateFlage = false;
        end

        % write movies
        if MovieFlag ~= 0 && mod(Counter, density) == 0
            writeVideo(AviObj, getframe(gcf));
        elseif mod(Counter, density) == 0
            pause(1/fps);
        end
        Counter = Counter + 1;
    end
    fprintf(1, 'Last index: %d Total Points %d\n', i+MaxX, length(Signal));

    cla(Dose); cla(Feedback);
    set(Dose, 'visible', 'off');
    set(Feedback, 'visible', 'off');
end

function [No Improvement Numbers Greatly Improved] = Init_RateScreen()

    No = uicontrol('style', 'text', ...
                   'units', 'characters', ...
                   'string', 'No', ...
                   'position', [7 21.357142 4.6667 1.642857], ...
                   'fontsize', 13, ...
                   'fontweight', 'bold', ...
                   'visible', 'off', ...
                   'backgroundcolor', [0.49 0.49 0.49]); 
    Improvement = uicontrol('style', 'text', ...
                            'units', 'characters', ...
                            'string', 'improvement', ...
                            'position', [1 19.929 19.167 1.429], ...
                            'fontsize', 13, ...
                            'fontweight', 'bold', ...
                            'visible', 'off', ...
                            'backgroundcolor', [0.49 0.49 0.49]);
    Numbers = uicontrol('style', 'text', ...
                        'units', 'characters', ...
                        'string', '1     2     3     4     5     6     7     8     9     10', ...
                        'position', [20.66667 20.42857 61.833333 1.7857142], ...
                        'fontsize', 13, ...
                        'fontweight', 'bold', ...
                        'visible', 'off', ...
                        'backgroundcolor', [0.49 0.49 0.49]);
    Greatly = uicontrol('style', 'text', ...
                        'units', 'characters', ...
                        'string', 'Greatly', ...
                        'position', [85.167 21.357 9.8333 1.429], ...
                        'fontsize', 13, ...
                        'fontweight', 'bold', ...
                        'visible', 'off', ...
                        'backgroundcolor', [0.49 0.49 0.49]);
    Improved = uicontrol('style', 'text', ...
                         'units', 'characters', ...
                         'string', 'improved', ...
                         'position', [83.667 19.929 13.667 1.429], ...
                         'fontsize', 13, ...
                         'fontweight', 'bold', ...
                         'visible', 'off', ...
                         'backgroundcolor', [0.49 0.49 0.49]);
end
                    
function Run_RateScreen(No, Improvement, Numbers, Greatly, Improved, ...
                        fps, seconds, AviObj, MovieFlag)
    set(No, 'visible', 'on');
    set(Improvement, 'visible', 'on');
    set(Numbers, 'visible', 'on');
    set(Greatly, 'visible', 'on');
    set(Improved, 'visible', 'on');

    % record here
    for i = 1:(fps.*seconds)
        if MovieFlag ~= 0
            writeVideo(AviObj, getframe(gcf));
        else
            pause(1/fps);
        end
    end

    set(No, 'visible', 'off');
    set(Improvement, 'visible', 'off');
    set(Numbers, 'visible', 'off');
    set(Greatly, 'visible', 'off');
    set(Improved, 'visible', 'off');
end
              
function [Improvement] = Init_RateScreen2()
    Improvement = uicontrol('style', 'text', ...
                            'units', 'normalized', ...
                            'string', 'Rate your change in mood', ...
                            'position', [0.005 0.45 0.988 0.192], ...
                            'foregroundcolor', 'white', ...
                            'fontsize', 34, ...
                            'fontweight', 'bold', ...
                            'backgroundcolor', [0.0 0.0 0.0], ...
                            'visible', 'off');
end    

function Run_RateScreen2(Improvement, fps, seconds, AviObj, MovieFlag)
    set(Improvement, 'visible', 'on');
    
    % record here
    for i = 1:(fps.*seconds)
        if MovieFlag ~= 0
            writeVideo(AviObj, getframe(gcf));
        else
            pause(1/fps);
        end
    end

    set(Improvement, 'visible', 'off');
end

function [Jitter] = Init_Jitter()
    Jitter = uicontrol('style', 'text', ...
                       'units', 'characters', ...
                       'string', 'x', ...
                       'position', [43.167 18.714 13.333 10.429], ...
                       'fontsize', 100, ...
                       'backgroundcolor', [0.49 0.49 0.49], ...
                       'visible', 'off');
end

function Run_Jitter(Jitter, fps, seconds, AviObj, MovieFlag)
    set(Jitter, 'visible', 'on');
    
    % record here
    for i = 1:(fps.*seconds)
        if MovieFlag ~= 0
            writeVideo(AviObj, getframe(gcf));
        else
            pause(1/fps);
        end
    end

    set(Jitter, 'visible', 'off');
end

function [Noise HighSignal LowSignal NegSignal] = ...
           DefaultSignals(WindowTime, TotalFeedbackTime, FeedbackTime, ...
           HighAmp, LowAmp, NegAmp, fps, density)

    Frames2Seconds = fps * 2 * density;
    Frames12Seconds = fps * 12 * density;

    Noise = 5.*randn(1, fps*(TotalFeedbackTime+WindowTime)*density);

    HighSignal = [zeros(1, fps*WindowTime*density+Frames2Seconds) ...
                  (1/Frames2Seconds:1/Frames2Seconds:1)*HighAmp ...
                  HighAmp*ones(1, Frames12Seconds) ...
                  (1:-1/Frames2Seconds:0)*HighAmp ...
                  zeros(1, Frames2Seconds-1)] + Noise;


    LowSignal = [zeros(1, fps*WindowTime*density+Frames2Seconds) ...
                 (1/Frames2Seconds:1/Frames2Seconds:1)*LowAmp ...
                 LowAmp*ones(1, Frames12Seconds) ...
                 (1:-1/Frames2Seconds:0)*LowAmp ...
                 zeros(1, Frames2Seconds-1)] + Noise;
    NegSignal = [zeros(1, fps*WindowTime*density+Frames2Seconds) ...
                 (1/Frames2Seconds:1/Frames2Seconds:1)*NegAmp ...
                 NegAmp*ones(1, Frames12Seconds) ...
                 (1:-1/Frames2Seconds:0)*NegAmp ...
                 zeros(1, Frames2Seconds-1)] + Noise;
end

function [Noise HighSignal LowSignal NegSignal] = ...
           SineSignals(WindowTime, TotalFeedbackTime, FeedbackTime, ...
           HighAmp, LowAmp, NegAmp, fps, density)

    Frames2Seconds = fps * 2 * density;
    Frames3Seconds = fps * 3 * density;
    Frames12Seconds = fps * 12 * density;
    Frames10Seconds = fps * 10 * density;

    Noise = 5.*randn(1, fps*(TotalFeedbackTime+WindowTime)*density);
    x = (1/Frames3Seconds):(1/Frames3Seconds):1;
    SinWave1 = 10*sin(2*pi*(1:Frames10Seconds)*(1/(fps*density/4)));
    SinWave2 = 7.5*sin(2*pi*(1:Frames10Seconds)*(1/(fps*density*2)));

    HighSignal = [zeros(1, fps*WindowTime*density+Frames2Seconds) ...
                  fliplr((50.^(-x))*HighAmp) ...
                  HighAmp+SinWave1+SinWave2 ... % HighAmp*ones(1, Frames10Seconds) ...
                  (50.^(-x))*HighAmp ...
                  zeros(1, Frames2Seconds)] + Noise;

    LowSignal = [zeros(1, fps*WindowTime*density+Frames2Seconds) ...
                 fliplr((50.^(-x))*LowAmp) ...
                 LowAmp*ones(1, Frames10Seconds) ...
                 (50.^(-x))*LowAmp ...
                 zeros(1, Frames2Seconds)] + Noise;

    NegSignal = [zeros(1, fps*WindowTime*density+Frames2Seconds) ...
                 fliplr((50.^(-x))*-LowAmp) ...
                 NegAmp*ones(1, Frames10Seconds) ...
                 (50.^(-x))*-LowAmp ...
                 zeros(1, Frames2Seconds)] + Noise;
end

function [Noise PlusPlusSig PlusSig NegSig NegNegSig] = ...
           IncreaseSignals(WindowTime, TotalFeedbackTime, FeedbackTime, ...
           HighAmp, LowAmp, NegAmp, fps, density)

    Frames2Seconds = fps * 2 * density;
    Frames3Seconds = fps * 3 * density;
    Frames12Seconds = fps * 12 * density;
    Frames10Seconds = fps * 10 * density;
    Frames14Seconds = fps * 14 * density;
    Frames16Seconds = fps * 16 * density;
    Frames6Seconds = fps * 6 * density;
    FeedbackDur = FeedbackTime * fps * density;

    Noise = 5.*randn(1, fps*(TotalFeedbackTime+WindowTime)*density);
    x = (1/FeedbackDur):(1/FeedbackDur):1;
    SinWave1 = 10*sin(2*pi*(1:FeedbackDur)*(1/(fps*density)));
    SinWave2 = 7.5*sin(2*pi*(1:FeedbackDur)*(1/(fps*density*2)));

    SinWave3 = 10*sin(2*pi*(1:Frames3Seconds)*(1/(fps*density)));
    SinWave4 = 7.5*sin(2*pi*(1:Frames3Seconds)*(1/(fps*density*2)));

    PlusPlusSig = [zeros(1, fps*WindowTime*density) ...
                   HighAmp*x+(SinWave1+SinWave2)/2 ...
                   (1:-1/Frames3Seconds:1/Frames3Seconds)*HighAmp+(SinWave3+SinWave4)/2 ...
                   zeros(1, Frames6Seconds)] + Noise;

    PlusSig = [zeros(1, fps*WindowTime*density) ...
               LowAmp*x+(SinWave1+SinWave2)/2 ...
               (1:-1/Frames3Seconds:1/Frames3Seconds)*LowAmp+(SinWave3+SinWave4)/2 ...
               zeros(1, Frames6Seconds)] + Noise;

    NegSig = [zeros(1, fps*WindowTime*density) ...
              -LowAmp*x-(SinWave1+SinWave2)/2 ...
              (-1:1/Frames3Seconds:-1/Frames3Seconds)*LowAmp-(SinWave3+SinWave4)/2 ...
              zeros(1, Frames6Seconds)] - Noise;

    NegNegSig = [zeros(1, fps*WindowTime*density) ...
                 -HighAmp*x-(SinWave1+SinWave2)/2 ...
                (-1:1/Frames3Seconds:-1/Frames3Seconds)*HighAmp-(SinWave3+SinWave4)/2 ...
                zeros(1, Frames6Seconds)] - Noise;
end

function [Noise PlusPlusSig PlusSig NegSig NegNegSig] = ...
           SimpleIncrease(WindowTime, FeedbackTime, ...
           HighAmp, LowAmp, NegAmp, fps, density)

    Frames3Seconds = fps * 3 * density;
    Frames6Seconds = fps * 6 * density;
    FeedbackDur = FeedbackTime * fps * density;

    Noise = 5.*randn(1, fps*(FeedbackTime+3+WindowTime)*density);
    x = (1/FeedbackDur):(1/FeedbackDur):1;
    SinWave1 = 10*sin(2*pi*(1:FeedbackDur)*(1/(fps*density))); % lasts change length
    SinWave2 = 7.5*sin(2*pi*(1:FeedbackDur)*(1/(fps*density*2))); % lasts change length

    SinWave3 = 10*sin(2*pi*(1:Frames3Seconds)*(1/(fps*density)));
    SinWave4 = 7.5*sin(2*pi*(1:Frames3Seconds)*(1/(fps*density*2)));

    % singal legnth = change + 3 seconds, removed addition of noise
    PlusPlusSig = [zeros(1, fps*WindowTime*density) ...
                   HighAmp*x+(SinWave1+SinWave2)/2 ...
                   (1:-1/Frames3Seconds:1/Frames3Seconds)*HighAmp+(SinWave3+SinWave4)/2];

    PlusSig = [zeros(1, fps*WindowTime*density) ...
               LowAmp*x+(SinWave1+SinWave2)/2 ...
               (1:-1/Frames3Seconds:1/Frames3Seconds)*LowAmp+(SinWave3+SinWave4)/2];

    NegSig = [zeros(1, fps*WindowTime*density) ...
              -LowAmp*x-(SinWave1+SinWave2)/2 ...
              (-1:1/Frames3Seconds:-1/Frames3Seconds)*LowAmp-(SinWave3+SinWave4)/2];

    NegNegSig = [zeros(1, fps*WindowTime*density) ...
                 -HighAmp*x-(SinWave1+SinWave2)/2 ...
                (-1:1/Frames3Seconds:-1/Frames3Seconds)*HighAmp-(SinWave3+SinWave4)/2];
end

function [Noise PlusPlusSig PlusSig NegSig NegNegSig] = ...
           SimpleDelayIncrease(WindowTime, FeedbackTime, ...
           HighAmp, LowAmp, NegAmp, fps, density)

    MoreBase = 1;
    Frames3Seconds = fps * 3 * density;
    Frames6Seconds = fps * 6 * density;

    FeedbackTime = FeedbackTime - MoreBase;
    FeedbackDur = FeedbackTime * fps * density;

    Noise = 5.*randn(1, fps*(FeedbackTime+3+WindowTime)*density);
    x = (1/FeedbackDur):(1/FeedbackDur):1;
    SinWave1 = 10*sin(2*pi*(1:FeedbackDur)*(1/(fps*density))); % lasts change length
    SinWave2 = 7.5*sin(2*pi*(1:FeedbackDur)*(1/(fps*density*2))); % lasts change length

    SinWave3 = 10*sin(2*pi*(1:Frames3Seconds)*(1/(fps*density)));
    SinWave4 = 7.5*sin(2*pi*(1:Frames3Seconds)*(1/(fps*density*2)));

    % singal legnth = change + 3 seconds, removed addition of noise
    PlusPlusSig = [zeros(1, fps*(WindowTime+MoreBase)*density) ...
                   HighAmp*x+(SinWave1+SinWave2)/2 ...
                   (1:-1/Frames3Seconds:1/Frames3Seconds)*HighAmp+(SinWave3+SinWave4)/2];

    PlusSig = [zeros(1, fps*(WindowTime+MoreBase)*density) ...
               LowAmp*x+(SinWave1+SinWave2)/2 ...
               (1:-1/Frames3Seconds:1/Frames3Seconds)*LowAmp+(SinWave3+SinWave4)/2];

    NegSig = [zeros(1, fps*(WindowTime+MoreBase)*density) ...
              -LowAmp*x-(SinWave1+SinWave2)/2 ...
              (-1:1/Frames3Seconds:-1/Frames3Seconds)*LowAmp-(SinWave3+SinWave4)/2];

    NegNegSig = [zeros(1, fps*(WindowTime+MoreBase)*density) ...
                 -HighAmp*x-(SinWave1+SinWave2)/2 ...
                (-1:1/Frames3Seconds:-1/Frames3Seconds)*HighAmp-(SinWave3+SinWave4)/2];
end

function Run_FeedbackScreen2(Feedback, ...
                            fps, PlotSeconds, density, Signal, ...
                            AviObj, MovieFlag)
% function Run_FeedbackScreen(Dose, Feedback, fps, PlotSeconds, density)
%   INPUT
%       Feedback    - handle to Feedback graphics
%       fps         - frames per second
%       PlotSeconds - number of seconds for one point to scroll from beginning to end of screen
%       density     - density of plot (unused right now)
%
% Init_FeedbackScreen2 must be run first. In this version, their is no dose bar plot. The
% feedback screen runs only with no text prompts indicating beginning or end infusion.

    MaxX = (fps * PlotSeconds * density) - 1;
    set(Feedback, 'visible', 'on');

    % now plot signal
    SignalPlot = plot(Feedback, 0:MaxX, Signal(1:MaxX+1), 'r',...
                                'linewidth', 2);

    % plot x axis which is just a white line
    tmp = plot(Feedback, 0:MaxX, zeros(1, MaxX+1), 'w-', ...
                         'linewidth', 2);

    Counter = 0;

    if MovieFlag ~= 0
        writeVideo(AviObj, getframe(gcf));
    end

    for i = 2:(length(Signal)-MaxX)
        % update signal
        set(SignalPlot, 'YData', Signal(i:(i+MaxX)));

        % write movies
        if MovieFlag ~= 0 && mod(Counter, density) == 0
            writeVideo(AviObj, getframe(gcf));
        elseif mod(Counter, density) == 0
            pause(1/fps);
        end
        Counter = Counter + 1;
    end
    fprintf(1, 'Last index: %d Total Points %d\n', i+MaxX, length(Signal));

    cla(Feedback);
    set(Feedback, 'visible', 'off');
end

function OldMain(fps, density, MovieFlag)
    close all;
    WindowTime = 4;              % time for one point to move from beginning to end of screen
    AntTime = 10;                % time for anticipation period
    TotalFeedbackTime = 22;      % total time for all signals 
    FeedbackTime = 13;           % time from start to end infusion
    HighAmp = 85;
    LowAmp = 30;
    NegAmp = -30;
    NumRuns = 7;
    NumTrials = 12;
    InitSeconds = 10; 

    % create signals
    [Noise PlusPlusSig PlusSig NegSig NegNegSig] = ...
        IncreaseSignals(WindowTime, TotalFeedbackTime, FeedbackTime, ...
                       HighAmp, LowAmp, NegAmp, fps, density);
    BeginNoise = Noise(1:(fps*InitSeconds*density));

    % Expectation order
    % 1 = Infusion
    % 2 = No Infusion
    ExpOrder = [1 1 2 2 1 2 1 2 1 1 2 2
                2 2 1 1 2 1 2 1 2 2 1 1
                1 1 2 1 2 2 1 2 2 2 1 1
                2 2 1 2 1 1 2 1 1 1 2 2
                1 1 2 1 2 2 2 1 1 2 1 2
                2 2 1 2 1 1 1 2 2 1 2 1
                1 1 2 1 2 2 2 1 2 2 1 1];

    % Jitter order in seconds
    JitterOrder = [1 1 2 3 2 3 3 2 2 1 3 1
                   2 3 2 1 1 3 3 1 3 1 2 2
                   3 2 3 1 1 2 2 1 2 1 3 3
                   1 3 2 3 3 1 1 2 2 1 2 3
                   2 1 3 1 1 2 2 3 3 2 3 1
                   3 2 1 2 2 3 3 1 1 3 1 2
                   1 2 2 1 3 3 2 3 2 3 1 1];

    % Outcoume order
    % 1 = ++
    % 2 = +
    % 3 = -
    % 4 = --
    OutcomeOrder = [1 2 3 4 2 2 1 3 4 3 1 4
                    3 4 1 2 4 4 3 1 2 1 3 2
                    2 1 4 2 4 1 1 2 3 3 4 3
                    4 3 2 4 2 3 3 4 1 1 2 1
                    1 2 3 4 1 4 4 3 2 2 1 3
                    3 4 1 2 3 2 2 1 4 4 3 1
                    1 4 2 3 1 3 3 2 4 4 1 2];

    MainFigure = figure('position', [0 0 600 600],...
                        'color', [0.5 0.5 0.5]);

    % 1 = high infuison, 2 = low infusion, 3 = no infusion
    InfusionLabel = [1 2 3];

    % Initialize screens
    [InfusionType Counter Expectations] = Init_AnticipationScreen();
    [Dose Feedback] = Init_FeedbackScreen(fps, WindowTime, density);
    % [No Improvement Numbers Greatly Improve] = Init_RateScreen();
    % [Improvement] = Init_RateScreen2();
    % [Jitter] = Init_Jitter();

    for i = 1:NumRuns

        % Initialize avi object
        if MovieFlag ~= 0
            fname = sprintf('NewNeurofeedbackTask_Run_%02d_%s.avi', i, datestr(now, 'mmddyy'));
            AviObj = VideoWriter(fname);
            AviObj.FrameRate = fps;
            AviObj.Quality = 75;
            open(AviObj);
        else
            AviObj = [];
        end

        % Run initial screen
        set(MainFigure, 'color', [0.5 0.5 0.5]);

        for k = 1:NumTrials

            % Anticipation screen
            set(MainFigure, 'color', [0 0 0]);
            Run_AnticipationScreen(InfusionType, Counter, Expectations, ...
                                   fps, AntTime, ExpOrder(i, k), AviObj, MovieFlag);
            set(MainFigure, 'color', [0.5 0.5 0.5]);

            % Outcome screen
            %% Create full signal
            if OutcomeOrder(i, k) == 1
                TmpSignal = [PlusPlusSig 5*randn(1, fps*JitterOrder(i, k)*density)];
            elseif OutcomeOrder(i, k) == 2
                TmpSignal = [PlusSig 5*randn(1, fps*JitterOrder(i, k)*density)];
            elseif OutcomeOrder(i, k) == 3
                TmpSignal = [NegSig 5*randn(1, fps*JitterOrder(i, k)*density)];
            elseif OutcomeOrder(i, k) == 4
                TmpSignal = [NegNegSig 5*randn(1, fps*JitterOrder(i, k)*density)];
            else
                error('Invalid outcome number %d, Index: %d %d\n', OutcomOrder(i, k), i, k);
            end

            %% Get dose
            if ExpOrder(i, k) == 1
                TmpDose = 100;
            elseif ExpOrder(i, k) == 2
                TmpDose = 0;
            else
                error('Invalid expecation number %d, Index: %d %d\n', ExpOrder(i, k), i, k);
            end

            %% Now run outcome
            Run_FeedbackScreen(Dose, Feedback, ...
                               fps, WindowTime, density, ...
                               ExpOrder(i, k), TmpSignal, TmpDose, TotalFeedbackTime, ...
                               FeedbackTime, AviObj, MovieFlag);
        end

        if MovieFlag ~= 0
            close(AviObj);
        end
    end
end

function NewMain(fps, density, MovieFlag)
    close all;
    WindowTime = 4;              % time for one point to move from beginning to end of screen
    AntTime = 10;                % time for anticipation period
    FeedbackTime = 12;           % time from start to end infusion
    HighAmp = 85;
    LowAmp = 30;
    NegAmp = -30;
    NumRuns = 7;
    NumTrials = 12;
    InitSeconds = 10; 
    ImproveDur = 3;

    % create signals
    [Noise PlusPlusSig PlusSig NegSig NegNegSig] = ...
        SimpleDelayIncrease(WindowTime, FeedbackTime, ...
                       HighAmp, LowAmp, NegAmp, fps, density);
    BeginNoise = Noise(1:(fps*InitSeconds*density));


    % Expectation order
    % 1 = Infusion
    % 2 = No Infusion
    ExpOrder = [1 1 2 2 1 2 1 2 1 1 2 2
                2 2 1 1 2 1 2 1 2 2 1 1
                1 1 2 1 2 2 1 2 2 2 1 1
                2 2 1 2 1 1 2 1 1 1 2 2
                1 1 2 1 2 2 2 1 1 2 1 2
                2 2 1 2 1 1 1 2 2 1 2 1
                1 1 2 1 2 2 2 1 2 2 1 1];

    % Jitter order in seconds
    JitterOrder = [2 2 3 4 3 4 4 3 3 2 4 2
                   3 4 3 2 2 4 4 2 4 2 3 3
                   4 3 4 2 2 3 3 2 3 2 4 4
                   2 4 3 4 4 2 2 3 3 2 3 4
                   3 2 4 2 2 3 3 4 4 3 4 2
                   4 3 2 3 3 4 4 2 2 4 2 3
                   2 3 3 2 4 4 3 4 3 4 2 2];

    % create jitter noise
    JitterNoise = {5*randn(1, fps*2*density); ...
                   5*randn(1, fps*3*density); ...
                   5*randn(1, fps*4*density)};

    % Outcoume order
    % 1 = ++
    % 2 = +
    % 3 = -
    % 4 = --
    OutcomeOrder = [1 2 3 4 2 2 1 3 4 3 1 4
                    3 4 1 2 4 4 3 1 2 1 3 2
                    2 1 4 2 4 1 1 2 3 3 4 3
                    4 3 2 4 2 3 3 4 1 1 2 1
                    1 2 3 4 1 4 4 3 2 2 1 3
                    3 4 1 2 3 2 2 1 4 4 3 1
                    1 4 2 3 1 3 3 2 4 4 1 2];

    MainFigure = figure('position', [0 0 600 600],...
                        'color', [0.5 0.5 0.5]);

    % Initialize screens
    [InfusionType Counter Expectations] = Init_AnticipationScreen();
    Feedback = Init_FeedbackScreen2(fps, WindowTime, density);
    [Improvement] = Init_RateScreen2();

    for i = 1:NumRuns

        % Initialize avi object
        if MovieFlag ~= 0
            fname = sprintf('NewNeurofeedbackTask_Run_%02d_%s.avi', i, datestr(now, 'mmddyy'));
            AviObj = VideoWriter(fname);
            AviObj.FrameRate = fps;
            AviObj.Quality = 75;
            open(AviObj);
        else
            AviObj = [];
        end

        % Run initial screen
        set(MainFigure, 'color', [0.5 0.5 0.5]);
        Run_InitialScreen(Feedback, BeginNoise, ...
                          fps, WindowTime, density, ...
                          AviObj, MovieFlag);

        for k = 1:NumTrials

            % Anticipation screen
            set(MainFigure, 'color', [0 0 0]);
            Run_AnticipationScreen(InfusionType, Counter, Expectations, ...
                                   fps, AntTime, ExpOrder(i, k), AviObj, MovieFlag);
            set(MainFigure, 'color', [0.5 0.5 0.5]);

            % Outcome screen
            %% Create full signal
            if JitterOrder(i, k) == 2
                TmpJitter = JitterNoise{1};
            elseif JitterOrder(i, k) == 3
                TmpJitter = JitterNoise{2};
            elseif JitterOrder(i, k) == 4
                TmpJitter = JitterNoise{3};
            else
                error('Invalid jitter number: %d, Index %d %d\n', JitterOrder(i, k), i, k);
            end

            if OutcomeOrder(i, k) == 1
                TmpSignal = [PlusPlusSig TmpJitter];
            elseif OutcomeOrder(i, k) == 2
                TmpSignal = [PlusSig TmpJitter];
            elseif OutcomeOrder(i, k) == 3
                TmpSignal = [NegSig TmpJitter];
            elseif OutcomeOrder(i, k) == 4
                TmpSignal = [NegNegSig TmpJitter];
            else
                error('Invalid outcome number %d, Index: %d %d\n', OutcomOrder(i, k), i, k);
            end

            %% Now run outcome
            Run_FeedbackScreen2(Feedback, fps, WindowTime, density, TmpSignal, AviObj, MovieFlag);

            % Now run rate screen
            set(MainFigure, 'color', [0 0 0]);
            Run_RateScreen2(Improvement, fps, ImproveDur, AviObj, MovieFlag);
            set(MainFigure, 'color', [0.5 0.5 0.5]);
        end

        if MovieFlag ~= 0
            close(AviObj);
        end
    end
end

function Experiment(fps, density, MovieFlag)
    close all;
    WindowTime = 4;              % time for one point to move from beginning to end of screen
    AntTime = 10;                % time for anticipation period
    FeedbackTime = 12;           % time from start to end infusion
    HighAmp = 85;
    LowAmp = 30;
    NegAmp = -30;
    NumRuns = 7;
    NumTrials = 12;
    InitSeconds = 10; 
    PlotSeconds = 4;

    AviObj = VideoWriter('tmp.avi');
    AviObj.FrameRate = fps;
    AviObj.Quality = 75;
    open(AviObj);

    MainFigure = figure('position', [0 0 600 600],...
                        'color', [0.5 0.5 0.5]);

    [Noise PlusPlusSig PlusSig NegSig NegNegSig] = ...
        SimpleIncrease(WindowTime, FeedbackTime, ...
                       HighAmp, LowAmp, NegAmp, fps, density);

    Feedback = Init_FeedbackScreen2(fps, PlotSeconds, density);
    set(Feedback, 'visible', 'on');

    TmpSignal = [PlusPlusSig 5*randn(1, fps*2*density)];
    Run_FeedbackScreen2(Feedback, fps, WindowTime, density, TmpSignal, AviObj, 1);
    pause(3)
    TmpSignal = [PlusPlusSig 5*randn(1, fps*4*density)];
    Run_FeedbackScreen2(Feedback, fps, WindowTime, density, TmpSignal, AviObj, 1);
    close(AviObj);
end

function Run_FeedbackScreen3(Dose, Feedback, ...
                            fps, PlotSeconds, density, ...
                            Signal, MaxDose, TotalDur, ...
                            AviObj, MovieFlag)
% function Run_FeedbackScreen3(Dose, Feedback, fps, PlotSeconds, density)
%   INPUT
%       Dose        - handle to Dose graphics
%       Feedback    - handle to Feedback graphics
%       fps         - frames per second
%       PlotSeconds - number of seconds for one point to scroll from beginning to end of screen
%       density     - density of plot (unused right now)
%       Signal      - the whole signal that will be plotted in feedback
%       MaxDose     - controls dose level on dose bar
%       TotalDur    - number of seconds for feedback, this refers to when the signal is changing
%                     from the baseline. It ends when the signal begins to decay. This is needed
%                     for changing the dose bar level.
%       AviObj      - avi object
%       MovieFlag   - 1 = make movies, else only show on figure
%       
%
% This function requires Init_FeedbackScreen to be run first. In this version, the dose bar moves
% for a subset of the feedback duration. No text apears prompting the beginning or end of
% infusion. No rate prompt is displayed.

    MaxX = (fps * PlotSeconds * density) - 1;
    set(Dose, 'visible', 'on');
    set(Feedback, 'visible', 'on');

    % plot dose bar
    DoseBar = plot(Dose, [0 1], [MaxDose MaxDose], ...
                   'Color', [0 191/255 1], ...
                   'Linewidth', 8);
    DoseAreaY = [0 0];
    DoseArea = area(Dose, [0 1], DoseAreaY, 'FaceColor', 'red');

    % now plot signal
    SignalPlot = plot(Feedback, 0:MaxX, Signal(1:MaxX+1), 'r',...
                                'linewidth', 2);

    % plot x axis which is just a white line
    tmp = plot(Feedback, 0:MaxX, zeros(1, MaxX+1), 'w-', ...
                         'linewidth', 2);

    if MaxDose == 0
        DoseFlag = false;
    else
        DoseFlag = true;
    end

    Counter = 0;

    if MovieFlag ~= 0
        writeVideo(AviObj, getframe(gcf));
    end

    for i = 2:(length(Signal)-MaxX)
        % update signal
        set(SignalPlot, 'YData', Signal(i:(i+MaxX)));

        % handle dose bar
        if DoseFlag && DoseAreaY(1) <= MaxDose
            DoseAreaY = DoseAreaY + (1/(fps*TotalDur*density))*MaxDose;
            set(DoseArea, 'YData', DoseAreaY);
        elseif DoseFlag
            set(DoseArea, 'YData', [0 0]);
            set(DoseBar, 'YData', [0 0]);
            DoseFlag = false;
        end

        % write movies
        if MovieFlag ~= 0 && mod(Counter, density) == 0
            writeVideo(AviObj, getframe(gcf));
        elseif mod(Counter, density) == 0
            pause(1/fps);
        end
        Counter = Counter + 1;
    end
    fprintf(1, 'Last index: %d Total Points %d\n', i+MaxX, length(Signal));

    cla(Dose); cla(Feedback);
    set(Dose, 'visible', 'off');
    set(Feedback, 'visible', 'off');
end

function Main3(fps, density, MovieFlag)
    close all;
    WindowTime = 4;              % time for one point to move from beginning to end of screen
    AntTime = 10;                % time for anticipation period
    FeedbackTime = 12;           % time from start to end infusion
    HighAmp = 85;
    LowAmp = 30;
    NegAmp = -30;
    NumRuns = 7;
    NumTrials = 12;
    InitSeconds = 10; 
    ImproveDur = 4;              % time for rate screen 2
    BaselineTime = 9;            % time only for baseline signal to run

    % create signals
    [Noise PlusPlusSig PlusSig NegSig NegNegSig] = ...
        SimpleDelayIncrease(WindowTime, FeedbackTime, ...
                       HighAmp, LowAmp, NegAmp, fps, density);
    BeginNoise = Noise(1:(fps*InitSeconds*density));

    % create more varied noise
    VariedNoise = cell(4, 1);
    VariedNoise{1} = 4.5.*randn(1, fps*(FeedbackTime+3+WindowTime)*density);
    VariedNoise{2} = 5.*randn(1, fps*(FeedbackTime+3+WindowTime)*density);
    VariedNoise{3} = 5.5.*randn(1, fps*(FeedbackTime+3+WindowTime)*density);
    VariedNoise{4} = 6.*randn(1, fps*(FeedbackTime+3+WindowTime)*density);

    % Expectation order
    % 1 = Infusion
    % 2 = No Infusion
    ExpOrder = [1 1 2 2 1 2 1 2 1 1 2 2
                2 2 1 1 2 1 2 1 2 2 1 1
                1 1 2 1 2 2 1 2 2 2 1 1
                2 2 1 2 1 1 2 1 1 1 2 2
                1 1 2 1 2 2 2 1 1 2 1 2
                2 2 1 2 1 1 1 2 2 1 2 1
                1 1 2 1 2 2 2 1 2 2 1 1];

    % Jitter order in seconds
    JitterOrder = [2 2 3 4 3 4 4 3 3 2 4 2
                   3 4 3 2 2 4 4 2 4 2 3 3
                   4 3 4 2 2 3 3 2 3 2 4 4
                   2 4 3 4 4 2 2 3 3 2 3 4
                   3 2 4 2 2 3 3 4 4 3 4 2
                   4 3 2 3 3 4 4 2 2 4 2 3
                   2 3 3 2 4 4 3 4 3 4 2 2];

    % create jitter noise
    JitterNoise = {5*randn(1, fps*2*density); ...
                   5*randn(1, fps*3*density); ...
                   5*randn(1, fps*4*density)};

    % Outcoume order
    % 1 = ++
    % 2 = +
    % 3 = -
    % 4 = --
    OutcomeOrder = [1 2 3 4 2 2 1 3 4 3 1 4
                    3 4 1 2 4 4 3 1 2 1 3 2
                    2 1 4 2 4 1 1 2 3 3 4 3
                    4 3 2 4 2 3 3 4 1 1 2 1
                    1 2 3 4 1 4 4 3 2 2 1 3
                    3 4 1 2 3 2 2 1 4 4 3 1
                    1 4 2 3 1 3 3 2 4 4 1 2];

    BeginNoiseOrder = [2 3 1 2 4 1 3];

    MainFigure = figure('position', [0 0 600 600],...
                        'color', [0.5 0.5 0.5]);

    % create baseline signals
    BaselineNoise = cell(4, 1);
    BaselineNoise{1} = 5.*randn(1, fps*BaselineTime*density);
    BaselineNoise{2} = 5.*randn(1, fps*BaselineTime*density);
    BaselineNoise{3} = 5.*randn(1, fps*BaselineTime*density);
    BaselineNoise{4} = 5.*randn(1, fps*BaselineTime*density);

    BaselineNoiseOrder =  [3 2 2 4 1 2 1 4 3 4 1 3
                           4 1 4 3 2 1 1 4 3 3 2 2
                           3 4 1 4 2 4 1 3 1 3 2 2
                           1 2 4 4 2 3 2 3 1 4 1 3
                           2 4 3 2 4 1 3 1 3 2 4 1
                           1 2 1 3 2 1 4 3 4 2 4 3
                           2 1 4 4 1 2 3 3 2 3 1 4];
    
    % Initialize screens
    [InfusionType Counter Expectations] = Init_AnticipationScreen();
    [Dose Feedback] = Init_FeedbackScreen(fps, WindowTime, density);
    [Improvement] = Init_RateScreen2();

    for i = 5:5

        % Initialize avi object
        if MovieFlag ~= 0
            fname = sprintf('NewNeurofeedbackTask_Run_%02d_%s.avi', i, datestr(now, 'mmddyy'));
            AviObj = VideoWriter(fname);
            AviObj.FrameRate = fps;
            AviObj.Quality = 75;
            open(AviObj);
        else
            AviObj = [];
        end

        % Run initial screen
        set(MainFigure, 'color', [0.5 0.5 0.5]);
        BeginNoise = VariedNoise{BeginNoiseOrder(i)}(1:(fps*InitSeconds*density));
        Run_InitialScreen(Feedback, Dose, BeginNoise, ...
                          fps, WindowTime, density, ...
                          AviObj, MovieFlag);

        for k = 1:NumTrials

            % Anticipation screen
            set(MainFigure, 'color', [0 0 0]);
            Run_AnticipationScreen(InfusionType, Counter, Expectations, ...
                                   fps, AntTime, ExpOrder(i, k), AviObj, MovieFlag);
            set(MainFigure, 'color', [0.5 0.5 0.5]);

            % Outcome screen
            %% Create full signal
            if JitterOrder(i, k) == 2
                TmpJitter = JitterNoise{1};
            elseif JitterOrder(i, k) == 3
                TmpJitter = JitterNoise{2};
            elseif JitterOrder(i, k) == 4
                TmpJitter = JitterNoise{3};
            else
                error('Invalid jitter number: %d, Index %d %d\n', JitterOrder(i, k), i, k);
            end

            if OutcomeOrder(i, k) == 1
                TmpSignal = [PlusPlusSig+VariedNoise{4} TmpJitter];
            elseif OutcomeOrder(i, k) == 2
                TmpSignal = [PlusSig+VariedNoise{1} TmpJitter];
            elseif OutcomeOrder(i, k) == 3
                TmpSignal = [NegSig+VariedNoise{2} TmpJitter];
            elseif OutcomeOrder(i, k) == 4
                TmpSignal = [NegNegSig+VariedNoise{3} TmpJitter];
            else
                error('Invalid outcome number %d, Index: %d %d\n', OutcomOrder(i, k), i, k);
            end

            %% Get dose
            if ExpOrder(i, k) == 1
                TmpDose = 100;
            elseif ExpOrder(i, k) == 2
                TmpDose = 0;
            else
                error('Invalid expecation number %d, Index: %d %d\n', ExpOrder(i, k), i, k);
            end

            %% Now run outcome
            Run_FeedbackScreen3(Dose, Feedback, ...
                                fps, WindowTime, density, ...
                                TmpSignal, TmpDose, FeedbackTime, ...
                                AviObj, MovieFlag);

            % Now run rate screen
            set(MainFigure, 'color', [0 0 0]);
            Run_RateScreen2(Improvement, fps, ImproveDur, AviObj, MovieFlag);
            set(MainFigure, 'color', [0.5 0.5 0.5]);

            % now run baseline
            TmpBase = BaselineNoise{BaselineNoiseOrder(i, k)};
            if k == NumTrials
                TmpBase = TmpBase(1:end-fps*WindowTime*density);
                Run_LastSignalScreen(Dose, Feedback, ...
                                     fps, WindowTime, density, ...
                                     TmpBase, AviObj, MovieFlag);
            else
                Run_SignalScreen(Dose, Feedback, ...
                                 fps, WindowTime, density, ...
                                 TmpBase, AviObj, MovieFlag);
            end
        end

        if MovieFlag ~= 0
            close(AviObj);
        end
    end
end

function TrainingMain(fps, density, MovieFlag)
    close all;
    WindowTime = 4;              % time for one point to move from beginning to end of screen
    AntTime = 10;                % time for anticipation period
    FeedbackTime = 12;           % time from start to end infusion
    HighAmp = 85;
    LowAmp = 30;
    NegAmp = -30;
    NumRuns = 1;
    NumTrials = 8;
    InitSeconds = 10; 
    ImproveDur = 4;
    BaselineTime = 9;

    % create signals
    [Noise PlusPlusSig PlusSig NegSig NegNegSig] = ...
        SimpleIncrease(WindowTime, FeedbackTime, ...
                       HighAmp, LowAmp, NegAmp, fps, density);
    BeginNoise = Noise(1:(fps*InitSeconds*density));

    % Expectation order
    % 1 = Infusion
    % 2 = No Infusion
    ExpOrder     = [1 2 1 2 2 1 2 1];
    OutcomeOrder = [1 3 2 4 4 2 3 1];
    % Outcoume order
    % 1 = ++
    % 2 = +
    % 3 = -
    % 4 = --

    % Jitter order in seconds
    JitterOrder = [2 3 4 3 4 2 4 2];

    % create jitter noise
    JitterNoise = {5*randn(1, fps*2*density); ...
                   5*randn(1, fps*3*density); ...
                   5*randn(1, fps*4*density)};


    MainFigure = figure('position', [0 0 600 600],...
                        'color', [0.5 0.5 0.5]);

    % create baseline signals
    BaselineNoise = cell(4, 1);
    BaselineNoise{1} = 4.5.*randn(1, fps*BaselineTime*density);
    BaselineNoise{2} = 5.*randn(1, fps*BaselineTime*density);
    BaselineNoise{3} = 5.5.*randn(1, fps*BaselineTime*density);
    BaselineNoise{4} = 6.*randn(1, fps*BaselineTime*density);

    BaselineNoiseOrder =  [1 3 2 4 2 4 1 3];

    % Initialize screens
    [InfusionType Counter Expectations] = Init_AnticipationScreen();
    [Dose Feedback] = Init_FeedbackScreen(fps, WindowTime, density);
    [Improvement] = Init_RateScreen2();

    for i = 1:NumRuns

        % Initialize avi object
        if MovieFlag ~= 0
            fname = sprintf('Training_%02d_%s.avi', i, datestr(now, 'mmddyy'));
            AviObj = VideoWriter(fname);
            AviObj.FrameRate = fps;
            AviObj.Quality = 75;
            open(AviObj);
        else
            AviObj = [];
        end

        % Run initial screen
        set(MainFigure, 'color', [0.5 0.5 0.5]);
        Run_InitialScreen(Feedback, Dose, BeginNoise, ...
                          fps, WindowTime, density, ...
                          AviObj, MovieFlag);

        for k = 1:NumTrials

            % Anticipation screen
            set(MainFigure, 'color', [0 0 0]);
            Run_AnticipationScreen(InfusionType, Counter, Expectations, ...
                                   fps, AntTime, ExpOrder(i, k), AviObj, MovieFlag);
            set(MainFigure, 'color', [0.5 0.5 0.5]);

            % Outcome screen
            %% Create full signal
            if JitterOrder(i, k) == 2
                TmpJitter = JitterNoise{1};
            elseif JitterOrder(i, k) == 3
                TmpJitter = JitterNoise{2};
            elseif JitterOrder(i, k) == 4
                TmpJitter = JitterNoise{3};
            else
                error('Invalid jitter number: %d, Index %d %d\n', JitterOrder(i, k), i, k);
            end

            if OutcomeOrder(i, k) == 1
                TmpSignal = [PlusPlusSig+Noise TmpJitter];
            elseif OutcomeOrder(i, k) == 2
                TmpSignal = [PlusSig+Noise TmpJitter];
            elseif OutcomeOrder(i, k) == 3
                TmpSignal = [NegSig+Noise TmpJitter];
            elseif OutcomeOrder(i, k) == 4
                TmpSignal = [NegNegSig+Noise TmpJitter];
            else
                error('Invalid outcome number %d, Index: %d %d\n', OutcomOrder(i, k), i, k);
            end

            %% Get dose
            if ExpOrder(i, k) == 1
                TmpDose = 100;
            elseif ExpOrder(i, k) == 2
                TmpDose = 0;
            else
                error('Invalid expecation number %d, Index: %d %d\n', ExpOrder(i, k), i, k);
            end

            %% Now run outcome
            Run_FeedbackScreen3(Dose, Feedback, ...
                                fps, WindowTime, density, ...
                                TmpSignal, TmpDose, FeedbackTime, ...
                                AviObj, MovieFlag);

            % Now run rate screen
            set(MainFigure, 'color', [0 0 0]);
            Run_RateScreen2(Improvement, fps, ImproveDur, AviObj, MovieFlag);
            set(MainFigure, 'color', [0.5 0.5 0.5]);

            % now run baseline
            TmpBase = BaselineNoise{BaselineNoiseOrder(i, k)};
            Run_SignalScreen(Dose, Feedback, ...
                            fps, WindowTime, density, ...
                            TmpBase, AviObj, MovieFlag);
        end

        if MovieFlag ~= 0
            close(AviObj);
        end
    end
end

function Run_SignalScreen(Dose, Feedback, ...
                         fps, PlotSeconds, density, ...
                         Signal, AviObj, MovieFlag)
% function Run_FeedbackScreen3(Dose, Feedback, fps, PlotSeconds, density)
%   INPUT
%       Dose        - handle to Dose graphics
%       Feedback    - handle to Feedback graphics
%       fps         - frames per second
%       PlotSeconds - number of seconds for one point to scroll from beginning to end of screen
%       density     - density of plot (unused right now)
%       Signal      - the whole signal that will be plotted in feedback
%       MaxDose     - controls dose level on dose bar
%       TotalDur    - number of seconds for feedback, this refers to when the signal is changing
%                     from the baseline. It ends when the signal begins to decay. This is needed
%                     for changing the dose bar level.
%       AviObj      - avi object
%       MovieFlag   - 1 = make movies, else only show on figure
%       
%
% This function requires Init_FeedbackScreen to be run first. This function runs a baseline
% signal on the feedback screen for a set period of time.
%
    MaxX = (fps * PlotSeconds * density) - 1;
    set(Dose, 'visible', 'on');
    set(Feedback, 'visible', 'on');

    % plot dose bar
    DoseBar = plot(Dose, [0 1], [0 0], ...
                   'Color', [0 191/255 1], ...
                   'Linewidth', 8);
    DoseAreaY = [0 0];
    DoseArea = area(Dose, [0 1], DoseAreaY, 'FaceColor', 'red');

    % now plot signal
    SignalPlot = plot(Feedback, 0:MaxX, Signal(1:MaxX+1), 'r',...
                                'linewidth', 2);

    % plot x axis which is just a white line
    tmp = plot(Feedback, 0:MaxX, zeros(1, MaxX+1), 'w-', ...
                         'linewidth', 2);

    Counter = 0;

    if MovieFlag ~= 0
        writeVideo(AviObj, getframe(gcf));
    end

    for i = 2:(length(Signal)-MaxX)
        % update signal
        set(SignalPlot, 'YData', Signal(i:(i+MaxX)));

        % write movies
        if MovieFlag ~= 0 && mod(Counter, density) == 0
            writeVideo(AviObj, getframe(gcf));
        elseif mod(Counter, density) == 0
            pause(1/fps);
        end
        Counter = Counter + 1;
    end
    fprintf(1, 'Last index: %d Total Points %d\n', i+MaxX, length(Signal));

    cla(Dose); cla(Feedback);
    set(Dose, 'visible', 'off');
    set(Feedback, 'visible', 'off');
end

function Run_LastSignalScreen(Dose, Feedback, ...
                              fps, PlotSeconds, density, ...
                              Signal, AviObj, MovieFlag)
% function Run_LastSignalScreen(Dose, Feedback, fps, PlotSeconds, density, Signal, ...
%                               AviObj, MovieFlag)
%   INPUT
%       Dose        - handle to Dose graphics
%       Feedback    - handle to Feedback graphics
%       fps         - frames per second
%       PlotSeconds - number of seconds for one point to scroll from beginning to end of screen
%       density     - density of plot (unused right now)
%       Signal      - the whole signal that will be plotted in feedback
%       AviObj      - avi object
%       MovieFlag   - 1 = make movies, else only show on figure
%
% This function requires Init_FeedbackScreen to be run first. This function runs a baseline
% signal on the feedback screen for a set period of time throughout the whole screen so that
% the signal is not removed abruptly from the plot. 
% This means total plot time = signal time (sec) + window time (secs; typically 4 seconds)
%
    MaxX = (fps * PlotSeconds * density) - 1;
    set(Dose, 'visible', 'on');
    set(Feedback, 'visible', 'on');

    % plot dose bar
    DoseBar = plot(Dose, [0 1], [0 0], ...
                   'Color', [0 191/255 1], ...
                   'Linewidth', 8);
    DoseAreaY = [0 0];
    DoseArea = area(Dose, [0 1], DoseAreaY, 'FaceColor', 'red');

    % now plot signal
    SignalPlot = plot(Feedback, 0:MaxX, Signal(1:MaxX+1), 'r',...
                                'linewidth', 2);

    % plot x axis which is just a white line
    tmp = plot(Feedback, 0:MaxX, zeros(1, MaxX+1), 'w-', ...
                         'linewidth', 2);

    Counter = 0;

    if MovieFlag ~= 0
        writeVideo(AviObj, getframe(gcf));
    end

    % first show changing signal
    for i = 2:length(Signal)
        % update signal
        if i <= (length(Signal)-MaxX)
            set(SignalPlot, 'YData', Signal(i:(i+MaxX)));
        else
            set(SignalPlot, 'YData', Signal(i:end), 'XData', 0:(length(Signal(i:end))-1));
        end

        % write movies
        if MovieFlag ~= 0 && mod(Counter, density) == 0
            writeVideo(AviObj, getframe(gcf));
        elseif mod(Counter, density) == 0
            pause(1/fps);
        end
        Counter = Counter + 1;
    end
    fprintf(1, 'Last index: %d Total Points %d\n', i+MaxX, length(Signal));

    cla(Dose); cla(Feedback);
    set(Dose, 'visible', 'off');
    set(Feedback, 'visible', 'off');
end

