function fname2 = verifyEncoding(fname)
% Ensure this file can be read by MATLAB
% Matlab 2019a can't read UTF-16, but it CAN read UTF-8
% So this checks the encoding of your input file and converts if necessary.

% First, see if this script has been run before
% If so, just export the name of the converted file.
fname2 = replace(fname, '.tsv', '_utf8.tsv');

if ~exist(fname2, 'file')
    % Perform conversion.
    % Read in file as byte numbers
    fid = fopen(fname, 'r');
    txt = fread(fid);
    fclose(fid);

    % Check that the "byte order" is [255 254] or [254 255]
    border = txt(1:2);
    % If so, it is UTF-16, so convert it.
    % If not, don't convert it, bc that will result in an empty file.
    if isequal(border,[255; 254]) || isequal(border, [254; 255])
        convertUTF16toUTF8(fname, fname2);
    else
        fname2 = fname;
        warning('Could not detect encoding scheme for file %s.\nAssuming it''s fine.', fname);
    end

end