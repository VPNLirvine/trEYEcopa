% Assume var data exists



% Now only analyze correlations based on subject 1
s = 1;
s2 = 2;
numTrials = height(data(s).beh);
for t = 1:numTrials
    % See if this trial exists for subject 2
    tname = data(s).beh.StimName{t};
    % Init these vars each time, so you don't have leftover data
    scanA = [];
    scanB = [];
    if ismember(tname, data(s2).beh.StimName)
        % Figure which trial you need from subject 2
        ind = find(strcmp(tname, data(s2).beh.StimName));
        % Slice out the scanpath for both subjects
        % ...which will take x and y data, right?
        scanA(:,1) = pickCoordData(data(s).edf(t).Samples.gx);
        scanA(:,2) = pickCoordData(data(s).edf(t).Samples.gy);

        scanB(:,1) = pickCoordData(data(s2).edf(ind).Samples.gx);
        scanB(:,2) = pickCoordData(data(s2).edf(ind).Samples.gy);
        
        % Now you have x,y for every timepoint for both subjects
        % Determine if either needs to be flipped
        if data(s).beh.Flipped(t)
            % Then flip the x data
            % That requires knowing the screen dimensions...
            % Uh just hardcode for now I guess: 1920 x 1200
            screenXMax = 1920;
            scanA(:,1) = mirrorX(scanA(:,1), screenXMax);
        end
        if data(s2).beh.Flipped(ind)
            % Same
            screenXMax = 1920;
            scanB(:,1) = mirrorX(scanB(:,1), screenXMax);
        end
        
        % Now correlate the two x-y vectors somehow
        % Remembering that they're not necessarily the same length
        % And also they're both 2-column matrices
        fprintf(1, '');
    else
        % Nothing to compare, so move to next trial
        continue
    end
end

% So now what?