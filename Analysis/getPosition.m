function data = getPosition()
% Import the XY position data from all TriCOPA videos as a table
% Reads from a specific CSV file

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
warning('off', 'MATLAB:table:RowsAddedExistingVars');

tmp = readtable('TriCOPA-animations.csv');
numTrials = height(tmp);
assert(numTrials == 100, 'Error importing TriCOPA position data - less than the expected 100 entries found!');

data = table();
for i = 1:numTrials
    % Recreate filename
    t = erase(tmp.Performance_Label_ID{i}, 'COPA ');
    t = replace(t, ' ', '_');
    data.StimName{i} = replace(t, '-', sprintf('_%i_', tmp.Performance_ID(i)));

    % Sort characters
    c = tmp{i,3}; c = c{:}; % from table to cell to string
    ch = strsplit(c, ' ');
    % Should be a cell with 'bigTriangle', 'circle', 'door', 'littleTriangle'
    % Character 1 - bigTriangle
    data.C1_Name{i} = ch{1};
    data.X1_Values{i} = str2num(tmp.X1_Values{i});
    data.Y1_Values{i} = str2num(tmp.Y1_Values{i});
    data.R1_Values{i} = str2num(tmp.R1_Values{i});
    % Character 2 - circle
    data.C2_Name{i} = ch{2};
    data.X2_Values{i} = str2num(tmp.X2_Values{i});
    data.Y2_Values{i} = str2num(tmp.Y2_Values{i});
    data.R2_Values{i} = str2num(tmp.R2_Values{i});
    % Character 3 - door
    data.C3_Name{i} = ch{3};
    data.X3_Values{i} = str2num(tmp.X3_Values{i});
    data.Y3_Values{i} = str2num(tmp.Y3_Values{i});
    data.R3_Values{i} = str2num(tmp.R3_Values{i});
    % Character 4 - littleTriangle
    data.C4_Name{i} = ch{4};
    data.X4_Values{i} = str2num(tmp.X4_Values{i});
    data.Y4_Values{i} = str2num(tmp.Y4_Values{i});
    data.R4_Values{i} = str2num(tmp.R4_Values{i});
end
warning('on', 'MATLAB:table:RowsAddedExistingVars');
warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
end % function