function [output, varargout] = doGazePath(data, varargin)
% Given some gaze vectors, compare their similarity over time
% Converts each gaze vector into a dimension-reduced 3D histogram,
% then compares each subject to an N-1 group histogram,
% and outputs the similarity score for each time bin of the histogram.
%
% -Input 1 is a data table of gaze vectors, e.g. x = getTCData('gaze')
% -(Optional) Input 2 is a T/F flag to plot ALL those gaze vectors.
% This is more useful for debugging or for the Martin & Weisberg vid
% -Output 1 is a table with the average vector for each VIDEO,
% describing group-level fluctuations in the ISC over time.
% This is most useful for generating predictions about new subjects.
% -Optional output 2 is a table with a vector for each TRIAL, like Input 1.
% This is more useful for identifying outliers/subject-level influences.
%
% Both outputs put the "ISC" per bin in row 1, and the bin time in row 2.
% Time is given as the center of the bin (e.g. 0ms to 200ms = 100 ms)


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

    % Normalize the timing for all subjects with this stim
    % unfortunately this is looping over trial, not stim,
    % so it happens multiple times per video.
    stimDat = data(strcmp(data.StimName, stim),:);
    stimDat = fixTiming(stimDat);
    thisSub = strcmp(subID, stimDat.Subject);
    % Convert gaze vector into a 3D a histogram
    [subDat, subBins] = getHeatPath(stimDat(thisSub,:), stim, plotFlag);
    % Also get an N-1 group average for this stim
    subset = ~strcmp(subID, stimDat.Subject);
    [groupDat, groupBins] = getHeatPath(stimDat(subset,:), stim, plotFlag);
    % groupDat = heatpaths(subset).Data;
    % groupBins = heatpaths(subset).Bins;
    % Convert bin edges to bin centers, to facilitate plotting
    binD = groupBins.TbinEdges(1:end-1) + (diff(groupBins.TbinEdges) / 2);

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
    % By initializing with 0s, you ensure they're all the same length
    myCorr = zeros([1, numGBins]); % init
    bins = zeros([1, numGBins]); % init
    for j = 1:numGBins
        subF = subDat(:,:,j);
        grpF = groupDat(:,:,j);
        myCorr(j) = corr2(subF,grpF);
        bins(j) = binD(j); % make sure they're the same length
    end
    % Finally, store myCorr in a bigger variable for each row of the data
    % Add the bin centers as a second row so you can plot against time
    pathCorrs{i} = [myCorr; bins];
end % for each row of the input data
fprintf(1, '\nDone comparing subjects to group.\n');
if nargout > 1
    data.Eyetrack = pathCorrs';
    varargout{1} = data;
end

% Now the fun part: compare those correlations for all subs per video
fprintf(1, 'Averaging path similarities per video...')
output = table('Size',[length(stimList),3], 'VariableTypes', {'cell', 'cell', 'cell'}, 'VariableNames', {'Data', 'Bins', 'StimName'});
for s = 1:length(stimList)
    stim = stimList{s};
    corrForStim = pathCorrs(strcmp(stim, data.StimName));
    d = [];
    for v = 1:length(corrForStim)
        d(:,v) = corrForStim{v}(1,:);
    end

    % Output
    output.Data{s} = mean(d, 2, 'omitnan');
    [~, bins] = getHeatPath(data, stim, plotFlag); % get bins of full group
    output.Bins{s} = bins.TbinEdges(1:end-1) + (diff(bins.TbinEdges) / 2); % centers, not edges
    output.StimName{s} = stim;

    % Visualize
    if flag
        figure();
        plot(output.Bins{s}, output.Data{s});
        xlabel('Time (ms)');
        ylabel('Average framewise ISC');
        ylim([0 1]);
        title(strrep(output.StimName{s}, '_', '\_'));
        ax = gca; % axes handle
        ax.XAxis.Exponent = 0; % avoid scientific notation
    end % if plotting
end % for each stim
fprintf(1, 'Done.\n');
end % function