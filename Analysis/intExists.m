function flag = intExists(mwflag, metricName)
% Determines whether you can use the 'interactivity' data.
% It specifically doesn't exist for non-social Martin & Weisberg videos
% So IGNORE interactivity if you need to analyze both MW conditions.
% Otherwise, use this flag to drop the mechanical videos from the data,
% or else you'll have a half-empty column of int data messing with results.

if mwflag
    useList = {'tot'}; % add more as needed
    if any(strcmp(metricName, useList))
        flag = true;
    else
        flag = false;
    end
else
    % e.g. if TriCOPA
    flag = true;
end