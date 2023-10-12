function T = myTable(s)
header = ["MEC" , "SOC"];

for i = 1:length(s)
MEC(i,1) = sum(s(i).mecFixations);
SOC(i,1) = sum(s(i).socFixations);
end

T = table( MEC, SOC);

end