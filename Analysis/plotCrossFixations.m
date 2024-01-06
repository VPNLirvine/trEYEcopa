function plotCrossFixations(TrialsCellArray)
pths = specifyPaths('..');
if ~iscell(TrialsCellArray)
    TrialsCellArray = {TrialsCellArray};
end

imPath = pths.fixdat;
imFormat = '.png';

figure()
ax = gca;  % Get the current axes
ax.YDir = 'reverse';  % Reverse the y-axis direction
ax.Units = 'pixels';  % Set the units of the axes to pixels

% Load the frame and get its dimensions
imhndl = imread(strcat(imPath, '/', 'all_crosses',imFormat));
[imh, imw, ~] = size(imhndl);
scVec = get(0, 'ScreenSize');  % Get the screen size
scw = scVec(3);
sch = scVec(4);

% Position the image
pos = [[scw/2 - imw/2, scw/2 + imw/2], [sch/2 - imh/2, sch/2 + imh/2]];

% Display the frame
image([pos(1), pos(2)], [pos(3), pos(4)], imhndl)
hold on

% Control color of the output
Color = ["k","m","g"];

% Iterate over experiments
for j = 1:length(TrialsCellArray)
    
    Trials = TrialsCellArray{j};
    
    % Case controlled color
    color = Color(j);
    
    % Case random color
%     color = rand(1, 3);
    
    % Iterate over 1:9 crosses within each experiment
    for trialNum = 1:length(Trials)

        for fixNum = 1 :length(Trials(trialNum).Fixations.gavx)
            
            if Trials(trialNum).Fixations.time(fixNum) >= 100 % plot only fixations greater than 100 ms
            text(Trials(trialNum).Fixations.gavx(fixNum), Trials(trialNum).Fixations.gavy(fixNum), num2str(fixNum),'FontSize', 6,'Color',color);
            end
            
        end
        
    end % End of the loop that iterates over 1:9 crosses

    
end % End of the loop that iterates over experiments


end % End of the function

% function stimName = getStimName(Trials, trialNum)
% % Read in a list of all eyelink messages for one trial
% % Search for one referencing the stimulus name
% % Strip out everything but the stimulus name and return it
% stimName = Trials(trialNum).Events.message{2};
% % y = cellfun(@(x) contains(x,'!V TRIAL_VAR image '), list);
% % assert(sum(y) == 1, 'No message re video name found!');
% % stimName = list{y};
% %     stimName = erase(stimName, '!V TRIAL_VAR video_file ');
% stimName = erase(stimName, '!V TRIAL_VAR image ');
% stimName = erase(stimName, '.bmp');
% end % function
