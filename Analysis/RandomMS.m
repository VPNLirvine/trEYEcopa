function NewOrd = RandomMS()
T = readtable('condition list - Sheet1.csv');
socCellArr = T.NAME(string(T.CONDITION) == 'social');
mecCellArr = T.NAME(string(T.CONDITION) == 'mechanical');

ID = 9;
rng(ID); % Need input


Newsoc = socCellArr(randperm(length(socCellArr)));
Newmec = mecCellArr(randperm(length(mecCellArr)));
NewOrd = cell(1,length(Newsoc)+length(Newmec));

if rand <0.5
    for i = 1:length(Newsoc)
        NewOrd(2*i-1) = Newsoc{i};
        NewOrd(2*i) = Newmec{i};
    end

else
    for i = 1:length(Newsoc)
        NewOrd(2*i-1) = Newmec{i};
        NewOrd(2*i) = Newsoc{i};
    end
end

NewOrd = cell2struct(NewOrd,{'name'});


end