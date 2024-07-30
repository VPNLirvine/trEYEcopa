function N = NSS(data)
% Normalized Scanpath Saliency
% For each trial in a table of data,
% determine similarity of the scanpath to an N-1 group "average" scanpath.
% Computes a group "heatpath" in sliding windows to save memory.

% Parameters:
sigX = deg2pix(1.2); % 1.2 deg from Dorr et al (2010)
sigY = sigX;
sigT = 26.25; % msec - also from Dorr et al (2010)
gaussDenom = 2*(sigX^2 + sigY^2 + sigT^2);
winSz = 225; % msec
stpSz = 25; % msec
scSz = [1200 1920]; % screen size in experiment

vidList = unique(data.StimName);

for v = 1:length(vidList)
    vidName = vidList{v};

    % Grab all scanpaths for this video
    datSubset = data(strcmp(data.StimName, vidName), :);
    % Interpolate them all into a common time domain,
    % since sample rate etc may vary.
    datSubset = fixTiming(datSubset);

    % Determine the number of windows that fit the time domain
    % After interpolation, this is constant for all subs with this video
    timeVec = datSubset.Eyetrack{1}(3,:);
    numWindows = ceil((max(timeVec) - winSz - stpSz) / stpSz);
    sl = 1:height(datSubset);
    for s = sl
        % Determine which row of the output this goes in
        subID = datSubset.Subject(s);
        outInd = strcmp(subID, data.Subject) & strcmp(vidName, data.StimName);

        % Leave one subject out and aggregate the rest together
        others = sl(sl~=s); % the subs that are not this one
        leftOut = datSubset.Eyetrack{s};
        probMap = []; % init
        
        for j = 1:numWindows
            % G(i,j,1:2,:) = exp(-((xbar(1:2,:) - xi(1:2,:))^2/(2*(sigX^2 + sigY^2 + sigT^2))));
            % G = exp(-((xj(1:2,:) - xi(1:2,:)).^2/(2*(sigX^2 + sigY^2 + sigT^2))));
            % G = exp(-(([960;600] - xi(1:2,:)).^2/(2*(sigX^2 + sigY^2 + sigT^2))));
            % G(:,:,j) = exp(-((xi(:,:) - xi(:,j)).^2/gaussDenom));
            % G = G + xi(1:2,:); % ?
            % G(:,:,j) = G(:,:,j) .* xi
            
            % Domain of this time window
            t = (stpSz * (j - 1)):(winSz + stpSz * (j - 1));
            % Which data indices fall within this window?
            toUse = ismember(timeVec, t);
            numTs = sum(toUse);
            % Spacing and kernel
            tSpace = (max(timeVec(toUse)) - min(timeVec(toUse))) / sum(toUse);
            sigma = [sigY, sigX, sigT / tSpace];

            % Initialize a 3D brick that just covers this time window
            brick = zeros(bs);
            % Fill it with smoothed data from every N-1 subject
            for i = others
                fprintf(1,'%i\n', i);
                gazeSnip = round(single(datSubset.Eyetrack{i}(:,toUse)));
                % Convert to 3D
                brick2 = zeros([scSz, numTs]);
                brick2(gazeSnip(2,:), gazeSnip(1,:)) = 1; % y is vert = row
                % Now smooth it... somehow

                % for k = 1:numTs
                %     % This still doesn't smooth over time, though
                %     % brick2(:,:,k) = imgaussfilt(brick2(:,:,k), round(sigX));
                %     % G = exp(-((round(bs / 2)' - gazeSnip).^2/gaussDenom));
                %     G = exp(-((gazeSnip - gazeSnip(:,k)).^2/gaussDenom));
                % end
                % (imgaussfilt3 is PAINFULLY slow, use something else)
                brick2 = imgaussfilt3(brick2, sigma);
                % brick2 = G .* exp(-((X-gazeSnip(1,:)).^2/(2*sigX^2) + (Y-gazeSnip(2,:)).^2/(2*sigY^2)));
                % Add to group map
                brick = brick + brick2;
            end
            % Normalize the brick
            brick = zscore(brick);
            % Now use the left-out data to index from the brick
            x = round(leftOut(1, toUse));
            y = round(leftOut(2, toUse));
            z = 1:numTs;
            ind = sub2ind(size(brick2), x, y, z);
            % This is this subject's gaze "probability" timeseries
            % Plug it into a larger vector that covers all time windows
            probMap(toUse) = brick2(ind);
            % Discard the bricks to save memory
        end
        data.Eyetrack{outInd} = probMap;
    end
    fprintf(1, 'Done with video %i of %i\n', v, length(vidList));
end