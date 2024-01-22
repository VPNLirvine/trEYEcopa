% trial number
% stimulus ID
% timestamp of frame onset
pths = specifyPaths('..');
flist = dir(fullfile(pths.beh, '*_task-debug_date-*.tsv'));
numFiles = length(flist);
for i = 1:numFiles
    fname = fullfile(pths.specifyPaths, flist(i).Name);
    input = readtable(fname);
    % 'Trial \tStimName \tFrame \tDuration\n'
    stimList = unique(input.StimName);
    numStims = length(stimList);
    % Separate by movie
    data = pivot(input, Columns='StimName', DataVariable='Duration')
    % Plot histogram of frame durations
    
    % t-test for differences by movie?
end