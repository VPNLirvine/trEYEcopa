function getHeatPath(data, stim)
% If a heat MAP is a 2D representation of single subject's 3D gaze path,
% then a heat PATH is a 3D representation of ALL subjects' gaze paths.
% It's like a 3D histogram.
%
% Input 1 is the data table of gaze paths, e.g. from getTCData('gaze');
% Input 2 is the stimulus name as it appears in data.StimName

% Find the index of that stim name
stimList = unique(data.StimName);
s = find(strcmp(stim, stimList));

numStims = length(stimList);

% Now subset to the trial data for that stim from all subs
pathList = data.Eyetrack(strcmp(stim, data.StimName));
subList = data.Subject(strcmp(stim, data.StimName));
numSub = length(subList);

% As an intermediary step, plot all those paths stacked on top of each other
% but turn this section off if you're looping over stimulus
figure();
hold on
for i = 1:length(pathList)
    plotGaze(pathList{i}, stim);
end
hold off

% Now reorganize the data in prep for making a histogram:
% write each element of each gaze vector into a single row of one giant table
varNames = {'Subject','x','y','time','c'};
varTypes = {'string','double','double','double','double'};
tbl = table('Size', [0 5], 'VariableTypes',varTypes,'VariableNames',varNames);
a = 0; % existing length of tbl
for i = 1:numSub
    dat = double(pathList{i});
    xdat = dat(1,:);
    ydat = dat(2,:);
    tdat = dat(3,:) + 1;
    clear dat

    % Account for blink data
    bad = xdat == 100000000 | ydat == 100000000;
    xdat(bad) = [];
    ydat(bad) = [];
    tdat(bad) = [];
    
    subID = subList{i};
    numRows = length(tdat);

    % Write this data into new rows of an output variable
    tbl(a+1:a+numRows,:) = table(repmat(subID, numRows,1), xdat',ydat',tdat', repmat(i,numRows,1));
    a = a + numRows;
end

% Finally, run it through a 3D histogram and plot again.
plotDensity(tbl, stim);
fprintf(1, 'Done.\n')
