data = getPosition;
numTrials = height(data);
for i = 1:numTrials
    movName = data.StimName{i};
    frame3movie(movName);
end