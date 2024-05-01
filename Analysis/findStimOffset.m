function onTime = findStimOffset(edfRow)
% The other onset times are all wrong
% The one in the header includes the duration of the drift check(s)
% The one from osfImport includes a few samples before video onset
% This tells you exactly when (in eyetracker units) the video starts

list = edfRow.Events.message;
chktxt = 'BLANK_SCREEN';
y = cellfun(@(x) contains(x, chktxt), list);
assert(sum(y) > 0, 'No message re stimulus offset found!');
onTime = double(edfRow.Events.sttime(y));