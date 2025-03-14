function stimName = getStimName(Trials)
% Read in a list of all eyelink messages for one trial
% Search for one referencing the stimulus name
% Strip out everything but the stimulus name and return it
list = Trials.Events.message;
chktxt = '0 !V VFRAME 1 ';
y = cellfun(@(x) contains(x, chktxt), list);
if ~sum(y)
    chktxt = '!V TRIAL_VAR video_file ';
    y = cellfun(@(x) contains(x,chktxt), list);
    assert(sum(y) > 0, 'No message re video name found!');
    stimName = list{y};
    stimName = erase(stimName, chktxt);
    stimName = erase(stimName, '.MOV');
else
    assert(sum(y) > 0, 'No message re video name found!');
    stimName = list{y};
    stimName = erase(stimName, chktxt);
    stimName = erase(stimName, '.MOV');
    % This still has the video coordinates in the message, so remove them
    x = sscanf(stimName, '%i %i %s');
    stimName = char(x(3:end))'; % skip 1 and 2, the coordinates.
end

end % function