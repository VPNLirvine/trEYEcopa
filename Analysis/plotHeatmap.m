function plotHeatmap(data, vidName)
figure();
    imagesc(data);
    title(sprintf('Gaze heatmap for %s', strrep(vidName, '_', '\_')));
end