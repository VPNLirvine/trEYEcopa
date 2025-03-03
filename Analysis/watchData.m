function watchData(movName, gaze, prediction)
    % Plays a stimulus video with gaze data overlaid,
    % and optionally with the predicted gaze data as well.
    % Input 1 is the name of a video, e.g. 'Q100_6751_antisocial.mov'
    % Input 2 is a 4*n gaze vector that must include frame indices
    % (Optional) Input 3 is a prediction vector of similar size
    
    watchPred = false;
    if nargin > 2 && islogical(prediction) && prediction
        watchPred = true;
        % Optionally allow a logical that fetches the proper gaze
        prediction = motionDeviation(movName);
        % Convert to a mask
        for i = 1:size(prediction, 3)
            % Inside a loop bc otherwise it's 3D distance
            prediction(:,:,i) = bwdist(prediction(:,:,i));
        end
        prediction = prediction <= deg2pix(3);
    end

    numSamples = width(gaze);
    frameIdx = gaze(4,:);
    sr = diff(gaze(3,1:2)) / 1000;
    % Load in the video data
    movFName = findVidPath(movName);
    [~,movName,~] = fileparts(movFName); % ensure no extension attached
    fprintf(1, 'Loading frames...');
    thisVid = VideoReader(movFName);
    frame = readFrame(thisVid);
    fprintf(1, 'Done.\n');

    % Get the dimensions of the video
    imh = thisVid.Height;
    imw = thisVid.Width;
    % numFrames = size(frames,4);
    numFrames = thisVid.NumFrames;
    % clear thisVid % release memory

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
        h0 = image([pos(1), pos(3)], [pos(2), pos(4)], frame);
        hold on;
        if watchPred
            green = cat(3, zeros(size(prediction(:,:,1))), ones(size(prediction(:,:,1))), zeros(size(prediction(:,:,1))));
            h2 = image(green);
            set(h2, 'AlphaData', prediction(:,:,i));
            % h2 = scatter(prediction(1,i), prediction(2,i), (deg2pix(3) * .7)^2, 'o', 'MarkerFaceColor', 'b');
            % h2.MarkerFaceAlpha = .2;
        end
        h1 = scatter(gaze(1,i), gaze(2,i), (10*.7)^2, 'o', 'MarkerFaceColor', 'r');
        hold off;
    titxt = strrep(movName, '_', '\_');
    % Now animate in a new loop
    t = tic;
    lastFrame = i;
    for i = 2:numSamples
        f = frameIdx(i);
        if lastFrame < f
            h0.CData = readFrame(thisVid);
            lastFrame = lastFrame + 1;
        end
        % h0.CData = frames(:,:,:,f);
        % h0.CData = readFrame(thisVid);
        h1.XData = gaze(1,i);
        h1.YData = gaze(2,i);
        if watchPred
            % h2.XData = prediction(1,i);
            % h2.YData = prediction(2,i);
            set(h2, 'AlphaData', prediction(:,:,f) .* .5);
        end
        title(titxt);
        
        % Compensate for framerate
        if toc > sr
            drawnow;
            tic;
        end
        % drawnow limitrate;
        % pause(sr);
    end
    
    toc(t);  % Display the elapsed time
    close all  % Close all figures
    clear frames % in case it doesn't automatically

end
