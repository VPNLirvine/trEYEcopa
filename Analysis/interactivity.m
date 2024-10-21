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
output = table('Size', [numVids, 2], 'VariableTypes', {'cell', 'double'}, 'VariableNames', {'StimName', 'Interactivity'});

% Now loop over all videos in posData
for v = 1:numVids
    % Subset table to just this video
    stimName = posData.StimName{v};
    posDat = posData(v,:);
    % Get some stimulus parameters
    x = VideoReader(findVidPath(stimName));
    wRect = [0 0 1920 1200];
    Movx = x.Width;
    Movy = x.Height;
    pos = resizeVideo(Movx, Movy, wRect);
    clear x
    
    % Run some processing on the position data for the characters
    posDat = interpPosition(posDat); %new position data
    posDat = rescalePosition(posDat, pos);
    posDat = postab2struct(posDat); %stucture format
    
    % Now we're ready to rock:
    % Interactivity is the proportion of time ANY two characters are
    % within some pixel-distance threshold
    threshold = 500;
    
    % initialize the tally for this video 
    interactivity = zeros(1, length(posDat(1).X));
    
    % Check which characters actually move
    use1 = any(posDat(1).X ~= posDat(1).X(1)) || any(posDat(1).Y ~= posDat(1).Y(1));
    use2 = any(posDat(2).X ~= posDat(2).X(1)) || any(posDat(2).Y ~= posDat(2).Y(1));
    use4 = any(posDat(4).X ~= posDat(4).X(1)) || any(posDat(4).Y ~= posDat(4).Y(1));

    %calculate pairwise distances
    for i = 1:length(posDat(1).X)%or is there any other way to extract frame length?
        if sum([use1, use2, use4]) < 2
            % If only one character ever moves, then by definition,
            % there is never a "social" interaction
            interactivity(i) = 0;
        else
            % Extract positions for each character at each frame
            p1 = [posDat(1).X(i), posDat(1).Y(i)];
            p2 = [posDat(2).X(i), posDat(2).Y(i)];
            p4 = [posDat(4).X(i), posDat(4).Y(i)]; % Ignore C3 (door)
            
            % Calculate pairwise distances
            d12 = sqrt((p1(1) - p2(1))^2 + (p1(2) - p2(2))^2);
            d14 = sqrt((p1(1) - p4(1))^2 + (p1(2) - p4(2))^2);
            d24 = sqrt((p2(1) - p4(1))^2 + (p2(2) - p4(2))^2);

            % Avoid considering distances between unused characters
            % (All characters were always on screen, but may never move)
            if ~use1
                d12 = threshold + 1; d14 = threshold + 1;
            end
            if ~use2
                d12 = threshold + 1; d24 = threshold + 1;
            end
            if ~use4
                d14 = threshold + 1; d24 = threshold + 1;
            end
            
            % If the minimum distance is below the threshold, mark as interactions
            mindis = min([d12, d14, d24]);
            if mindis < threshold
                interactivity(i) = 1; 
            else
                interactivity(i) = 0; 
            end
        end
    end

    % Final calculation is a proportion: sum non-zero over duration
    output.StimName{v} = [stimName '.mov'];
    output.Interactivity(v) = nnz(interactivity)/length(interactivity);

end % for video

end % function