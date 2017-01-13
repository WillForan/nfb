PsychDebugWindowConfiguration
PsychDefaultSetup(2); % default settings

% screen initialization and refresh
Screens = Screen('Screens'); % get scren number
ScreenNumber = max(Screens);
[Window, Rect] = PsychImaging('OpenWindow', ScreenNumber, BgColor);
PriorityLevel = MaxPriority(Window);
Priority(PriorityLevel);
[XCenter, YCenter] = RectCenter(Rect);
[Refresh] = Screen('GetFlipInterval', Window);
ScanRect = [0 0 1024 768];
[ScanCenter(1), ScanCenter(2)] = RectCenter(ScanRect);

% print scren information
fprintf(1, '\n');
fprintf(1, 'Screen refresh rate: %0.4f Hz\n', 1/Refresh);
fprintf(1, 'Screen resolution:   %d x %d\n\n', Rect(3), Rect(4));

% devices 
[indices, names, infos] = GetKeyboardIndices;

for i = 1:numel(indices)
    fprintf('%d:%s\n', indices(i), names{i});
end

sca
