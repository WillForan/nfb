% Use KbQueue to wait for scanner trigger 
% optional argument is device id
function trgrtime = waitForScannerTrigger()
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
%KbQueueCreate(); KbQueueStart();
 
fprintf('WAITING FOR TRIGGER')

% keep checking until the scanner says it started
while ~scannerTrigger
    [pressed, firstPress, ~,~,~] = KbQueueCheck();
    scannerTrigger = pressed && ...
        any(ismember(triggerKeys, KbName(firstPress)));
end
 
% grab the time of the button push. look at press of first (by key orsca
[~,~, trgrtime ] = find(firstPress(triggerIdx),1);
 
% release queue -- unblock listening to keyboard -- so we can use KbWait later
% this takes about .090 seconds
% which is why we grab time above
KbQueueStop();

% in Nfb we will continue to use KbQueue -- so dont release it
% KbQueueRelease()
 
% % previously trigger simulated "key press" was long enough to be captured by KbWait
% while ~ scannerTrigger
%   [~, keyCode, ~]  = KbWait;
%   scannerTrigger = any(ismember({'=','=+'}, KbName(keyCode)));
% end
 
end