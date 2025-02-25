function watchData(movName, gaze, prediction)
    % Plays a stimulus video with gaze data overlaid,
    % and optionally with the predicted gaze data as well.
    % Input 1 is the name of a video, e.g. 'Q100_6751_antisocial.mov'
    % Input 2 is a 4*n gaze vector that must include frame indices
    % (Optional) Input 3 is a prediction vector of similar size
    
    if nargin > 2 && islogical(prediction)
        % Optionally allow a logical that fetches the proper gaze
        prediction = motionDeviation(gaze, movName);
    end

    numSamples = width(gaze);
    frameIdx = gaze(4,:);
    sr = diff(gaze(3,1:2)) / 1000;
    % Load in the video data
    movFName = findVidPath(movName);
    [~,movName,~] = fileparts(movFName); % ensure no extension attached
    fprintf(1, 'Loading frames...');
    thisVid = VideoReader(movFName);
    frames = read(thisVid);
    fprintf(1, 'Done.\n');

    % Get the dimensions of the video
    imh = thisVid.Height;
    imw = thisVid.Width;
    numFrames = size(frames,4);
    clear thisVid % release memory

%     scVec = get(0, 'ScreenSize');  % Get the screen size
    scVec = [1,1,1920,1200]; % size of stimulus monitor
    scw = scVec(3);
    sch = scVec(4);
    
    % pos = [[scw/2 - imw/2, scw/2 + imw/2], [sch/2 - imh/2, sch/2 + imh/2]];  % Position of the image
    % pos = [1 1 imw imh];
    pos = resizeVideo(imw, imh, scVec);
    
    
    % Set up image
        figure();
        ax = gca;  % Get the current axes
        ax.YDir = 'reverse';  % Reverse the y-axis direction
        ax.Units = 'pixels';  % Set the units of the axes to pixels
        i = 1;
        title(movName);
        h0 = image([pos(1), pos(3)], [pos(2), pos(4)], frames(:,:,:,i));
        hold on;
        h1 = scatter(gaze(1,i), gaze(2,i), (10*.7)^2, 'o', 'MarkerFaceColor', 'r');
        if nargin > 2
            h2 = scatter(prediction(1,i), prediction(2,i), (deg2pix(3) * .7)^2, 'o', 'MarkerFaceColor', 'b');
        end
        h2.MarkerFaceAlpha = .2;
        hold off;
    titxt = strrep(movName, '_', '\_');
    % Now animate in a new loop
    tic
    for i = 2:numSamples
        f = frameIdx(i);
        h0.CData = frames(:,:,:,f);
        h1.XData = gaze(1,i);
        h1.YData = gaze(2,i);
        if nargin > 2
            h2.XData = prediction(1,i);
            h2.YData = prediction(2,i);
        end
        title(titxt);
        % drawnow;
        % pause(1/15); % compensate for frame rate
        pause(sr);
    end
    
    toc  % Display the elapsed time
    close all  % Close all figures
    clear frames % in case it doesn't automatically

end
