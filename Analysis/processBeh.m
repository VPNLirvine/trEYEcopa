function dat = processBeh(dat)
% Convert a lazily-created column to two meaningful ones
% Consider updating the experiment code to rectify this upstream

flipCheck = ['flipped' filesep 'f_'];
normCheck = ['normal' filesep];

numRows = size(dat, 1);
for i = 1:numRows
    txt = dat(i).StimName;
    
    % Check whether it's flipped or not
    if contains(txt, flipCheck)
        dat(i).StimName = erase(txt, flipCheck);
        dat(i).Flipped = true;
    elseif contains(txt, normCheck)
        dat(i).StimName = erase(txt, normCheck);
        dat(i).Flipped = false;
    else
        error('Cannot determine whether data in row %i was a flipped video or not!', i)
    end
end

end