function plotDensity(tbl, stim)
% Adapted from a user named 'Hoki' on StackOverflow
x = tbl.x;
y = tbl.y;
z = tbl.time;

npt = numel(x);


%% Define domain and grid parameters
% nbins    = 100 ;
% maxDim   = 300 ;
% binEdges = linspace(0,maxDim,nbins+1) ;

% try again
xMax = 1920;
yMax = 1200;
tMax = max(tbl.time);
binRes = round(deg2pix(2));
tbinRes = 200; % ms?

nxbins = ceil(xMax / binRes);
nybins = ceil(yMax / binRes);
ntbins = ceil(tMax / tbinRes);

xBins = linspace(1,xMax,nxbins+1);
yBins = linspace(1,yMax,nybins+1);
tBins = linspace(1,tMax,ntbins+1);

%% Count density
% we start counting density along in the [X,Y] plane (Z axis aglomerated)
[Nz1,~,~,binY,binX] = histcounts2(y,x,yBins,xBins) ;
npt = sum(Nz1, 'all'); % we may be excluding outliers like blinks here
% preallocate 3D containers
N3d = zeros(nybins,nxbins,ntbins) ; % 3D matrix containing the counts
Npc = zeros(nybins,nxbins,ntbins) ; % 3D matrix containing the percentages
colorpc = zeros(npt,1) ;         % 1D vector containing the percentages

% we do not want to loop on every block of the domain because:
%   - depending on the grid size there can be many
%   - a large number of them can be empty
% So we first find the [X,Y] blocks which are not empty, we'll only loop on
% these blocks.
validbins = find(Nz1) ;                              % find the indices of non-empty blocks
[ybins,xbins] = ind2sub([nybins,nxbins],validbins) ;  % convert linear indices to 2d indices
nv = numel(xbins) ;                                 % number of block to process

% Now for each [X,Y] block, we get the distribution over a [Z] column and
% assign the results to the full 3D matrices
for k=1:nv
    % this block coordinates
    xbin = xbins(k) ;
    ybin = ybins(k) ;

    % find linear indices of the `x` and `y` values which are located into this block
    idx = find( binX==xbin & binY==ybin ) ;
    assert(~isempty(idx), 'xbin and ybin do not point to a valid cell. Bin sizes likely off by one.')
    % make a subset with the corresponding 'z' value
    subZ = z(idx) ;
    assert(length(subZ) == Nz1(ybin,xbin), 'valid idx either did not find the correct data, or only a portion. Could be that the bins do not cover the full range of values.');
    % find the distribution and assign to 3D matrices
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
    end

end

% Validate
% N3d flattened over z should equal Nz1
chk = sum(N3d,3);
assert(isequal(chk,Nz1), 'Encountered an unexpected binning error after passing all previous checks')
numCounted = sum(N3d, 'all');
assert(  numCounted == npt, 'Only considered %i of %i timepoints!', numCounted, npt ) % double check we counted everything

%% Display final result
dotSize = (colorpc + eps) ./ max(colorpc + eps); % rescale to percentage
% Apply a threshold on which dots to plot,
% otherwise it plots literally all of them.
dropThese = dotSize < 0.1; % apply a threshold
    x(dropThese) = [];
    z(dropThese) = [];
    y(dropThese) = [];
    dotSize(dropThese) = [];
    colorpc(dropThese) = [];
dotSize = dotSize .* binRes; % resize based on bin size
% Now draw the plot
h=figure;
hs=scatter3(x, z, y, dotSize , colorpc ,'filled' );
xlabel('x');
ylabel('Time in ms');
zlabel('y');
title(replace(stim,'_','\_'));
xlim([0 xMax]);
zlim([0 yMax]);
set(gca, 'YDir', 'reverse'); % time goes from back to front
set(gca, 'ZDir', 'reverse');
cb = colorbar ;
cb.Label.String = 'Probability density estimate';

