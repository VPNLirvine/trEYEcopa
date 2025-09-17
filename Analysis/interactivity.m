function output = interactivity(varargin)
% Calculate the "interactivity" between characters in each video.
% Defined as the proportion of video time that 
% any two characters are within a minimum distance of each other.
% This is a stimulus parameter that does not vary by subject.

% Get position data for requested video(s)
% If input is empty, then grab all videos
if nargin > 0
    stimName = varargin{1};
    assert(ischar(stimName) || isstring(stimName), 'Input must be a video name!');
    % strip out extension and/or path:
    [~, stimName, ~] = fileparts(stimName);
    posData = getPosition(stimName);
else
    posData = getPosition(); % no input is different than empty input...
end

% Initialize output
numVids = height(posData);
output = table('Size', [numVids, 2], 'VariableTypes', {'cell', 'cell'}, 'VariableNames', {'StimName', 'Interactivity'});

% Now loop over all videos in posData
for v = 1:numVids
    % Subset table to just this video
    stimName = posData(v).StimName;
    posDat = posData(v).Data;
    % Get some stimulus parameters
    x = VideoReader(findVidPath(stimName));
    wRect = [0 0 1920 1200];
    Movx = x.Width;
    Movy = x.Height;
    pos = resizeVideo(Movx, Movy, wRect);
    clear x
    
    % Run some processing on the position data for the characters
    posDat = rescalePosition(posDat, pos);
    numChars = length(posDat);
    
    % Now we're ready to rock:
    % Interactivity is the proportion of time ANY two characters are
    % within some pixel-distance threshold
    % threshold = 500;
    threshold = deg2pix(5);
    
    % initialize the tally for this video 
    interactivity = zeros(1, length(posDat(1).X));
    
    % Check which characters actually move
    for i = 1:numChars
        use(i) = any(posDat(i).X ~= posDat(i).X(1)) || any(posDat(i).Y ~= posDat(i).Y(1));
    end

    %calculate pairwise distances
    for i = 1:length(posDat(1).X)%or is there any other way to extract frame length?
        if sum(use) < 2
            % If only one character ever moves, then by definition,
            % there is never a "social" interaction
            interactivity(i) = 0;
        else
            % Do pairwise distance comparisons between characters,
            % but exclude any "unused" characters
            validC = find(use);
            X = []; Y = [];
            for j = 1:length(validC)
                X(j) = posDat(validC(j)).X(i);
                Y(j) = posDat(validC(j)).Y(i);
            end
            coords = [X(:), Y(:)];
            dist = pdist(coords, 'euclidean');

            % If the minimum distance is below the threshold,
            % mark as an interaction
            if min(dist) < threshold
                interactivity(i) = 1; 
            else
                interactivity(i) = 0; 
            end
        end
    end

    % Final calculation is a proportion: sum non-zero over duration
    output.StimName{v} = stimName;
    % output.Interactivity(v) = nnz(interactivity)/length(interactivity);
    output.Interactivity{v} = interactivity;

end % for video

end % function