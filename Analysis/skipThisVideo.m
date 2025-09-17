function flag = skipThisVideo(vidName, stimType)
% Determine whether to return a default value of some sort,
% or else actually run a calculation. For example, there is BY DEFINITION
% zero social interactivity in the M&W mechanical videos.
% So instead of trying to calculate it, just return a 0.

switch stimType
    case 'MW'
        % Check whether you've got a mechanical video
        T = readtable('MWConditionList.csv');
        mecCellArr = T.NAME(string(T.CONDITION) == 'mechanical');
        if contains(vidName, mecCellArr)
            flag = true;
        else
            flag = false;
        end
    case 'TC'
        % Don't skip any TriCOPA videos.
        flag = false;
    otherwise
        flag = false; % default
end