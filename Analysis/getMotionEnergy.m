function motion = getMotionEnergy(varargin)
% Reads all videos in a folder, analyzes motion, returns a param/video.
% Input 1 is the name of the motion parameter you want:
%   'eng' is motion energy, i.e. total optic flow: 1 value per frame
%   'loc' is the pixel location of peak motion energy: XY per frame
%   'map' is a 2D heatmap of motion energy: represents entire video
% Input 2 is 'TC' or 'MW' to determine which video set to analyze

if nargin > 0
    mtype = varargin{1};
    assert(ischar(mtype), 'Input 1 must be either ''loc'', ''map'', or ''eng''');
    assert(any(strcmp(mtype, {'loc', 'eng', 'map'})), 'Input must be either ''loc'', ''map'', or ''eng''');
else
    mtype = 'eng';
end

% Determine which stimulus set to consider
pths = specifyPaths('..');
if nargin > 1
    stype = varargin{2};
    assert(any(strcmp(stype, {'TC', 'MW'})), 'Input 2 must be either ''TC'' or ''MW'' (all caps)');
else
    stype = 'TC'; % default
end
switch stype
    case 'TC'
        stimDir = fullfile(pths.TCstim, 'normal');
    case 'MW'
        stimDir = pths.MWstim;
    otherwise
        error('Incorrect stimulus type detected! Must be either MW or TC')
end
stimList = dir(fullfile(stimDir, '*.mov')); % ignore any CSVs in there
numStims = length(stimList);

motion = table('Size', [numStims, 2], 'VariableTypes', {'string', 'cell'}, 'VariableNames', {'StimName', 'MotionEnergy'}); % init

fprintf(1, 'Getting motion data for %i videos.\n', numStims)
for s = 1:numStims
    fprintf(1, '\t%i\n', s);
    stimName = stimList(s).name;
    fname = findVidPath(stimName);
    motionVec = findMotionEnergy(fname, mtype);
    if strcmp(mtype, 'map')
        % Save each map as an individual file,
        % since they are each several GB uncompressed
        % Requires an argument specifying a newer format (c. R2006b)
        [~,x,~] = fileparts(stimName);
        fout = [x, '.mat'];
        save(fullfile(pths.map, fout), 'motionVec', '-v7.3');
    else
        [~,motion.StimName{s},~] = fileparts(stimName); % drop file extension
        motion.MotionEnergy{s} = motionVec;
        motion.Duration{s} = getVideoDuration(fname);
    end

end
fprintf(1, 'Done.\n');

% Save to disk, since this takes ~45 minutes to calculate
if strcmp(mtype, 'eng')
    fout = fullfile(pths.mot, [stype, '_motionData.mat']);
    save(fout, 'motion');
elseif strcmp(mtype, 'loc')
    fout = fullfile(pths.mot, [stype, '_motionLocation.mat']);
    save(fout, 'motion'); 
end
