function flag = nameOrType(input)
% Checks whether an input string contains a stimulus name or 'type'
% e.g. the stim name "BASEBALL" belongs to stim type "MW"
% If you ask for 'MW', you probably want ALL MW videos.
% But 'MW' itself is not a video. So this interprets that input.

assert(ischar(input) || isstring(input), 'Input must be a string!');
typeList = {'MW', 'TC', 'NAR'};
if any(strcmp(typeList, input))
    flag = 'type';
else
    flag = 'name';
end
