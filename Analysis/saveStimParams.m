function stimParams = saveStimParams(stimSet)
if nargin > 0
    assert(strcmp(stimSet, 'TC') | strcmp(stimSet, 'MW'), 'Input must be ''TC'' or ''MW''');
else
    stimSet = 'TC'; % by default
end


% Orient yourself to the folder structure
[b,~,~] = fileparts(which('specifyPaths'));
addpath(b);
pths = specifyPaths(b);

if strcmp(stimSet, 'TC')
    in = fullfile(pths.TCstim, 'normal');
elseif strcmp(stimSet, 'MW')
    in = fullfile(pths.MWstim);
end

% Scan the stimulus folder for video files
vlist = dir(fullfile(in, '*.mov'));
numVids = size(vlist, 1);

% Init output vars
StimName = cell(numVids, 1);
Duration = zeros(numVids,1);
FR = zeros(numVids,1);
NumFrames = zeros(numVids,1);

for i = 1:numVids
    vname = vlist(i).name;
    fprintf(1,'%i: %s\n',i, vname);
    vpath = fullfile(in, vname);
    vid = VideoReader(vpath);
    StimName{i} = vname;
    Duration(i) = vid.Duration;
    FR(i) = vid.FrameRate;
    NumFrames(i) = vid.NumFrames;
    clear vid
end
stimParams = table(StimName, Duration, FR, NumFrames);

% Export to disk
fout = fullfile(pths.analysis,[stimSet 'stimParams.mat']);
save(fout, "stimParams");

end % function