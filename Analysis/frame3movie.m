function varargout = frame3movie(movName)
    % Plays a stimulus video with position data overlaid
    % Input is the name of a video, e.g. 'Q100_6751_antisocial.mov'

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
    
%     pos = [[scw/2 - imw/2, scw/2 + imw/2], [sch/2 - imh/2, sch/2 + imh/2]];  % Position of the image
    pos = [1 1 imw imh];
    
    % Get the position data and rescale it to fit the plot size
    posData = getPosition(movName);
    posData = interpPosition(posData);
    posDat = rescalePosition(posData, pos);
    posDat = postab2struct(posDat);
    
    % Set up image
        figure();
        ax = gca;  % Get the current axes
        ax.YDir = 'reverse';  % Reverse the y-axis direction
        ax.Units = 'pixels';  % Set the units of the axes to pixels
        i = 1;
        title(movName);
        h0 = image([pos(1), pos(3)], [pos(2), pos(4)], frames(:,:,:,i));
        hold on;
        h1 = plot(posDat(1).X(i), posDat(1).Y(i), '^', 'MarkerFaceColor', 'r', 'MarkerSize', 40);
        h2 = plot(posDat(2).X(i), posDat(2).Y(i), 'o', 'MarkerFaceColor', 'b', 'MarkerSize', 30);
        h3 = plot(posDat(3).X(i), posDat(3).Y(i), '+', 'MarkerFaceColor', 'g', 'MarkerSize', 30);
        h4 = plot(posDat(4).X(i), posDat(4).Y(i), '^', 'MarkerFaceColor', 'c', 'MarkerSize', 30);
        hold off;
    titxt = strrep(movName, '_', '\_');
    % Now animate in a new loop
    tic
    for i = 2:numFrames
        h0.CData = frames(:,:,:,i);
        h1.XData = posDat(1).X(i);
        h1.YData = posDat(1).Y(i);
        h2.XData = posDat(2).X(i);
        h2.YData = posDat(2).Y(i);
        h3.XData = posDat(3).X(i);
        h3.YData = posDat(3).Y(i);
        h4.XData = posDat(4).X(i);
        h4.YData = posDat(4).Y(i);
        title(titxt);
        drawnow;
%         pause(1/15); % compensate for frame rate
        pause(1/60);
    end
    
    toc  % Display the elapsed time
    close all  % Close all figures
    clear frames % in case it doesn't automatically

    % Allow export of interpolated position data
    % Do it from this function since you need to watch to verify it's fixed
    % DON'T export the rescaled version! Keep it at standard 4000x3000
    if nargout > 0
        varargout{1} = posData;
    end
end
