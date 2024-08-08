function scoreAQ = defineAQ()
% Generate a table that gives the valence and subscale for each AQ item
% This is a lookup table of 'correct' answers,
% intended to be used to score individual responses

scoreAQ = table();
scoreAQ.Question(1:50) = 1:50;

% Identify which questions are reverse-coded
agrees = [2, 4, 5, 6, 7, 9, 12, 13, 16, 18, 19, 20, 21, 22,  23,  26,  33,  35,  39,  41,  42,  43,  45,  46];
disagrees = [1, 3, 8, 10, 11, 14, 15, 17, 24,  25,  27,  28,  29,  30,  31,  32,  34,  36,  37,  38,  40,  44, 47, 48, 49, 50];
% Identify which questions belong to which subscale
socskill = [1,10,11,13,15,17,22,26,34,38,44,46,47]; % 13 total
comm = [20,27,31,35,36,39,45,48]; % 8 total
attDet = [5,6,9,12,19,23,41]; % 7 total
others = ~ismember(1:50, [attDet, comm, socskill]);

scoreAQ.Valence(agrees) = {'Agree'};
scoreAQ.Valence(disagrees) = {'Disagree'};

scoreAQ.Subscale(socskill) = {'Social Skills'};
scoreAQ.Subscale(comm) = {'Communication'};
scoreAQ.Subscale(attDet) = {'Attention to Detail'};
scoreAQ.Subscale(others) = {'Unused'};

end