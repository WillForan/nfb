load('Waveforms.mat');

fid = fopen('Waveforms.csv', 'w');
fprintf(fid, 'Run,Number,Section,Index,Time,Value\n'); 
Time = 1/60:1/60:(599*1/60);

for iRun = 1:size(Signals, 2)
    for i = 1:size(Signals{iRun}, 1)
        Index = 1;
        for k = 1:size(Signals{iRun}, 2)
    
            if k == 1
                Start = 241;
            else
                Start = 1;
            end
    
            for m = Start:length(Signals{iRun}{i, k})
                fprintf(fid, '%d,%d,%d,%d,%0.4f,%0.4f\n', ...
                    iRun, i, k, Index, Time(Index), Signals{iRun}{i, k}(m));
                Index = Index + 1;
            end
        end
    end
end

fclose(fid);
