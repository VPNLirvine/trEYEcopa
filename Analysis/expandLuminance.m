function output = expandLuminance(lum, pup)
% Input 1 is the luminance vector from estLuminance
% Input 2 is the pupillometry vector with frame numbers
% Since the luminance vector is invariably shorter than the pupil vector,
% expand it to be the same size.

output = zeros([1,length(pup)]);

% Now for everything ELSE, index in the value from lum
for i = 1:length(pup)
    if pup(2,i) == 0
        % The default value is .5,
        % since the screen before the video is 50% gray.
        output(i) = 0.5;
    else
        output(i) = lum(pup(2,i));
    end
end