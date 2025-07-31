function stype = detectStimType(data)
% Given a table (or even just a row) of data from selectMetric,
% determine whether it comes from Martin & Weisberg or TriCOPA run
% by looking at the subject ID

sid = data.Subject{1};
stype = sid(1:2); % literally just the 
assert(any(strcmp(stype, {'MW', 'TC'})), 'Subject prefix ''%s'' did not match expected options TC or MW', stype)
