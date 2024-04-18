function data = doISC(data)
    % Calculate intersubject correlations of scan paths
    % Generates a heatmap of every trial's scanpath,
    % then correlates each subject's scanpath with the n-1 group average
    % for a particular stimulus.
    % Expect input of the heatmaps for each video

    % I've offloaded the heatmaps bc there are two data-getter functions,
    % depending on the stimulus set.
    % You could probably eventually merge them, but for now, separate.
    
    numRows = size(data,1);

    % Extract the heatmaps from the input data
    % Then we're just going to overwrite the existing table to save memory
    heatmapList = data.Eyetrack;
    data.Eyetrack = zeros(numRows,1);

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
        heatmap1 = heatmapList{r};
        
        % Calculate the n-1 group average heatmap
        % First, see what n-1 is for this video
        hitList = strcmp(stimName, data.StimName) & ~strcmp(subID, data.Subject);
        if sum(hitList) == 0
            % If there's no other results for this one, skip it
            % Can't look at n-1 other people when n = 1
            continue
        else
            % Stack all the other heatmaps into a 3D matrix
            imStack = cat(3,heatmapList{hitList});
            % Now average across the 3rd dimension
            heatmap2 = mean(imStack, 3);
            % Compare and export
            data.Eyetrack(r) = corr2(heatmap1, heatmap2);
            
        end
    end
    data = rmmissing(data); % Drop any skipped rows
    % Clean up before exit
    warning('on', 'MATLAB:table:RowsAddedExistingVars');
    fprintf(1, 'Done.\n');
end