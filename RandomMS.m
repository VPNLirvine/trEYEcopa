function NewOrd = RandomMS(subID)
rng('default')
pths = specifyPaths();
csvPath = fullfile(pths.analysis, 'condition list - Sheet1.csv');
T = readtable(csvPath);
socCellArr = T.NAME(string(T.CONDITION) == 'social');
mecCellArr = T.NAME(string(T.CONDITION) == 'mechanical');

newsubID = str2double(subID); % convert the number to numerical format
rng(newsubID); % Seed RNG based on subject ID

% Determine stimulus order
Newsoc = socCellArr(randperm(length(socCellArr)));
Newmec = mecCellArr(randperm(length(mecCellArr)));
NewOrd = cell(1,length(Newsoc)+length(Newmec));

if rand <0.5
    for i = 1:length(Newsoc)
        NewOrd(2*i-1) = Newsoc(i);
        NewOrd(2*i) = Newmec(i);
    end

else
    for i = 1:length(Newsoc)
        NewOrd(2*i-1) = Newmec(i);
        NewOrd(2*i) = Newsoc(i);
    end
end


% NewOrd = cell2struct(NewOrd,{'name'});
end