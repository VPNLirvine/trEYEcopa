function input = fixOutliers(input)
    % Drop elements with z-score > some threshold
    % This is quick and dirty in the absence of better guidance.
    input = double(input); % in case it's like uint8 or something
    threshold = 6; % conservative 6-sigma threshold. most people use 3
    scores = zscore(input);
    
%     % Alternative method: mean impute instead of dropping
%     good = input(scores <= threshold);
%     [~,mu] = zscore(good);
%     input(scores > threshold) = mu;

    input(scores > threshold) = [];
    input(scores < -threshold) = [];
end
    