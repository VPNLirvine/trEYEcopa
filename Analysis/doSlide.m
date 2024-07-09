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
        % Not all have the same length/sample rate.
        % To fix it, interpolate anything with a different length
        % so that it matches the time vector of gaze1.
        timeRef = gaze1(3,:);
        N = height(imStack);
        X = [];
        Y = [];
        gaze2 = [];
        for i = 1:N
            gazeN = single(imStack{i});
            % get time vector of this subj
            timeComp = gazeN(3,:);
            % Interpolate to fit the timescale of the reference subject
            X(i,:) = interp1(timeComp, gazeN(1,:), timeRef, 'spline');
            Y(i,:) = interp1(timeComp, gazeN(2,:), timeRef, 'spline');
        end

        % Now average across the 4th dimension?
        gaze2(1,:) = mean(X,1);
        gaze2(2,:) = mean(Y,1);
        % Now do the heavy lifting of sliding-window correlation
        % Potentially faster via fft or something
        numT = length(gaze1);
        tmp = zeros([numT, 1]); % preallocate
        winSize = 200; % but that's in ms, while t is in indices.
        for t = 1:numT
            % gaze1 is this subject
            % gaze2 is the n-1 group average
            % Both have 3 rows: x, y, and timestamp

            % Define the sliding window for this timestamp
            drmax = find(gaze1(3,:) >= gaze1(3,t) + winSize, 1);
            if isempty(drmax)
                % if no timestamps >= t+200, then t is near the end,
                % and t+200 exceeds the length.
                % So hard-cutoff at the end.
                drmax = numT;
            end
            drange = t:drmax;
            % Calculate the correlation within the window
            tmp(t) = corr2(gaze1(1:2,drange), gaze2(1:2,drange));
        end
        data.Eyetrack{r} = sltmp;
    end
end
data = rmmissing(data); % Drop any skipped rows
fprintf(1,'\nDone. Skipped %i trials with not enough other subjects.\n', numSkipped);
end % function