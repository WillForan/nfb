% Use KbQueue to wait for scanner trigger 
%   assume trigger key is =+
%   assume keyboard "DeviceID" is []
function trgrtime = waitForScannerTrigger()
% 20190510 WF - task uses kbqueue, so do not create/release
% 20180103 WF - wait for trigger keypess
%  use PTB's KbQueue for new Psychology Software Tools button box
%  because simulated keypress is too fast to be consistently captured by ListenChar/KbWait/KbCheck
%  trigger is a simulated "=" keypress


% what key(s) are acceptable scanner start triggers
triggerKeys = {'=+'};
 
% setup: var, keys, and queue
scannerTrigger = 0;
KbName('UnifyKeyNames');
triggerIdx = KbName(triggerKeys);
ListenChar(2); % we can tell matlab to not show keypresses

fprintf('WAITING FOR TRIGGER\n')
%KbQueueCreate(); % for nfb, we already have a KbQueue created
KbQueueStart();

% keep checking until the scanner says it started
while ~scannerTrigger
    [pressed, firstPress, ~,~,~] = KbQueueCheck();
    scannerTrigger = pressed && ...
        any(ismember(triggerKeys, KbName(firstPress)));
end
 
% grab the time of the button push. look at press of first (by key orsca
[~,~, trgrtime ] = find(firstPress(triggerIdx),1);
 

KbQueueStop();
KbQueueFlush();

% in Nfb we will continue to use KbQueue -- so dont release it
% not releasing also saves us 90ms
% KbQueueRelease()
 
end