%% Setup
pths = specifyPaths('..');
gazeDat = getTCData('gaze');
motionDat = importdata('motionData.mat');

%% Specifics
i = 274; % Which sub+video in gaze?
% Q11 is just one character moving:         try i = 2251 or 246
% Q13 is two characters moving together:    try i = 274
% Q57 has dynamics between all three:       try i = 292

% Subset data
stimName = gazeDat.StimName{i};
x = strcmp(motionDat.StimName, stimName); % find corresponding motion row
motion = motionDat.MotionEnergy{x};
gaze = gazeDat.Eyetrack{i};

% Compute successive distances between each gaze position,
% which is the hypotenuse of two coordinate pairs and the origin.
gaze = double(gaze);
p = gaze(1:2,:)';
% Don't care about actual Euclidean distances; more like a percent
% p(:,1) = p(:,1) / 4000;
% p(:,2) = p(:,2) / 3000;
% p(p > 1) = nan; % censor blinks
p(p > 5000) = nan; % assume values > screen diagonal are blinks, censor
gdiff = sqrt(sum(diff(p).^2,2)); % Get successive distances
gdiff = [0; gdiff]; % reinsert value for first frame (has 0 difference)
% gdiff = gdiff / max(gdiff, [], 'all'); % rescale
gdiff = gdiff / 50; % rescale by some extreme value

% Now plot this against the motion data to see how well it compares
figure();
t = (0:length(motion)-1) * (1000/60);
plot(t',motion);
hold on;
plot(gaze(3,:)',gdiff);
hold off;
ylim([0 1]);
title(strrep(stimName, '_', '\_'));
legend('Motion energy', 'Eye gaze energy');