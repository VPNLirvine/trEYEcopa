function plotGaze(xdat,ydat)
% While running selectMetric('heatmap'), with a breakpoint before it ends,
% plot the x-y values of the gaze path over time
% But be aware the subID and stimulus name aren't retained at this level

plot3(1:length(xdat), xdat,ydat);
    xlabel('Time'); ylabel('X'); zlabel('Y');
    % Set the plot limits to the stimulus monitor resolution
    sz = [1920 1200];
    ylim([0 sz(1)]);
    zlim([0 sz(2)]);
    % Overlay grid for reference
    grid on
end