function scoreAQ = defineAQ()
% Generate a table that gives the valence and subscale for each AQ item
% This is a lookup table of 'correct' answers,
% intended to be used to score individual responses

scoreAQ = table();
scoreAQ.Question(1:50) = 1:50;


agrees = [2, 4, 5, 6, 7, 9, 12, 13, 16, 18, 19, 20, 21, 22,  23,  26,  33,  35,  39,  41,  42,  43,  45,  46];
disagrees = [1, 3, 8, 10, 11, 14, 15, 17, 24,  25,  27,  28,  29,  30,  31,  32,  34,  36,  37,  38,  40,  44, 47, 48, 49, 50];
socskill = [1,11,13,15,22,36,44,45, 47, 48];
attSwitch = [2,4,10,16,25,32,34, 37,43,46];
attDet = [5,6,9,12,19,23,28, 29,30,49];
comm = [7,17,18,26,27,31,33, 35,38,39];
imag = [3,8,14,20,21,24,40,41, 42,50];

scoreAQ.Valence(agrees) = {'Agree'};
scoreAQ.Valence(disagrees) = {'Disagree'};

scoreAQ.Subscale(socskill) = {'Social Skills'};
scoreAQ.Subscale(attSwitch) = {'Attention Switching'};
scoreAQ.Subscale(attDet) = {'Attention to Detail'};
scoreAQ.Subscale(comm) = {'Communication'};
scoreAQ.Subscale(imag) = {'Imagination'};

end