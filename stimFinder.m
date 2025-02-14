function [stimPath, outputPath, stimList, prefix] = stimFinder(subID, in)
%% Ask user which experiment is desired and outputs moviePath, outputPath, and vidList associated with the experiment

pths = specifyPaths();
switch in
    case '1'
        % TriCOPA
        stimPath = pths.TCstim;
        outputPath = pths.TCdat; 
        prefix = 'TC_';
        
        % 2nd input will force subset to a predefined list of ~31 videos
        % to use the standard list, just do RandomTC(subID)
        stimList = RandomTC(subID, 1);
    case '2'
        % Martin & Weisberg
        stimPath = pths.MWstim;
        outputPath = pths.MWdat;
        prefix = 'MW_';
        
        stimList = RandomMS(subID);
        
    otherwise
        error("Invalid input! program terminated.") 
end


if ~exist(outputPath, 'dir')
    mkdir(outputPath)
end

    


end

