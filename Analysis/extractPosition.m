function extractPosition(gTruth, vidName)
% Given the output of a Video Labeler session and a video name,
% sort the Label Data into the format used by getPosition,
% then export to file for later use.
q = warning('query', 'MATLAB:table:RowsAddedExistingVars');
try
    warning('off', 'MATLAB:table:RowsAddedExistingVars');
    
    numFrames = height(gTruth.LabelData);
    % Also need to rescale data to be at 4000x3000 like the rest
    [vidX, vidY] = getVideoSize(vidName);
    xrs = 4000 / vidX;
    yrs = 3000 / vidY;
    % Set up
    vnames = {'StimName', 'C1_Name', 'X1_Values', 'Y1_Values', 'R1_Values', 'C2_Name', 'X2_Values', 'Y2_Values', 'R2_Values', 'C3_Name', 'X3_Values', 'Y3_Values', 'R3_Values', 'C4_Name', 'X4_Values', 'Y4_Values', 'R4_Values'};
    vtypes = repmat({'cell'}, [1 numel(vnames)]);
    tsize = [0, length(vnames)];
    output = table('Size', tsize, 'VariableNames',vnames, 'VariableTypes', vtypes);
    
    % Insert constants
    output.StimName{1} = vidName;
    output.C1_Name{1} = 'bigTriangle';
    output.C2_Name{1} = 'circle';
    output.C3_Name{1} = 'door';
    output.C4_Name{1} = 'littleTriangle';
    
    % Execute algorithm
    for i = 1:numFrames
        % Extract values from gTruth
        bigtriXY = extractCenter(gTruth.LabelData.bigTriangle{i});
        circXY = extractCenter(gTruth.LabelData.circle{i});
        doorXY = extractCenter(gTruth.LabelData.door{i});
        littriXY = extractCenter(gTruth.LabelData.littleTriangle{i});
    
        % Insert each value individually, rescaling as you go
        output.X1_Values{1}(i) = bigtriXY(1) .* xrs;
        output.Y1_Values{1}(i) = bigtriXY(2) .* yrs;
        output.R1_Values{1}(i) = 0;
        output.X2_Values{1}(i) = circXY(1) .* xrs;
        output.Y2_Values{1}(i) = circXY(2) .* yrs;
        output.R2_Values{1}(i) = 0;
        output.X3_Values{1}(i) = doorXY(1) .* xrs;
        output.Y3_Values{1}(i) = doorXY(2) .* yrs;
        output.R3_Values{1}(i) = 0;
        output.X4_Values{1}(i) = littriXY(1) .* xrs;
        output.Y4_Values{1}(i) = littriXY(2) .* yrs;
        output.R4_Values{1}(i) = 0;
    
    end
    
    % Interpolate through the NaNs
    output.X1_Values{1} = fixnans(output.X1_Values{1});
    output.Y1_Values{1} = fixnans(output.Y1_Values{1});
    output.X2_Values{1} = fixnans(output.X2_Values{1});
    output.Y2_Values{1} = fixnans(output.Y2_Values{1});
    output.X3_Values{1} = fixnans(output.X3_Values{1});
    output.Y3_Values{1} = fixnans(output.Y3_Values{1});
    output.X4_Values{1} = fixnans(output.X4_Values{1});
    output.Y4_Values{1} = fixnans(output.Y4_Values{1});
    
    % Export to a new subfolder as Analysis/Position/vidName.mat
    pths = specifyPaths('..');
    outpath = fullfile(pths.analysis, 'Position');
    if ~exist(outpath, 'dir')
        mkdir(outpath);
    end
    fout = fullfile(outpath, [vidName '.mat']);
    save(fout, 'output');
    warning(q.state, 'MATLAB:table:RowsAddedExistingVars');
catch
    warning(q.state, 'MATLAB:table:RowsAddedExistingVars');
end
end % function


% -----SUBFUNCTIONS-----
function xycenter = extractCenter(x)
    % Takes a 4-element vector from the Timetable output of Video Labeler
    % Exports the centerpoint of that rectangle
    if isempty(x)
        xycenter = [NaN, NaN];
    else
        xycenter = [x(1) + round(0.5*x(3)), x(2) + round(0.5*x(4))];
    end
end

function newdat = fixnans(dat)
    % NaNs are timepoints when no bounding box was drawn
    % Find these timepoints and replace with interpolated values
    nanlist = isnan(dat);
    if sum(nanlist) == 0
        % Short-circuit since interp1 will likely fail anyway
        newdat = dat;
    else
        x = 1:length(dat);
        newdat = interp1(x(~nanlist), dat(~nanlist), x(nanlist));
    end
end