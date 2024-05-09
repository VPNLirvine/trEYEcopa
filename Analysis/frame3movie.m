function frame3movie(movName)
    % Plays a stimulus video with position data overlaid
    % Requires having run frameGenerator on the corresponding stimulus
    % Input is the name of a video

    addpath('..'); % to allow specifyPaths to run
    pths = specifyPaths('..');
    frameFormat = '.jpg';

    % Get location of the stimulus
    movFName = [movName '.MOV']; % heh
    imPath = fullfile(pths.frames, movFName);
    
    % Verify the frames we want to draw actually exist
    if ~exist(imPath, 'dir')
        fprintf(1, 'Must extract video frames first...\n');
        frameGenerator(movFName);
    end
    
    figure();
    ax = gca;  % Get the current axes
    ax.YDir = 'reverse';  % Reverse the y-axis direction
    ax.Units = 'pixels';  % Set the units of the axes to pixels
    
    % Load the first frame and get its dimensions
    imhndl = imread(fullfile(imPath, '1.jpg'));
    [imh, imw, ~] = size(imhndl);
%     scVec = get(0, 'ScreenSize');  % Get the screen size
    scVec = [1,1,1920,1200]; % size of stimulus monitor
    scw = scVec(3);
    sch = scVec(4);
    
    % Load up all the frames before drawing anything
    frameList = dir([imPath filesep '*' frameFormat]);
    numFrames = length(frameList);
    fprintf(1, 'Loading frames...');
    for f = numFrames:-1:1 % backward!
        frames(f).dat = imread([imPath filesep num2str(f) frameFormat]);
    end
    fprintf(1, 'Done.\n');
    
%     pos = [[scw/2 - imw/2, scw/2 + imw/2], [sch/2 - imh/2, sch/2 + imh/2]];  % Position of the image
    pos = [1 imw 1 imh];
    posData = getPosition;
    m = strcmp(posData.StimName, movName);
    % Rescaling factors (since data is 4000x3000 instead of 678x508)
    xrs = pos(2)/4000;
    yrs = pos(4)/3000;
    % Now do some temporal rescaling of the position data:
    % It exists at some unknown framerate that doesn't match the video.
    % It also includes a variable amount of dead air time
    % So find the first and final video frame of motion,
    % find the first and final position frame of motion,
    % line those points up, interpolate between, and pad the ends out.
    
    % Get the start and end FRAMES
    dfFrames = findDifferentFrames(movFName);
    % This gives every video - extract just this one.
    dfFrames = dfFrames.FrameRange;

    % Get the start and end POSITIONS
    dfPosition = findDifferentPositions(posData, m);
    
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
    posDat(1).X(1:tlead) = posData.X1_Values{m}(1) .* xrs;
    posDat(1).Y(1:tlead) = posData.Y1_Values{m}(1) .* yrs;
    posDat(2).X(1:tlead) = posData.X2_Values{m}(1) .* xrs;
    posDat(2).Y(1:tlead) = posData.Y2_Values{m}(1) .* yrs;
    posDat(3).X(1:tlead) = posData.X3_Values{m}(1) .* xrs;
    posDat(3).Y(1:tlead) = posData.Y3_Values{m}(1) .* yrs;
    posDat(4).X(1:tlead) = posData.X4_Values{m}(1) .* xrs;
    posDat(4).Y(1:tlead) = posData.Y4_Values{m}(1) .* yrs;
    
    % Fill the 'middle' frames with the actual data
    % interpolate values to fit the length, then rescale to fit size
    posDat(1).X(tlead:tlag) = interp1(oldspacing, posData.X1_Values{m}(plead:plag), newspacing) .* xrs;
    posDat(1).Y(tlead:tlag) = interp1(oldspacing, posData.Y1_Values{m}(plead:plag), newspacing) .* yrs;
    posDat(2).X(tlead:tlag) = interp1(oldspacing, posData.X2_Values{m}(plead:plag), newspacing) .* xrs;
    posDat(2).Y(tlead:tlag) = interp1(oldspacing, posData.Y2_Values{m}(plead:plag), newspacing) .* yrs;
    posDat(3).X(tlead:tlag) = interp1(oldspacing, posData.X3_Values{m}(plead:plag), newspacing) .* xrs;
    posDat(3).Y(tlead:tlag) = interp1(oldspacing, posData.Y3_Values{m}(plead:plag), newspacing) .* yrs;
    posDat(4).X(tlead:tlag) = interp1(oldspacing, posData.X4_Values{m}(plead:plag), newspacing) .* xrs;
    posDat(4).Y(tlead:tlag) = interp1(oldspacing, posData.Y4_Values{m}(plead:plag), newspacing) .* yrs;
    
    % Fill the 'lagging' frames with the final position value
    posDat(1).X(tlag:numFrames) = posData.X1_Values{m}(end) .* xrs;
    posDat(1).Y(tlag:numFrames) = posData.Y1_Values{m}(end) .* yrs;
    posDat(2).X(tlag:numFrames) = posData.X2_Values{m}(end) .* xrs;
    posDat(2).Y(tlag:numFrames) = posData.Y2_Values{m}(end) .* yrs;
    posDat(3).X(tlag:numFrames) = posData.X3_Values{m}(end) .* xrs;
    posDat(3).Y(tlag:numFrames) = posData.Y3_Values{m}(end) .* yrs;
    posDat(4).X(tlag:numFrames) = posData.X4_Values{m}(end) .* xrs;
    posDat(4).Y(tlag:numFrames) = posData.Y4_Values{m}(end) .* yrs;
    
    % Set up image
        i = 1;
        title(movName);
        h0 = image([pos(1), pos(2)], [pos(3), pos(4)], frames(i).dat);
        hold on;
        h1 = plot(posDat(1).X(i), posDat(1).Y(i), '^', 'MarkerFaceColor', 'r', 'MarkerSize', 40);
        h2 = plot(posDat(2).X(i), posDat(2).Y(i), 'o', 'MarkerFaceColor', 'b', 'MarkerSize', 30);
        h3 = plot(posDat(3).X(i), posDat(3).Y(i), '+', 'MarkerFaceColor', 'g', 'MarkerSize', 30);
        h4 = plot(posDat(4).X(i), posDat(4).Y(i), '^', 'MarkerFaceColor', 'c', 'MarkerSize', 30);
        hold off;
    
    % Now animate in a new loop
    tic
    for i = 2:numFrames
        h0.CData = frames(i).dat;
        h1.XData = posDat(1).X(i);
        h1.YData = posDat(1).Y(i);
        h2.XData = posDat(2).X(i);
        h2.YData = posDat(2).Y(i);
        h3.XData = posDat(3).X(i);
        h3.YData = posDat(3).Y(i);
        h4.XData = posDat(4).X(i);
        h4.YData = posDat(4).Y(i);
        drawnow;
%         pause(1/15); % compensate for frame rate
        pause(1/60);
    end
    
    toc  % Display the elapsed time
    close all  % Close all figures
end
