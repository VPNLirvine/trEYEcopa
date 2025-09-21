function output = interactivity(varargin)
% Calculate the "interactivity" between characters in each video.
% Defined as the proportion of video time that 
% any two characters are within a minimum distance of each other.
% This is a stimulus parameter that does not vary by subject.

% Get position data for requested video(s)
% If input is empty or a stimulus code (e.g. 'TC'), then grab all videos
if nargin > 0
    input = varargin{1};
    flag = nameOrType(input);
    switch flag
        case 'name'
            stimName = input;
            % strip out extension and/or path:
            [~, stimName, ~] = fileparts(stimName);
            posData = getPosition(stimName);
        case 'type'
            posData = getPosition(input);
    end
else
    posData = getPosition(); % no input is different than empty input...
end

% Whether to return vectors or values
if nargin > 1
    valid2 = {'vec', 'val'};
    outType = varargin{2};
    assert(any(strcmp(valid2, outType)), 'Second input must be either ''vec'' or ''val''');
else
    outType = 'val'; % default to a single value
end

% Initialize output
numVids = length(posData);
if strcmp(outType, 'val')
    % Use double
    output = table('Size', [numVids, 2], 'VariableTypes', {'cell', 'double'}, 'VariableNames', {'StimName', 'Interactivity'});
elseif strcmp(outType, 'vec')
    % Use cell
    output = table('Size', [numVids, 2], 'VariableTypes', {'cell', 'cell'}, 'VariableNames', {'StimName', 'Interactivity'});
end

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
    
    % initialize the tallies for this video 
    interactivity = zeros(1, length(posDat(1).X));
    use = zeros(1,numChars);
    
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

    % Set outputs
    output.StimName{v} = stimName;
    if strcmp(outType, 'val')
        % Final calculation is a proportion: sum non-zero over duration
        output.Interactivity(v) = nnz(interactivity)/length(interactivity);
    elseif strcmp(outType, 'vec')
        % No calculation, just output the entire binary vector.
        % This is useful for generating time-based predictors.
        output.Interactivity{v} = interactivity;
    end

end % for video

end % function