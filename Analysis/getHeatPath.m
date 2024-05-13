function output = getHeatPath(data, stim, varargin)
% If a heat MAP is a 2D representation of single subject's 3D gaze path,
% then a heat PATH is a 3D representation of ALL subjects' gaze paths.
% It's like a 3D histogram.
% This is inherently itemwise, i.e. compares all subjects for one stimulus,
% thus you ought not correlate this data with subject-level vars like AQ.
%
% Input 1 is the full data table of gaze paths, e.g. from getTCData('gaze');
% Input 2 is the stimulus name as it appears in data.StimName
% Input 3 (optional) flags whether you want to plot the data or not
% - flag values: 0 = no plots, 1 = scatter of all, 2 = histogram, 3 = both
%
% Output 1 is a struct with two elements:
% output.Data is the 3D matrix of data representing the bin counts
% output.Bins is a struct w/ the bin edges: XbinEdges YbinEdges TbinEdges
% Remember that there are n+1 edges relative to bins:
% Bin 1 covers the range edge(1):edge(2), ... bin N is edge(N):edge(N+1)

% Parse varargin
if nargin > 2
    flag = varargin{1};
else
    % No plots by default
    flag = 0;
end

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
if flag == 1 || flag == 3
    figure();
    hold on
    for i = 1:length(pathList)
        plotGaze(pathList{i}, stim);
    end
    hold off
end

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
flag2 = flag >= 2; % Determine whether to plot or not
[output.Data, output.Bins] = plotDensity(tbl, stim, flag2); % Get data, maybe plot too
fprintf(1, 'Done.\n')
