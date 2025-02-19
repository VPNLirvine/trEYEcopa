function data = insertAQ(data)
% given Data, add the AQ subscales back in
aq = getAQ(specifyPaths('..'));

subList = unique(data.Subject);
numSubs = length(subList);
A1 = zeros(height(data),1);
A2 = zeros(height(data),1);
A3 = zeros(height(data),1);
for i = 1:numSubs
    subID = subList{i};
    subset = strcmp(subID, data.Subject);
    aqsubset = strcmp(subID, aq.SubID);
    A1(subset) = aq.SocialSkills(aqsubset);
    A2(subset) = aq.Communication(aqsubset);
    A3(subset) = aq.AttentionDetail(aqsubset);
end

data.SocialSkills = A1;
data.Communication = A2;
data.AttentionDetail = A3;