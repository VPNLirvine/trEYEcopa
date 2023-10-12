function frame2movie_2(Trials, trialNum)
try
    movLst = {'BASEBALL.MOV'};  % List of movie names
    imPath = strcat('/Users/vpnl/Documents/MATLAB/frames', '/', movLst{trialNum});
    frameFormat = '.jpg';
    
    figure(trialNum)
    ax = gca;  % Get the current axes
    ax.YDir = 'reverse';  % Reverse the y-axis direction
    ax.Units = 'pixels';  % Set the units of the axes to pixels
    
    % Load the first frame and get its dimensions
    imhndl = imread(strcat(imPath, '/', '1.jpg'));
    [imh, imw, ~] = size(imhndl);
    scVec = get(0, 'ScreenSize');  % Get the screen size
    scw = scVec(3);
    sch = scVec(4);
    
    frameNum = 0;  % Initialize frame number
    fixNum = 0;  % Initialize fixation number
    pos = [[scw/2 - imw/2, scw/2 + imw/2], [sch/2 - imh/2, sch/2 + imh/2]];  % Position of the image
    
    tic  % Start timing
    
    % Loop through each event in the trial
    for event = 1:length(Trials(trialNum).Events.message)
        
        % Check if the event message contains 'displayed' or if the event type is 7
        if contains(Trials(trialNum).Events.message{event},'displayed') || Trials(trialNum).Events.type(event) == 7
            frameNum = frameNum + contains(Trials(trialNum).Events.message{event},'displayed');  % Increment frame number if 'displayed' is found
            fixNum = fixNum + (Trials(trialNum).Events.type(event) == 7);  % Increment fixation number if event type is 7
        end
        
        if frameNum > 0
            frame = imread(strcat(imPath, '/', int2str(frameNum), frameFormat));  % Load the frame
            image([pos(1), pos(2)], [pos(3), pos(4)], frame)  % Display the frame
        end
        
        if fixNum > 0
            hold on
            plot(Trials(trialNum).Fixations.gavx(fixNum), Trials(trialNum).Fixations.gavy(fixNum), 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', 10)  % Plot the fixation position
            pause(0.00000001);  % Pause for a short time
        end
        cla  % Clear the current axes
        
    end
    
    toc  % Display the elapsed time
    close all  % Close all figures
    clear  % Clear variables
    
catch ME
    fprintf("%s\n%s\n%s\n", ME.identifier, ME.message, ME.Correction)
    close all  % Close all figures
    clear  % Clear variables
end
