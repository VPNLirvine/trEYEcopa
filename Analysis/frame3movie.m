function frame3movie(movName)
    % Plays a stimulus video with position data overlaid
    % Requires having run frameGenerator on the corresponding stimulus
    % Input is the name of a video

    addpath('..'); % to allow specifyPaths to run
    pths = specifyPaths('..');
    frameFormat = '.jpg';

    % Get location of the stimulus
    if ~strcmpi(movName(end-3:end), '.mov')
        movFName = [movName '.MOV']; % heh
    else
        movFName = movName;
        movName = movFName(1:end-4);
    end
    imPath = fullfile(pths.frames, movFName);
    
    % Verify the frames we want to draw actually exist
    if ~exist(imPath, 'dir')
        fprintf(1, 'Must extract video frames first...\n');
        frameGenerator(movFName);
    end
    
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
    
    % Get the position data and rescale it to fit the plot size
    posDat = resizePosition(movFName, pos);
    
    % Set up image
        figure();
        ax = gca;  % Get the current axes
        ax.YDir = 'reverse';  % Reverse the y-axis direction
        ax.Units = 'pixels';  % Set the units of the axes to pixels
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
