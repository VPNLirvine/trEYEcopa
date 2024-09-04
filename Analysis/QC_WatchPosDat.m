function QC_WatchPosDat(skip)
%% Verify Position Data
% Plays every video with the position data overlaid on top
% Intention is to log in some spreadsheet how well the two align

% Get list of videos
data = getPosition;
vidList = unique(data.StimName);
numVids = height(data);

if nargin == 0
    % Allow resuming
    skip = 1;
end

% Loop over every video
for i = skip:numVids
    % Play in frame3movie
    vidname = vidList{i};
    [~, vidname, ~] = fileparts(vidname); % strip out extension
    frame3movie(vidname);
    
    % Ask to continue or quit
    clc;
    x = input(sprintf('That was %i/%i %s. Keep going? y/n ', i, numVids, vidname), 's');
    if ~any(strcmpi(x, {'yes', 'y', ''}))
        break
    end
end