function [output, varargout] = plotDensity(tbl, stim, varargin)
% Adapted from a user named 'Hoki' on StackOverflow
% given some XYZ data for multiple subjects, generate a 3D histogram
% Bin sizes are hardcoded within, which is obviously less than ideal

% Parse inputs
if nargin > 2
    % Allow bypassing the plot to just get the data
    flag = varargin{1};
else
    % Plot by default, since it's called "plot density"
    flag = true;
end

% Define constants
x = tbl.x;
y = tbl.y;
z = tbl.time;

numSubs = length(unique(tbl.Subject));
npt = numel(x);


%% Define domain and grid parameters
xMax = 1920;
yMax = 1200;
tMax = max(tbl.time);
binRes = round(deg2pix(2));
tbinRes = 200; % ms

nxbins = ceil(xMax / binRes);
nybins = ceil(yMax / binRes);
ntbins = ceil(tMax / tbinRes);

xBins = linspace(1,xMax,nxbins+1); % add 1 bc this defines the EDGES
yBins = linspace(1,yMax,nybins+1);
% tBins = linspace(1,tMax,ntbins+1);
tBins = 0:tbinRes:(ntbins * tbinRes); % ensure consistent spacing

%% Count density
% Take density over [Z] at each possible [X,Y] position
% Anything with 0 density will be skipped later (to speed things up)
[Nz1,~,~,binY,binX] = histcounts2(y,x,yBins,xBins) ;
npt = sum(Nz1, 'all'); % we may be excluding outliers like blinks here
% preallocate 3D containers
N3d = zeros(nybins,nxbins,ntbins) ; % 3D matrix containing the counts
Npc = zeros(nybins,nxbins,ntbins) ; % 3D matrix containing the percentages
Nsub = zeros(nybins,nxbins,ntbins); % 3D matrix containing subject agreemnt
colorpc = zeros(npt,1) ;         % 1D vector containing the percentages
pctsubs = zeros(npt,1) ;

% We don't want to loop over every single block of XYZ because:
%   - most of them are probably empty
%   - depending on the resolution, there can be a LOT of empties
% So instead, we'll find the [X,Y] blocks with non-zero density,
% then ONLY loop over those.
validbins = find(Nz1) ;                              % find the indices of non-empty blocks
[ybins,xbins] = ind2sub([nybins,nxbins],validbins) ;  % convert linear indices to 2d indices
nv = numel(xbins) ;                                 % number of block to process

% Now for each "valid" [X,Y] position (i.e. at least one non-zero [Z] bin),
% Find the density of each individual [Z] bin (i.e. not collapsed),
% then save the results to the 3D bricks N3d and Npc
for k=1:nv
    % Coordinates into Nz1 of the next "valid" bin
    xbin = xbins(k) ;
    ybin = ybins(k) ;

    % Find the 1-D bin nums for all [Z]s that match the [X,Y] coords
    idx = find( binX==xbin & binY==ybin ) ;
    assert(~isempty(idx), 'xbin and ybin do not point to a valid cell. Bin sizes likely off by one.')
    % Grab the corresponding Z values from your input matrix [XYZ]
    subZ = z(idx) ;
    assert(length(subZ) == Nz1(ybin,xbin), 'valid idx either did not find the correct data, or only a portion. Could be that the bins do not cover the full range of values.');
    % Bin your continuous [Z] and count the density in each bin
    [Nz,~,zbins] = histcounts( subZ , tBins ) ;

    % validate again
    assert(sum(Nz) == Nz1(ybin,xbin), 'valid position data did not gather from all timepoints - time bins likely wrong size');
    N3d(ybin,xbin,:) = Nz ;         % total counts for this block
    Npc(ybin,xbin,:) = Nz ./ npt ;  % density % for this block

    % Now we have to assign this value (color or percentage) to all the points
    % which were found in the blocks
    vzbins = find(Nz) ;
    for kz=1:numel(vzbins)
        thisColorpc = Nz(vzbins(kz)) ./ npt * 100 ;
        idz   = find( zbins==vzbins(kz) ) ;
        idx3d = idx(idz) ;
        colorpc(idx3d) = thisColorpc ;
        numUsedSubs = length(unique(tbl.Subject(idx3d)));
        pctsubs(idx3d) = numUsedSubs / numSubs;
        Nsub(ybin,xbin,kz) = numUsedSubs / numSubs;
    end

end

% Validate
% N3d flattened over z should equal Nz1
chk = sum(N3d,3);
assert(isequal(chk,Nz1), 'Encountered an unexpected binning error after passing all previous checks')
numCounted = sum(N3d, 'all');
assert(  numCounted == npt, 'Only considered %i of %i timepoints!', numCounted, npt ) % double check we counted everything

%% Define function outputs
% Main output should give the bin counts
% output = Nsub;
output = Npc; % percent density at each bin

% Second output gives you the bin widths/edges
if nargout > 1
    Bins.XbinEdges = xBins;
    Bins.YbinEdges = yBins;
    Bins.TbinEdges = tBins;
    varargout{1} = Bins;
end
%% Display final result
dotSize = (colorpc + eps) ./ max(colorpc + eps); % rescale to percentage
% dotColor = dotSize;
dotColor = pctsubs;
% Apply a threshold on which dots to plot,
% otherwise it plots literally every sample for every subject.
% dropThese = dotSize < 0.1; % apply a threshold
%     x(dropThese) = [];
%     z(dropThese) = [];
%     y(dropThese) = [];
%     dotSize(dropThese) = [];
%     dotColor(dropThese) = [];
dotSize = dotSize .* binRes; % resize based on bin size
% Now draw the plot
if flag
    h=figure;
    hs=scatter3(x, z, y, dotSize , dotColor ,'filled' );
    xlabel('x');
    ylabel('Time in ms');
    zlabel('y');
    title(replace(stim,'_','\_'));
    xlim([0 xMax]);
    zlim([0 yMax]);
    % Avoid using scientific notation for the time axis
    ax = gca; % axes handle
    ax.YAxis.Exponent = 0;
    % Fix axis directions
    set(ax, 'YDir', 'reverse'); % time goes from back to front
    set(ax, 'ZDir', 'reverse');
    % Set colorbar
    cb = colorbar ;
    cb.Label.String = 'Percentage of subjects with data in this bin';
    clim([0 1]); % This is a percentage
    % cb.Label.String = 'Bin density';
end
