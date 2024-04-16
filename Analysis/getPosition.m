function data = getPosition()
tmp = readtable('TriCOPA-animations.csv');
numTrials = height(tmp);
assert(numTrials == 100, 'Error importing TriCOPA position data - less than the expected 100 entries found!');

data = struct();
for i = 1:numTrials
    % Recreate filename
    t = erase(tmp.Performance_Label_ID{i}, 'COPA ');
    data(i).StimName = replace(t, '-', sprintf('_%i_', tmp.Performance_ID(i)));

    % Sort characters
    c = tmp{i,3}; c = c{:}; % from table to cell to string
    ch = strsplit(c, ' ');
    % Should be a cell with 'bigTriangle', 'circle', 'door', 'littleTriangle'
    % Character 1 - bigTriangle
    data(i).char(1).name = ch{1};
    data(i).char(1).x = str2num(tmp.X1_Values{i});
    data(i).char(1).y = str2num(tmp.Y1_Values{i});
    data(i).char(1).rot = str2num(tmp.R1_Values{i});
    % Character 2 - circle
    data(i).char(2).name = ch{2};
    data(i).char(2).x = str2num(tmp.X2_Values{i});
    data(i).char(2).y = str2num(tmp.Y2_Values{i});
    data(i).char(2).rot = str2num(tmp.R2_Values{i});
    % Character 3 - door
    data(i).char(3).name = ch{3};
    data(i).char(3).x = str2num(tmp.X3_Values{i});
    data(i).char(3).y = str2num(tmp.Y3_Values{i});
    data(i).char(3).rot = str2num(tmp.R3_Values{i});
    % Character 4 - littleTriangle
    data(i).char(4).name = ch{4};
    data(i).char(4).x = str2num(tmp.X4_Values{i});
    data(i).char(4).y = str2num(tmp.Y4_Values{i});
    data(i).char(4).rot = str2num(tmp.R4_Values{i});
end

end % function