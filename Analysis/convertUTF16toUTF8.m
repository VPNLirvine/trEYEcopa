function convertUTF16toUTF8(inputFile, outputFile)
    % Check if the input file exists
    if exist(inputFile, 'file') ~= 2
        error('Input file does not exist.');
    end
    
    % Convert UTF-16 to UTF-8 using iconv
    command = sprintf('iconv -f UTF-16 -t UTF-8 "%s" > "%s"', inputFile, outputFile);
    [status, ~] = system(command);
    
    % Check if the conversion was successful
    if status ~= 0
        error('Error occurred during UTF-16 to UTF-8 conversion.');
    else
        disp('File converted successfully.');
    end
end