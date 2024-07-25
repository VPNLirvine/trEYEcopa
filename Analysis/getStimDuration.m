function duration = getStimDuration(edfRow)
% Trial duration in the EDF files is in unknown units,
% so this function determines length in seconds
% by finding a message sent by the experiment on stimulus end.
%
% Input is a single ROW of the output of osfImport (i.e. not all trials).
% Output is duration in seconds.
%
% If you want to write that value into the edf somewhere, that's up to you.

list = edfRow.Events.message;
chktxt = '!V TRIAL_VAR video_duration ';
y = cellfun(@(x) contains(x, chktxt), list);
assert(sum(y) > 0, 'No message re video duration found!');
duration = str2double(erase(list{y}, '!V TRIAL_VAR video_duration '));
duration = duration / 1000; % convert from ms to sec

end