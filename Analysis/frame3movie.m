function frame3movie(movName)
    % Plays a stimulus video with position data overlaid
    % Requires having run frameGenerator on the corresponding stimulus
    % Input is the name of a video
    
    Trials = [];
    trialNum = [];

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
    imhndl = imread(fullfile(impath, '1.jpg'));
    [imh, imw, ~] = size(imhndl);
    scVec = get(0, 'ScreenSize');  % Get the screen size
    scw = scVec(3);
    sch = scVec(4);
    
    % Load up all the frames before drawing anything
    frameList = dir([imPath filesep '*' frameFormat]);
    numFrames = length(frameList);
    for f = numFrames:-1:1 % backward!
        frames(f).dat = imread([imPath filesep num2str(f) frameFormat]);
    end
    
    frameNum = 0;  % Initialize frame number
    fixNum = 0;  % Initialize fixation number
    pos = [[scw/2 - imw/2, scw/2 + imw/2], [sch/2 - imh/2, sch/2 + imh/2]];  % Position of the image
    

    posData = getPosition;
    m = strcmp(posData.StimName, movName);
    posDat(1).X = posData.X1_Values(m);
    posDat(1).Y = posData.Y1_Values(m);
    posDat(2).X = posData.X2_Values(m);
    posDat(2).Y = posData.Y2_Values(m);
    posDat(3).X = posData.X3_Values(m);
    posDat(3).Y = posData.Y3_Values(m);
    posDat(4).X = posData.X4_Values(m);
    posDat(4).Y = posData.Y4_Values(m);
    fixdat = struct('X',[],'Y',[]); % init
    % Loop through each event in the trial
    for event = 1:length(Trials(trialNum).Events.message)
        % Check if the event message contains 'displayed' or if the event type is 7
        if contains(Trials(trialNum).Events.message{event},'displayed') || Trials(trialNum).Events.type(event) == 7
            frameNum = frameNum + contains(Trials(trialNum).Events.message{event},'displayed');  % Increment frame number if 'displayed' is found
            fixNum = fixNum + (Trials(trialNum).Events.type(event) == 7);  % Increment fixation number if event type is 7
            if frameNum == 0
                % Overwrite until you get a fixation
                fixdat(1).X = Trials(trialNum).Fixations.gavx(fixNum);
                fixdat(1).Y = Trials(trialNum).Fixations.gavy(fixNum);
            else
                % Get actual data
                fixdat(frameNum).X = Trials(trialNum).Fixations.gavx(fixNum);
                fixdat(frameNum).Y = Trials(trialNum).Fixations.gavy(fixNum);
            end
        end 
    end
    
    % Set up image
        i = 1;
        title(movName);
        h0 = image([pos(1), pos(2)], [pos(3), pos(4)], frames(i).dat);
        hold on;
        h1 = plot(posDat(1).X(i), posDat(1).Y(i), 'mo', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
        h2 = plot(posDat(2).X(i), posDat(2).Y(i), 'mo', 'MarkerFaceColor', 'g', 'MarkerSize', 10);
        h3 = plot(posDat(3).X(i), posDat(3).Y(i), 'mo', 'MarkerFaceColor', 'b', 'MarkerSize', 10);
        h4 = plot(posDat(4).X(i), posDat(4).Y(i), 'mo', 'MarkerFaceColor', 'c', 'MarkerSize', 10);
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
        pause(1/15); % compensate for frame rate
    end
    
    toc  % Display the elapsed time
    close all  % Close all figures
end
