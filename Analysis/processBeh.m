function dat = processBeh(dat)
% Convert a lazily-created column to two meaningful ones
% Consider updating the experiment code to rectify this upstream

flipCheck = ['flipped' filesep 'f_'];
normCheck = ['normal' filesep];

numRows = size(dat, 1);
for i = 1:numRows
    txt = dat.StimName(i);
    
    % Check whether it's flipped or not
    if contains(txt, flipCheck)
        dat.StimName(i) = erase(txt, flipCheck);
        dat.Flipped(i) = true;
    elseif contains(txt, normCheck)
        dat.StimName(i) = erase(txt, normCheck);
        dat.Flipped(i) = false;
    else
        error('Cannot determine whether data in row %i was a flipped video or not!', i)
    end
end

end