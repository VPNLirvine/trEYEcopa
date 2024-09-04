function posDat = resizePosition(movfName, varargin)
    % Given the name of a video, preprocesses the position data.
    % The data provided by asgordon does not fit the actual videos:
    % the videos have a few seconds of freeze-frame added on either end.
    % Here I rescale the position vectors over time to fit the videos.
    % An optional second input (defining a windowed area on the screen)
    % allows you to also rescale the position vectors over space,
    % so that the output will e.g. match a particular video resolution.
    % This is especially handy since the videos are not all the same res,
    % so a standardized output space allows better comparison.
    
    [~, movName, ~] = fileparts(movfName);

    if nargin > 1
        % Read in PTB size vector
        % This should have the x and y max values you want to rescale to
        pos = varargin{1};
    else
        % Default video size
        pos = [1 1 508 678];
    end
    % For the rescaled videos, during the experiment,
    % pos = [157.62 0 1762.4 1200];

    % Toggle a warning off while filling this table
    wns = warning('query', 'MATLAB:table:RowsAddedExistingVars');
    warning('off', 'MATLAB:table:RowsAddedExistingVars');

    posData = getPosition;
    posDat = posData([],:); % init empty output table
    m = strcmp(posData.StimName, movName);
    % Rescaling factors (since data is 4000x3000 instead of 678x508)
    xrs = (pos(3) - pos(1)) / 4000;
    yrs = (pos(4) - pos(2)) / 3000;
    
    % Now do some temporal rescaling of the position data:
    % It exists at some unknown framerate that doesn't match the video.
    % It also includes a variable amount of dead air time
    % So find the first and final video frame of motion,
    % find the first and final position frame of motion,
    % line those points up, interpolate between, and pad the ends out.

    % Get the start and end FRAMES
    [dfFrames, numFrames] = findDifferentFrames(movfName);
    % This gives every video - extract just this one.
    dfFrames = dfFrames.FrameRange;

    % Get the start and end POSITIONS
    dfPosition = findDifferentPositions(posData, m, xrs, yrs);
    
    % Now use those two variables to line up the videos with the positions
    tlead = dfFrames(1);
    tlag = dfFrames(2);
    plead = dfPosition(1);
    plag = dfPosition(2);

    % Rescale the position data to match the spacing of the video data
    % numCoords = length(posData.X1_Values{m});
    numGoodCoords = length(plead:plag);
    numGoodFrames = length(tlead:tlag);
    oldspacing = 1:numGoodCoords;
    newspacing = linspace(1,numGoodCoords, numGoodFrames);
    
    % Fill the 'leading' frames with the first position value
    posDat.X1_Values{1}(1:tlead) = posData.X1_Values{m}(1) .* xrs;
    posDat.Y1_Values{1}(1:tlead) = posData.Y1_Values{m}(1) .* yrs;
    posDat.R1_Values{1}(1:tlead) = posData.R1_Values{m}(1);
    posDat.X2_Values{1}(1:tlead) = posData.X2_Values{m}(1) .* xrs;
    posDat.Y2_Values{1}(1:tlead) = posData.Y2_Values{m}(1) .* yrs;
    posDat.R2_Values{1}(1:tlead) = posData.R2_Values{m}(1);
    posDat.X3_Values{1}(1:tlead) = posData.X3_Values{m}(1) .* xrs;
    posDat.Y3_Values{1}(1:tlead) = posData.Y3_Values{m}(1) .* yrs;
    posDat.R3_Values{1}(1:tlead) = posData.R3_Values{m}(1);
    posDat.X4_Values{1}(1:tlead) = posData.X4_Values{m}(1) .* xrs;
    posDat.Y4_Values{1}(1:tlead) = posData.Y4_Values{m}(1) .* yrs;
    posDat.R4_Values{1}(1:tlead) = posData.R4_Values{m}(1);
    
    % Fill the 'middle' frames with the actual data
    % interpolate values to fit the length, then rescale to fit size
    posDat.X1_Values{1}(tlead:tlag) = interp1(oldspacing, posData.X1_Values{m}(plead:plag), newspacing) .* xrs;
    posDat.Y1_Values{1}(tlead:tlag) = interp1(oldspacing, posData.Y1_Values{m}(plead:plag), newspacing) .* yrs;
    posDat.R1_Values{1}(tlead:tlag) = interp1(oldspacing, posData.R1_Values{m}(plead:plag), newspacing);
    posDat.X2_Values{1}(tlead:tlag) = interp1(oldspacing, posData.X2_Values{m}(plead:plag), newspacing) .* xrs;
    posDat.Y2_Values{1}(tlead:tlag) = interp1(oldspacing, posData.Y2_Values{m}(plead:plag), newspacing) .* yrs;
    posDat.R2_Values{1}(tlead:tlag) = interp1(oldspacing, posData.R2_Values{m}(plead:plag), newspacing);
    posDat.X3_Values{1}(tlead:tlag) = interp1(oldspacing, posData.X3_Values{m}(plead:plag), newspacing) .* xrs;
    posDat.Y3_Values{1}(tlead:tlag) = interp1(oldspacing, posData.Y3_Values{m}(plead:plag), newspacing) .* yrs;
    posDat.R3_Values{1}(tlead:tlag) = interp1(oldspacing, posData.R3_Values{m}(plead:plag), newspacing);
    posDat.X4_Values{1}(tlead:tlag) = interp1(oldspacing, posData.X4_Values{m}(plead:plag), newspacing) .* xrs;
    posDat.Y4_Values{1}(tlead:tlag) = interp1(oldspacing, posData.Y4_Values{m}(plead:plag), newspacing) .* yrs;
    posDat.R4_Values{1}(tlead:tlag) = interp1(oldspacing, posData.R4_Values{m}(plead:plag), newspacing);
    
    % Fill the 'lagging' frames with the final position value
    posDat.X1_Values{1}(tlag:numFrames) = posData.X1_Values{m}(end) .* xrs;
    posDat.Y1_Values{1}(tlag:numFrames) = posData.Y1_Values{m}(end) .* yrs;
    posDat.R1_Values{1}(tlag:numFrames) = posData.R1_Values{m}(end);
    posDat.X2_Values{1}(tlag:numFrames) = posData.X2_Values{m}(end) .* xrs;
    posDat.Y2_Values{1}(tlag:numFrames) = posData.Y2_Values{m}(end) .* yrs;
    posDat.R2_Values{1}(tlag:numFrames) = posData.R2_Values{m}(end);
    posDat.X3_Values{1}(tlag:numFrames) = posData.X3_Values{m}(end) .* xrs;
    posDat.Y3_Values{1}(tlag:numFrames) = posData.Y3_Values{m}(end) .* yrs;
    posDat.R3_Values{1}(tlag:numFrames) = posData.R3_Values{m}(end);
    posDat.X4_Values{1}(tlag:numFrames) = posData.X4_Values{m}(end) .* xrs;
    posDat.Y4_Values{1}(tlag:numFrames) = posData.Y4_Values{m}(end) .* yrs;
    posDat.R4_Values{1}(tlag:numFrames) = posData.R4_Values{m}(end);

    % Add in the other columns
    posDat.StimName{1} = posData.StimName{m};
    posDat.C1_Name{1} = posData.C1_Name{m};
    posDat.C2_Name{1} = posData.C2_Name{m};
    posDat.C3_Name{1} = posData.C3_Name{m};
    posDat.C4_Name{1} = posData.C4_Name{m};

    % Toggle warning back to its previous state
    warning(wns.state, 'MATLAB:table:RowsAddedExistingVars');