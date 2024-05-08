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
xBins = 1:binRes:xMax;
yBins = 1:binRes:yMax;
tBins = 0:tbinRes:tMax;

nxbins = length(xBins);
nybins = length(yBins);
ntbins = length(tBins);

%% Count density
% we start counting density along in the [X,Y] plane (Z axis aglomerated)
[Nz,xBins,yBins,binX,binY] = histcounts2(x,y,xBins,yBins) ;
npt = sum(Nz, 'all'); % we may be excluding outliers like blinks here
% preallocate 3D containers
N3d = zeros(nxbins,nybins,ntbins) ; % 3D matrix containing the counts
Npc = zeros(nxbins,nybins,ntbins) ; % 3D matrix containing the percentages
colorpc = zeros(npt,1) ;         % 1D vector containing the percentages

% we do not want to loop on every block of the domain because:
%   - depending on the grid size there can be many
%   - a large number of them can be empty
% So we first find the [X,Y] blocks which are not empty, we'll only loop on
% these blocks.
validbins = find(Nz) ;                              % find the indices of non-empty blocks
[xbins,ybins] = ind2sub([nxbins,nybins],validbins) ;  % convert linear indices to 2d indices
nv = numel(xbins) ;                                 % number of block to process

% Now for each [X,Y] block, we get the distribution over a [Z] column and
% assign the results to the full 3D matrices
for k=1:nv
    % this block coordinates
    xbin = xbins(k) ;
    ybin = ybins(k) ;

    % find linear indices of the `x` and `y` values which are located into this block
    idx = find( binX==xbin & binY==ybin ) ;
    % make a subset with the corresponding 'z' value
    subZ = z(idx) ;
    % find the distribution and assign to 3D matrices
    [Nz,~,zbins] = histcounts( subZ , tBins ) ;
    N3d(xbin,ybin,:) = Nz ;         % total counts for this block
    Npc(xbin,ybin,:) = Nz ./ npt ;  % density % for this block

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
numCounted = sum(sum(sum(N3d)));
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

