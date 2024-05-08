function getHeatPath(data, stim)
% If a heat MAP is a 2D representation of single subject's 3D gaze path,
% then a heat PATH is a 3D representation of ALL subjects' gaze paths.
% It's like a 3D histogram.
%
% Input 1 is the data table of gaze paths, e.g. from getTCData('gaze');
% Input 2 is the stimulus name, 

% Then pick a stim name
stimList = unique(data.StimName);
s = find(strcmp(stim, stimList));
% s = 11;

numStims = length(stimList);

% Now subset to the trial data for that stim from all subs
pathList = data.Eyetrack(strcmp(stim, data.StimName));
subList = data.Subject(strcmp(stim, data.StimName));
numSub = length(subList);

% For all subs with this video,
% write each element of the gaze vectors into a new row of one giant table
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

    % Now compress this data to be 20x20 instead of 1920x1200
    % xdat = round(xdat / 1920 * 20);
    % ydat = round(ydat / 1200 * 20);
    
    subID = subList{i};
    numRows = length(tdat);

    % Write this data into new rows of an output variable
    tbl(a+1:a+numRows,:) = table(repmat(subID, numRows,1), xdat',ydat',tdat', repmat(i,numRows,1));
    a = a + numRows;
end

fprintf(1, '\tPlotting stim %i / %i...', s, numStims)
% Plot all eye paths directly from the big table
figure();
colormap('lines');
scatter3(tbl.x,tbl.time,tbl.y, 36, tbl.c);
xlabel('x');
ylabel('Time in ms');
zlabel('y');
title(replace(stim,'_','\_'));
xlim([0 1920]);
zlim([0 1200]);
set(gca, 'YDir', 'reverse'); % time goes from back to front
set(gca, 'ZDir', 'reverse'); % y axis goes from top to bottom

% Cool, now aggregate across subjects and plot again.
plotDensity(tbl, stim);
fprintf(1, 'Done.\n')


