function output = pickCoordData(data)
% EDF files split x coords and y coords into separate matrices
% And for whatever reason, those are 2-row matrices with a row of junk data
% And for whatever reason, it's inconsistent which row has the junk data
% But thankfully, the junk data is always the same
% So this function finds the junk data and skips it

assert(size(data,1) == 2, 'Input data is the wrong size! Expected a matrix with 2 rows.')
assert(size(data,2) > 0, 'Input data is empty!')

if data(1,1) == -32768
    output = data(2,:);
elseif data(2,1) == -32768
    output = data(1,:);
else
    error('Could not find any junk data to drop!')
end