function output = interactivity(edfDat, flipFlag)
% This is to be a case inside selectMetric,
% which means it should operate on a SINGLE ROW of an EDF file
% (i.e. one trial of one subject)
% The goal is now to calculate interactivity between characters

pths = specifyPaths('..');

% Extract the stim name from edfDat
stimName = getStimName(edfDat);
[~,stimName] = fileparts(stimName);
if flipFlag
    stimName = erase(stimName, 'f_');
end

wRect = [0 0 1920 1200];
Movx = 674;
Movy = 504;
pos = resizeVideo(Movx, Movy, wRect);

% Get and process the position data for the characters
posDat = getPosition(stimName);
posDat = interpPosition(posDat); %new position data
posDat = rescalePosition(posDat, pos);
posDat = postab2struct(posDat);%stucture format

% Interactivity will be defined as proportion of time
% See if min distance is lower than some threshold, I'm not sure what
% number to put here
threshold = 200;

% initialize it 
interactivity = zeros(1, length(posDat(1).X));

%calculate pairwise distances
for i = 1:length(posDat(1).X)%or is there any other way to extract frame length?
    % Extract positions for each character at each frame
    p1 = [posDat(1).X(i), posDat(1).Y(i)];
    p2 = [posDat(2).X(i), posDat(2).Y(i)];
    p3 = [posDat(4).X(i), posDat(4).Y(i)]; % Ignore C3 (door)
    
    d12 = sqrt((p1(1) - p2(1))^2 + (p1(2) - p2(2))^2);
    d13 = sqrt((p1(1) - p3(1))^2 + (p1(2) - p3(2))^2);
    d23 = sqrt((p2(1) - p3(1))^2 + (p2(2) - p3(2))^2);
    mindis = min([d12, d13, d23]);
    
    % If the minimum distance is below the threshold, mark as interactions
    if mindis < threshold
        interactivity(i) = 1; 
    else
        interactivity(i) = 0; 
    end
end
triTime = nnz(interactivity)/length(interactivity)
output = triTime; 

end 
