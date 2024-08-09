function exportPosition()
% Export the position data in a non-hierarchical format, for Python etc.
% That means a separate file for every video, unfortunately.

% Load up the data in question
positions = getPosition;

% Make a safe place to store all these new files we're about to create
homedir = pwd;
mkdir posDat
cd('posDat');

% Set up header info for tables to write into
dheader = {'Frame', 'BigTriX', 'BigTriY', 'BigTriR', 'CircleX', 'CircleY', 'CircleR', 'DoorX', 'DoorY', 'DoorR', 'SmallTriX', 'SmallTriY', 'SmallTriR'};
dtypes = {'double','double','double','double','double','double','double','double','double','double','double','double','double'};

for i = 1:100
    fname = [positions.StimName{i} '.csv'];
    numRows = length(positions.X1_Values{i});
    data = table('Size', [numRows length(dheader)],'VariableNames', dheader, 'VariableTypes', dtypes);
    % Write each cell into new table as a col
    data.Frame = (1:numRows)';
    data.BigTriX = positions.X1_Values{i}(:);
    data.BigTriY = positions.Y1_Values{i}(:);
    data.BigTriR = positions.R1_Values{i}(:);
    data.CircleX = positions.X2_Values{i}(:);
    data.CircleY = positions.Y2_Values{i}(:);
    data.CircleR = positions.R2_Values{i}(:);
    data.DoorX = positions.X3_Values{i}(:);
    data.DoorY = positions.Y3_Values{i}(:);
    data.DoorR = positions.R3_Values{i}(:);
    data.SmallTriX = positions.X4_Values{i}(:);
    data.SmallTriY = positions.Y4_Values{i}(:);
    data.SmallTriR = positions.R4_Values{i}(:);
    % Export as a CSV
    writetable(data, fname);
end

cd(homedir);