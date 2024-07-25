data = getPosition;
numTrials = height(data);
stimList = unique(data.StimName);
for i = 1:numTrials
    movName = stimList{i};
    frame3movie(movName);
end