function intTable = getInteractivity(stype, itype)
% Gets the full vector of interactivity booleans per video
% This is essentially a wrapper for the existing interactivity() function.

assert(ismember(stype, {'TC', 'MW'}), 'Input 1 must indicate either TC or MW data');
assert(ismember(itype, {'vec', 'val'}), 'Input 2 must indicate either vec or val for interactivity (i.e. vector of booleans, or single value summary');
pths = specifyPaths('..');
switch itype
    case 'vec'
        fn = 'Vector';
    case 'val'
        fn = 'Data';
end
outputPath = fullfile(pths.int, append(stype, '_interact',fn,'.mat'));

if exist(outputPath, 'file')
    intTable = importdata(outputPath);
else
    fprintf(1, 'Calculating interactivity for %s...',stype);
    intTable = interactivity(stype, itype);
    fprintf(1, 'Done.\n');
    save(outputPath, 'intTable');
    fprintf(1, 'Exported to %s\n', outputPath);
end
