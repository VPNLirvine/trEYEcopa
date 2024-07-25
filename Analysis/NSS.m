function N = NSS(data)
x = data.Eyetrack;
subList = unique(data.Subject);
vidList = unique(data.StimName);

% Parameters:
sigX = deg2pix(1.2); % 1.2 deg from Dorr et al (2010)
sigY = sigX;
sigT = 26.25; % msec - also from Dorr et al (2010)

for j = 1:length(vidList)
    vidName = vidList{j};

    % Get a group-average scanpath for this video
    datSubset = x(strcmp(data.StimName, vidName));
    [xj, timeV] = avgPath(datSubset);

    F = [];
    F(3,:) = timeV;

    for i = 1:length(datSubset)
        % Estimate a Gaussian for every Xij
        tmp = single(datSubset{i});
        % This must also be interpolated to fit the new time domain
        xij = [];
        xij(1,:) = interp1(tmp(3,:), tmp(1,:), timeV, 'linear', 'extrap');
        xij(2,:) = interp1(tmp(3,:), tmp(2,:), timeV, 'linear', 'extrap');
        xij(3,:) = timeV;

        % G(i,j,1:2,:) = exp(-((xj(1:2,:) - xij(1:2,:))^2/(2*(sigX^2 + sigY^2 + sigT^2))));
        G = exp(-((xj(1:2,:) - xij(1:2,:)).^2/(2*(sigX^2 + sigY^2 + sigT^2))));
        % G = G + xij(1:2,:); % ?
        F(1:2,:) = F(1:2,:) + G;
    end

    F(1:2,:) = zscore(F(1:2,:));
    N{j} = F;
    fprintf(1, 'Done with row %i of %i\n', j, length(vidList));
end