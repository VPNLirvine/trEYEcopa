function [stimPath, outputPath, stimList, prefix] = stimFinder(subID, in)
%% Ask user which experiment is desired and outputs moviePath, outputPath, and vidList associated with the experiment

pths = specifyPaths();
switch in
    case '1'
        % TriCOPA
        stimPath = pths.TCstim;
        outputPath = pths.TCdat; 
        prefix = 'TC_';
        
        stimList = RandomTC(subID);
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

