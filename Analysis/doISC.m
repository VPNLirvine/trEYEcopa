function ISC = doISC()
    % Calculate intersubject correlations of scan paths
    % Generates a heatmap of every trial's scanpath,
    % then correlates each subject's scanpath with the n-1 group average
    % for a particular stimulus.

    % First, get the heatmaps for each video
    data = getTCData('heatmap');
    numRows = size(data,1);

    % Init the output variable
    dheader = {'Subject', 'Eyetrack', 'Response', 'RT', 'Flipped'};
    dtypes = {'string', 'double', 'double', 'double', 'logical'};
    ISC = table('Size', [0, 6], 'VariableNames', dheader, 'VariableTypes', dtypes);

    % Suppress a warning about the way I fill the table
    warning('off', 'MATLAB:table:RowsAddedExistingVars');
    
    % For each movie, compare each subject to all others
    fprintf(1, 'Calculating intersubject correlations...');
    for r = 1:numRows
        % Which video is this?
        stimName = data.StimName{r};
        % Which subject is this?
        subID = data.Subject{r};
        % Get this subject's heatmap
        heatmap1 = data.Eyetrack{r};
        
        % Calculate the n-1 group average heatmap
        % First, see what n-1 is for this video
        hitList = strcmp(stimName, data.StimName) & ~strcmp(subID, data.Subject);
        if sum(hitList) == 0
            % If there's no other results for this one, skip it
            % Can't look at n-1 other people when n = 1
            continue
        else
            % Stack all the other heatmaps into a 3D matrix
            imStack = cat(3,data.Eyetrack{hitList});
            % Now average across the 3rd dimension
            heatmap2 = mean(imStack, 3);
            % Compare and export
            ISC.Eyetrack(r) = corr2(heatmap1, heatmap2);
            
            % Add all the other bits in too
            ISC.Subject{r} = subID;
            ISC.Response{r} = data.Response(r);
            ISC.RT(r) = data.RT(r);
            ISC.Flipped(r) = data.Flipped(r);
            ISC.StimName{r} = stimName;
        end
    end
    ISC = rmmissing(ISC); % Drop any skipped rows
    % Clean up before exit
    warning('on', 'MATLAB:table:RowsAddedExistingVars');
    fprintf(1, 'Done.\n');
end