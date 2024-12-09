function output = getAvgDeviance()
% Deviance is a measure of how far any subject deviates from prediction.
% Here, we're averaging across subjects, preserving the time dimension,
% in order to get a group-average (or "expected") deviance vector.
% (...which is sort of ironic: you've got a stimulus-derived prediction,
% but then also a behavior-derived predicted deviance from the prediction)

% Get all subs all trials
dat = getTCData('deviance');

% Get a list of stims (though out of order)
stimList = unique(dat.StimName);
numStims = length(stimList);

% For each stim, average each timepoint across subjects
for i = 1:numStims
    stimName = stimList{i};
    subset = strcmp(stimName, dat.StimName);
    datStack = dat.Eyetrack(subset);
    % Now we have a set of timecourses, potentially of various durations,
    % and maybe even at different sampling rates.
    % In order to get a group-average, we have to align them.
    % So take the shortest timecourse and interpolate the rest to fit it.
    % Then average over subjects to get an average value per unit time.
    lengths = cellfun(@length, datStack);
    chosenOne = datStack{lengths == min(lengths)};
    newTiming = chosenOne(2,:); % just the timing info
    numSubs = height(datStack);
    fprintf(1, '%s:\tInterpolating over %i subs...', stimName, numSubs)
    tmpDat = zeros([numSubs, length(newTiming)]);
    maxDev = sqrt(1920^2 + 1200^2);
    for s = 1:numSubs
        x = datStack{s};
        oldDat = x(1,:);
        % There is a theoretical limit on how far you can deviate.
        % Anything beyond this is likely measurement error of some sort.
        % And I do observe occasional onset/offset effects in this data,
        % So we're just going to steamroll over them with the ideal max.
        if any(oldDat > maxDev)
            fprintf(1, 'Fixing %i values...', sum(oldDat > maxDev));
            oldDat(oldDat > maxDev) = maxDev;
        end
        oldTiming = x(2,:);
        tmpDat(s,:) = interp1(oldTiming, oldDat, newTiming);
    end
    fprintf(1, 'Done.\n');

    Deviance{i,1} = mean(tmpDat, 1, 'omitnan');
    StimName{i,1} = stimName;
end

% Write to output file
output = table();
output.StimName = StimName;
output.Deviance = Deviance;