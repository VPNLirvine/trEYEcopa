function newPosData = rescalePosition(oldPosData, varargin)
% Rescales position data from default 4000x3000 to a new resolution.
% Input 1 is a single row of position data
% Input 2 is an optional (but not really optional) PTB rect vector,
% e.g. [1 1 480 640]
% Output also changes the data organization for some reason...

    if nargin > 1
        % Read in PTB size vector
        % This should have the x and y max values you want to rescale to
        pos = varargin{1};
    else
        % Default video size
        pos = [1 1 508 678];
    end
    % For the rescaled videos, during the experiment,
    % pos = [157.62 0 1762.4 1200];

    % Rescaling factors (since data is 4000x3000 instead of 678x508)
    xrs = (pos(3) - pos(1)) / 4000;
    yrs = (pos(4) - pos(2)) / 3000;

    % Fill the 'leading' frames with the first position value
    newPosData(1).X = oldPosData.X1_Values{1} .* xrs;
    newPosData(1).Y = oldPosData.Y1_Values{1} .* yrs;
    newPosData(2).X = oldPosData.X2_Values{1} .* xrs;
    newPosData(2).Y = oldPosData.Y2_Values{1} .* yrs;
    newPosData(3).X = oldPosData.X3_Values{1} .* xrs;
    newPosData(3).Y = oldPosData.Y3_Values{1} .* yrs;
    newPosData(4).X = oldPosData.X4_Values{1} .* xrs;
    newPosData(4).Y = oldPosData.Y4_Values{1} .* yrs;