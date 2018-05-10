% waitForScannerTrigger  -- block until keyboard gets a trigger from the scanner
% uses KbQueue to wait for scanner trigger. could use KbQueueWait instead of this function
% options:
%    waitForScannerTrigger('triggerKeys',{'6^'}) -- set trigger to wait for to ^
%    waitForScannerTrigger('kb_created',1)       -- already have a kbqueue, dont create one
%    waitForScannerTrigger('deviceNumer',0)      -- set the device number
%    "On MS-Windows it is not possible to enumerate different keyboards and mice
%     separately. Therefore the 'deviceNumber' argument is mostly useless ..."
function trgrtime = waitForScannerTrigger(varargin)

% 20190510 WF - task uses kbqueue, so do not create/release
%  add options for 'trigger', 'kb_created', and deviceNumber

% 20180103 WF - initial
%  use PTB's KbQueue for new Psychology Software Tools button box
%  because simulated keypress is too fast to be consistently captured by ListenChar/KbWait/KbCheck
%  trigger is a simulated "=" keypress

%% parse options
% defaults
opts.triggerKeys = {'=+'}; % what will trigger continue
opts.deviceNumber= [];     % Device ID. More than likely never matters
opts.kb_created  = 0;      % we haven't already run KbQueueCreate

% parse any options
i=1;
opt_names = fieldnames(opts); % need to unnest
while i<nargin
   if contains(varargin{i},{opt_names{:}}) % 'contains' from R2016a
      opts.(varargin{i}) = varargin{i+1};
      i=i+1;
   end
   i=i+1;
end

 
%% setup: var, keys, and queue
KbName('UnifyKeyNames');
triggerIdx = KbName(opts.triggerKeys);
%ListenChar(2); % we can tell matlab to not show keypresses
% reported to work poorly with windows > xp

fprintf('=== WAITING FOR TRIGGER ===\n')

%% start queue
% only create a queue if we aren't told one already exists
if ~opts.kb_created; KbQueueCreate(opts.deviceNumber); end
KbQueueStart(opts.deviceNumber);

%% wait for trigger
% keep checking until the scanner says it started, essentially reimplement 'KbQueueWait'
scannerTrigger = 0;
while ~scannerTrigger
    [pressed, firstPress, ~,~,~] = KbQueueCheck(opts.deviceNumber);
    scannerTrigger = pressed && ...
        any(ismember(opts.triggerKeys, KbName(firstPress)));
end
 
% grab the time of the button push. look at press of first (by key orsca
[~,~, trgrtime ] = find(firstPress(triggerIdx),1);
 

%% clean up
KbQueueStop(opts.deviceNumber);
KbQueueFlush(opts.deviceNumber);
% releasing queue so we can use eg. KbWait
if ~opts.kb_created; KbQueueRelease(opts.deviceNumber); end
%  only do if we didn't have a queue before starting this function
% costs 90ms.
 
end
