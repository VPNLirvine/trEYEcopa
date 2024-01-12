function frame2movie(Trials, trialNum)
    % Plays a stimulus video with eyetracking data overlaid
    % Requires having run frameGenerator on the corresponding stimulus
    % Input Trials is the output of edfImport -  a single subject's data
    % trialNum is the trial number to view (e.g. 1, 2, etc)

    pths = specifyPaths('..');
    frameFormat = '.jpg';

    % Get location of the stimulus
    movName = getStimName(Trials(trialNum));  % List of movie names
    movName = [movName '.MOV']; % heh
    imPath = fullfile(pths.frames, movName);
    
    % Verify the frames we want to draw actually exist
    if ~exist(imPath, 'dir')
        fprintf(1, 'Must extract video frames first...\n');
        frameGenerator(movName);
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
        h1 = image([pos(1), pos(2)], [pos(3), pos(4)], frames(i).dat);
        hold on;
        h2 = plot(fixdat(i).X, fixdat(i).Y, 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', 10);
        hold off;
    
    % Now animate in a new loop
    tic
    for i = 2:numFrames
        h1.CData = frames(i).dat;
        h2.XData = fixdat(i).X;
        h2.YData = fixdat(i).Y;
        drawnow;
        pause(1/15); % compensate for frame rate
    end
    
    toc  % Display the elapsed time
    close all  % Close all figures
end
