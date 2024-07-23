function output = doGazePath(data, varargin)
% Given some gaze vectors, perform a framewise ISC
% Returns a table with a vector for each video,
% describing fluctuations the average ISC over time
% Expects as input the output of e.g. getTCData('gaze')

% data = getMWData('gaze');
stimList = unique(data.StimName);
subList = unique(data.Subject);

if nargin > 1
    flag = varargin{1};
    assert(islogical(flag), 'Second input must be a boolean indicating whether to plot or not');
else
    % This generates one plot per stimulus, please just skip
    flag = false;
end
plotFlag = 0; % For getting the initial heatpaths. PLEASE DON'T PLOT omg

% fprintf(1, 'Getting heatpaths...')
% for i = 1:length(stimList)
%     stim = stimList{i};
%     plotFlag = 0; % 2 to visualize
%     [heatpaths(i).Data, heatpaths(i).Bins] = getHeatPath(data, stim, plotFlag);
%     heatpaths(i).Stim = stim;
% end
% fprintf(1, 'Done getting heatpaths.\n');

% So now we have heatpaths.Data, which is the counts,
% and heatpaths.Bins, which lists the bin edges for X, Y, and T.

%... now what?
% You want to compare the group heatmap to a single subject's scanpath.
% So index a subject out of data matching this stimulus,
% run that single trial through getHeatPath to convert it,
% and compare the two

numRows = height(data);
% Give feedback re progress in command window
numDigs = length(num2str(numRows));
fprintf(1, 'Comparing subjects to group heatpaths %i times...\n', numRows)
fprintf(1, 'Working on row %s', pad(num2str(0), numDigs, 'left','0'));
for i = 1:numRows
    % Report which number we're working on
        % Delete previous number
        for b = 1:numDigs
            fprintf(1,'\b'); % backspace over last num
        end
        % Print the current number
        fprintf(1, '%s', pad(num2str(i), numDigs, 'left','0'));

    subID = data.Subject{i};
    stim = data.StimName{i};
    [subDat, subBins] = getHeatPath(data(i,:), stim, plotFlag);
    % Also get an N-1 group average for this stim
    subset = ~strcmp(subID, data.Subject);
    [groupDat, groupBins] = getHeatPath(data(subset,:), stim, plotFlag);
    % groupDat = heatpaths(subset).Data;
    % groupBins = heatpaths(subset).Bins;

    % Now at this point, subDat and groupDat may be different lengths.
    % Recording durations were slightly variable, so bin numbers differ.
    % I've ensured the time bins have the same spacing each time, 
    % so if a given recording has fewer bins, it just was a bit short.
    % Add some 0s to pad it out (0 means no gaze samples in this bin).
    numGBins = length(groupBins.TbinEdges) -1;
    numSBins = length(subBins.TbinEdges) -1;
    if numGBins > numSBins
        subDat(:,:,numSBins + 1 : numGBins) = NaN; % or NaN?
    elseif numSBins > numGBins
    % Same for if this sub is longer than everyone else
        groupDat(:,:,numGBins + 1 : numSBins) = NaN;
    end
    
    % Once you solve that issue, the next is that corr2 doesn't support 3D.
    % So you have to do a loop over every "frame" (i.e. bin)
    % Fortunately this is pretty fast (~.02 sec / row)
    myCorr = [];
    for j = 1:min([length(groupDat), length(subDat)])
        subF = subDat(:,:,j);
        grpF = groupDat(:,:,j);
        myCorr(j) = corr2(subF,grpF);
    end
    % Finally, store myCorr in a bigger variable for each row of the data
    pathCorrs{i} = myCorr;
end % for each row of the input data
fprintf(1, '\nDone comparing subjects to group.\n');

% Now the fun part: compare those correlations for all subs per video
output = table('Size',[length(stimList),3], 'VariableTypes', {'cell', 'cell', 'cell'}, 'VariableNames', {'Data', 'Bins', 'StimName'});
for s = 1:length(stimList)
    stim = stimList{s};
    corrForStim = pathCorrs(strcmp(stim, data.StimName));
    d = [];
    for v = 1:length(corrForStim)
        d(:,v) = corrForStim{v};
    end

    % Output
    output.Data{s} = mean(d, 2, 'omitnan');
    [~, output.Bins{s}] = getHeatPath(data, stim, plotFlag); % full group
    output.StimName{s} = stim;

    % Visualize
    if flag
        figure();
        plot((1:height(d)) * 200, output{s});
        xlabel('Time (ms)');
        ylabel('Average framewise ISC');
        ylim([0 1]);
        title(stim);
        ax = gca; % axes handle
        ax.XAxis.Exponent = 0; % avoid scientific notation
    end % if plotting
end % for each stim

end % function