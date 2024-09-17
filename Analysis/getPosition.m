function data = getPosition(movName)
% Import the XY position data from all TriCOPA videos as a table
% Reads from a specific CSV file
% Optional input of video name will just return data for that video

q1 = warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
q2 = warning('off', 'MATLAB:table:RowsAddedExistingVars');

tmp = readtable('TriCOPA-animations.csv');
tmp = sortrows(tmp); % not sure what order this was supposed to be in
numTrials = height(tmp);
assert(numTrials == 100, 'Error importing TriCOPA position data - less than the expected 100 entries found!');

data = table();
for i = 1:numTrials
    % Recreate filename
    t = erase(tmp.Performance_Label_ID{i}, 'COPA ');
    t = replace(t, ' ', '_');
    if strcmp(t(end), '_')
        % Drop any trailing underscore
        % Results from the poorly-made CSV having a space in the filename
        t = t(1:end-1);
    end
    data.StimName{i} = replace(t, '-', sprintf('_%i_', tmp.Performance_ID(i)));
    % Catch special cases:
    flag = 0;
    if contains(t, 'Q9_')
        flag = 9;
    elseif contains(t, 'Q31')
        data.StimName{i} = 'Q31_6674_talk_hug'; % not talk_and_hug
    elseif contains(t, 'Q33')
        flag = 33;
    elseif contains(t, 'Q29')
        data.StimName{i} = 'Q29_6672_hide_follow'; % not moving_away
    elseif contains(t, 'Q51')
        data.StimName{i} = 'Q51_6694_attack'; % not 6695
    elseif contains(t, 'Q60-racing')
        data.StimName{i} = 'Q59_6703_racing'; % Q59 not Q60
    elseif contains(t, 'Q68')
        flag = 68;
    elseif contains(t, 'Q71')
        % Actually aligns with the video for Q72
        data.StimName{i} = 'Q72_6717_kidnap';
    elseif contains(t, 'Q72')
        % Nothing matches this video, but bc of above, swap Q72 w Q71.
        data.StimName{i} = 'Q71_6716_knock_and_hide';
    elseif contains(t, 'Q79')
        data.StimName{i} = 'Q79_6726_jelous_dance'; % video is misspelled
    end
    
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
        % Except this just gives the unmoving fulcrum
        % So let's calculate the location of the swinging endpoint
        [data.X3_Values{i}, data.Y3_Values{i}] = rotateDoor(data.X3_Values{i}, data.Y3_Values{i}, data.R3_Values{i});
    % Character 4 - littleTriangle
    data.C4_Name{i} = ch{4};
    data.X4_Values{i} = str2num(tmp.X4_Values{i});
    data.Y4_Values{i} = str2num(tmp.Y4_Values{i});
    data.R4_Values{i} = str2num(tmp.R4_Values{i});

    % special cases
    % Needed when the video jumps a bit at the beginning,
        % but the positions drift over the same period,
        % so here we set the positions to jump too.
    if flag == 9
        data.X2_Values{i}(1:46) = data.X2_Values{i}(1);
        data.Y2_Values{i}(1:46) = data.Y2_Values{i}(1);
        data.R2_Values{i}(1:46) = data.R2_Values{i}(1);
    elseif flag == 33
        data.X2_Values{i}(1:50) = data.X2_Values{i}(1);
        data.Y2_Values{i}(1:50) = data.Y2_Values{i}(1);
        data.R2_Values{i}(1:50) = data.R2_Values{i}(1);
    elseif flag == 68
        data.X4_Values{i}(1:14) = data.X4_Values{i}(1);
        data.Y4_Values{i}(1:14) = data.Y4_Values{i}(1);
        data.R4_Values{i}(1:14) = data.R4_Values{i}(1);
    end
end % for each trial
warning(q2.state, 'MATLAB:table:RowsAddedExistingVars');
warning(q1.state, 'MATLAB:table:ModifiedAndSavedVarnames');

if nargin > 0
    % Subset to the selected video
    m = strcmp(data.StimName, movName);
    data = data(m,:);
end

end % function