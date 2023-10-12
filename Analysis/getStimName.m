function stimName = getStimName(Trials)
% Read in a list of all eyelink messages for one trial
% Search for one referencing the stimulus name
% Strip out everything but the stimulus name and return it
list = Trials.Events.message;
y = cellfun(@(x) contains(x,'0 !V VFRAME 1 640 360 '), list);
assert(sum(y) == 1, 'No message re video name found!');
stimName = list{y};
%     stimName = erase(stimName, '!V TRIAL_VAR video_file ');
stimName = erase(stimName, '0 !V VFRAME 1 640 360 ');
stimName = erase(stimName, '.MOV');
end % function