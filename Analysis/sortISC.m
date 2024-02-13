function data = sortISC
% Deal the output of doISC out into the normal output format

isc = doISC;
fprintf(1,'\n\nNow extracting a second dataset to get a template...\n\n');
data = getTCData('fixation'); % use a bogus metric to get a template

% Do a vlookup to overwrite the fixation data with the isc data
subList = unique(data.Subject);
numSubs = length(subList);
for i = 1:numSubs
    subName = subList{i};
    trialList = data.StimName(strcmp(subName, data.Subject));
    for t = 1:length(trialList)
        trialName = trialList{t};
        % Find the output index - position in data
        outInd = strcmp(trialName, data.StimName) & strcmp(subName, data.Subject);
        % Find the input index - position in isc
        inCol = strcmp(subName, isc.Properties.VariableNames);
        inRow = strcmp(trialName, isc.StimName);
        % Overwrite old data
        data.Eyetrack(outInd) = isc{inRow, inCol};
    end
end
% And drop any trials where only one person contributed,
% because then you have an artificially perfect correlation w/ the 'group',
% because the 'group' is really just that one person
trialList = unique(data.StimName);
for t = 1:length(trialList)
    trial = trialList{t};
    if sum(strcmp(trial, data.StimName)) == 1
        data(strcmp(trial, data.StimName), :) = [];
    end
end
end