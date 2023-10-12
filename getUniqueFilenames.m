function fOutList = getUniqueFilenames(fIn, In)

prefixOut = [];
for i = 1:size(fIn, 1)
    fNames = strsplit(fIn(i, :), '.');
    temp = strsplit(fNames{1}, '_');
    % out = strjoin(temp(1:In), '_'); %used for old stimuli -> exp: HH_2_100_89_rotate_90 & OO_1collision_1_rotate_180
    out = strjoin(temp(3:2+In), '_'); % for new stimuli -> exp: R_90_HH_2_100_73 & R_0_OO_1collision_11
    prefixOut = strvcat(prefixOut, out);
end
fOutList = unique(prefixOut, 'rows', 'legacy');
