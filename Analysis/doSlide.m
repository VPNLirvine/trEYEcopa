function data = doSlide(data)
% Perform sliding-window correlation of gaze path with other subjects
% Expects as input the gaze path data for all subs, e.g. getTCData('gaze')

numRows = height(data);

% Extract data to work over
% Then we're just going to overwrite the existing table to save memory
gazeList = data.Eyetrack;
data.Eyetrack = cell(numRows, 1);

% Suppress a warning about the way I fill the table
warning('off', 'MATLAB:table:RowsAddedExistingVars');

% Give feedback re progress in command window
numDigs = length(num2str(numRows));
fprintf(1, 'Calculating sliding-window correlation for %i gaze paths.\n', numRows);
fprintf(1, 'Working on row %s', pad(num2str(0), numDigs, 'left','0'));
numSkipped = 0;
% For each movie, compare each subject to all others
for r = 1:numRows
    % Report which number we're working on
        % Delete previous number
        for b = 1:numDigs
            fprintf(1,'\b'); % backspace over last num
        end
        % Print the current number
        fprintf(1, '%s', pad(num2str(r), numDigs, 'left','0'));
    % Which video is this?
    stimName = data.StimName{r};
    % Which subject is this?
    subID = data.Subject{r};
    % Get this subject's gaze path
    gaze1 = single(gazeList{r});
% Calculate the n-1 group average gaze path
    % First, see what n-1 is for this video
    hitList = strcmp(stimName, data.StimName) & ~strcmp(subID, data.Subject);
    if sum(hitList) == 0
        % If there's no other results for this one, skip it
        % Can't look at n-1 other people when n = 1
        numSkipped = numSkipped + 1;
        continue
    else
        % Stack all the other gaze paths together
        imStack = gazeList(hitList);
        N = height(imStack);
        % Not all have the same length/sample rate.
        % To account for this,
        % we'll compress the samples within each window into a heatmap, 
        % instead of working on raw scanpaths.
        
        % Now do the heavy lifting of sliding-window correlation
        % Potentially faster via fft or something
        numT = length(gaze1);
        tmp = zeros([numT, 1]); % preallocate
        winSize = 200; % but that's in ms, while t is in indices.

        % Predefine your Gaussian filter here for performance
        sigma = 2; % ??
        hsize = round(deg2pix(2)); % convert 2 deg to x pixels
        myFilt = fspecial('gaussian', hsize, sigma);
        for t = 1:numT
            % Print feedback about progress
            pct = pad(num2str(round(t/numT * 100)), 3, 'left', '0');
            fprintf(1, ': %s%%', pct);

            % Define the sliding window for this timestamp
            % gaze has 3 rows: x, y, and timestamp
            drmax = find(gaze1(3,:) >= gaze1(3,t) + winSize, 1);
            if isempty(drmax)
                % if no timestamps >= t+200, then t is near the end,
                % and t+200 exceeds the length.
                % So hard-cutoff at the end.
                drmax = numT;
            end
            drange = t:drmax;
            % These numbers help us find the relevant range in other subjs
            tmin = gaze1(3,t);
            tmax = gaze1(3,drmax);

            gs1x = gaze1(1, drange); % gaze subset
            gs1y = gaze1(2, drange); % gaze subset

            % Convert gaze vector to a heatmap
            scDim = [1920 1200]; % copied over from another function
            hm1 = getHeatmap(gs1x, gs1y, scDim);
                % Normalize
                hm1 = zscore(hm1);
                % Smooth
                hm1 = imfilter(hm1, myFilt, 'replicate');

            % Get the n-1 *average* heatmap for the same time window
            hmN = zeros([scDim(2), scDim(1), N]); % preallocate
            for i = 1:N
                % For all other subjects with this video:
                % Extract scanpath
                gazeN = single(imStack{i});
                % Determine which elements fit in this window
                timeComp = gazeN(3,:) >= tmin & gazeN(3,:) <= tmax;
                % Subset
                gs2x = gazeN(1, timeComp);
                gs2y = gazeN(2, timeComp);
                % Convert to heatmap
                x = []; % init
                x = getHeatmap(gs2x, gs2y, scDim);
                % Normalize
                x = zscore(x);
                % Smooth, store result in temp
                hmN(:,:,i) = imfilter(x, myFilt, 'replicate');
            end
            % hmN is now a stack of 2D heatmaps per subject
            % Compress into a group average
            hm2 = mean(hmN, 3);
            % Calculate correlation bw subject and group
            tmp(t) = corr2(hm1, hm2);

            % Backspace over percent complete
            fprintf(1,'\b\b\b\b\b\b');
        end
        data.Eyetrack{r} = tmp;
    end
end
data = rmmissing(data); % Drop any skipped rows
fprintf(1,'\nDone. Skipped %i trials with not enough other subjects.\n', numSkipped);
end % function