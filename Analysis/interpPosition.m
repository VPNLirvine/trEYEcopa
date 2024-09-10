function newPosData = interpPosition(oldPosData)
% Given the name of a video, preprocesses the position data
% The data provided by asgordon does not fit the actual videos:
% the videos have a few seconds of freeze-frame added on either end.
% Here I rescale the position vectors over time to fit the videos,
% which involves some simple motion detection.

% Ideally you would only pass in a single row of data, but just in case...
numMovies = height(oldPosData);
pths = specifyPaths('..');
for m = 1:numMovies
    movName = oldPosData.StimName{m};

    % First see if we can bypass these slow processing steps
    chname = fullfile(pths.pos, [movName '.mat']);
    if exist(chname, 'file')
        newPosData = importdata(chname);
    else
        % Do some temporal rescaling of the position data:
        % It exists at some unknown framerate that doesn't match the video.
        % It also includes a variable amount of dead air time
        % So find the first and final video frame of motion,
        % find the first and final position frame of motion,
        % line those points up, interpolate between, and pad the ends out.
    
        % Get the start and end FRAMES
        [dfFrames, numFrames] = findDifferentFrames(movName);
        dfFrames = dfFrames.FrameRange;
    
        % Get the start and end POSITIONS
        dfPosition = findDifferentPositions(oldPosData);
        
        % Now use those two variables to line up the videos with the positions
        tlead = dfFrames(1);
        tlag = dfFrames(2);
        plead = dfPosition(1);
        plag = dfPosition(2);
    
        % Stretch the position data to match the spacing of the video data
        % numCoords = length(posData.X1_Values{m});
        numGoodCoords = length(plead:plag);
        numGoodFrames = length(tlead:tlag);
        oldspacing = 1:numGoodCoords;
        newspacing = linspace(1,numGoodCoords, numGoodFrames);
        
        % Fill the 'leading' frames with the first position value
        newPosData.X1_Values{1}(1:tlead) = oldPosData.X1_Values{m}(1);
        newPosData.Y1_Values{1}(1:tlead) = oldPosData.Y1_Values{m}(1);
        newPosData.X2_Values{1}(1:tlead) = oldPosData.X2_Values{m}(1);
        newPosData.Y2_Values{1}(1:tlead) = oldPosData.Y2_Values{m}(1);
        newPosData.X3_Values{1}(1:tlead) = oldPosData.X3_Values{m}(1);
        newPosData.Y3_Values{1}(1:tlead) = oldPosData.Y3_Values{m}(1);
        newPosData.X4_Values{1}(1:tlead) = oldPosData.X4_Values{m}(1);
        newPosData.Y4_Values{1}(1:tlead) = oldPosData.Y4_Values{m}(1);
        
        % Fill the 'middle' frames with the actual data
        % interpolate values to fit the length, then rescale to fit size
        newPosData.X1_Values{1}(tlead:tlag) = interp1(oldspacing, oldPosData.X1_Values{m}(plead:plag), newspacing);
        newPosData.Y1_Values{1}(tlead:tlag) = interp1(oldspacing, oldPosData.Y1_Values{m}(plead:plag), newspacing);
        newPosData.X2_Values{1}(tlead:tlag) = interp1(oldspacing, oldPosData.X2_Values{m}(plead:plag), newspacing);
        newPosData.Y2_Values{1}(tlead:tlag) = interp1(oldspacing, oldPosData.Y2_Values{m}(plead:plag), newspacing);
        newPosData.X3_Values{1}(tlead:tlag) = interp1(oldspacing, oldPosData.X3_Values{m}(plead:plag), newspacing);
        newPosData.Y3_Values{1}(tlead:tlag) = interp1(oldspacing, oldPosData.Y3_Values{m}(plead:plag), newspacing);
        newPosData.X4_Values{1}(tlead:tlag) = interp1(oldspacing, oldPosData.X4_Values{m}(plead:plag), newspacing);
        newPosData.Y4_Values{1}(tlead:tlag) = interp1(oldspacing, oldPosData.Y4_Values{m}(plead:plag), newspacing);
        
        % Fill the 'lagging' frames with the final position value
        newPosData.X1_Values{1}(tlag:numFrames) = oldPosData.X1_Values{m}(end);
        newPosData.Y1_Values{1}(tlag:numFrames) = oldPosData.Y1_Values{m}(end);
        newPosData.X2_Values{1}(tlag:numFrames) = oldPosData.X2_Values{m}(end);
        newPosData.Y2_Values{1}(tlag:numFrames) = oldPosData.Y2_Values{m}(end);
        newPosData.X3_Values{1}(tlag:numFrames) = oldPosData.X3_Values{m}(end);
        newPosData.Y3_Values{1}(tlag:numFrames) = oldPosData.Y3_Values{m}(end);
        newPosData.X4_Values{1}(tlag:numFrames) = oldPosData.X4_Values{m}(end);
        newPosData.Y4_Values{1}(tlag:numFrames) = oldPosData.Y4_Values{m}(end);
    end 
end