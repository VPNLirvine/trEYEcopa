% CSV file path
addpath('..'); % to allow specifyPaths to run
pths = specifyPaths('..');

csv_file = fullfile(pths.analysis, 'TriCOPA-animations.csv');

% Read the CSV file into a table
data = readtable(csv_file);

% stim number based on csv row
rownum = 2;

% Extract the X, Y, and R coordinates
x_values_row1 = str2num(data{rownum, 'X1_Values'}{:});
y_values_row1 = str2num(data{rownum, 'Y1_Values'}{:});
r_values_row1 = str2num(data{rownum, 'R1_Values'}{:});

% Extract the X, Y, and R coordinates for columns 7 and 8 (X2_values, Y2_values, and R2_values)
x_values_row1_X2 = str2num(data{rownum, 'X2_Values'}{:});
y_values_row1_Y2 = str2num(data{rownum, 'Y2_Values'}{:});
r_values_row1_X2 = str2num(data{rownum, 'R2_Values'}{:});

% Extract the X, Y, and R coordinates for columns 10 and 11 (X3_values, Y3_values, and R3_values)
x_values_row1_X3 = str2num(data{rownum, 'X3_Values'}{:});
y_values_row1_Y3 = str2num(data{rownum, 'Y3_Values'}{:});
r_values_row1_X3 = str2num(data{rownum, 'R3_Values'}{:});

% Extract the X, Y, and R coordinates for columns 14 and 15 (X4_values, Y4_values, and R4_values)
x_values_row1_X4 = str2num(data{rownum, 'X4_Values'}{:});
y_values_row1_Y4 = str2num(data{rownum, 'Y4_Values'}{:});
r_values_row1_X4 = str2num(data{rownum, 'R4_Values'}{:});

% Determine the limits of the graph
% x_min = min([min(x_values_row1), min(x_values_row1_X2), min(x_values_row1_X3), min(x_values_row1_X4)]) - 50;
% x_max = max([max(x_values_row1), max(x_values_row1_X2), max(x_values_row1_X3), max(x_values_row1_X4)]) + 50;
% y_min = -max([max(y_values_row1), max(y_values_row1_Y2), max(y_values_row1_Y3), max(y_values_row1_Y4)]) - 50;
% y_max = -min([min(y_values_row1), min(y_values_row1_Y2), min(y_values_row1_Y3), min(y_values_row1_Y4)]) + 50;

x_min = 1;
x_max = 4000;
y_min = -3000;
y_max = -1;

% Create a video writer object
writerObj = VideoWriter('moving_dot_multiple_columns_flipped_y_larger_limits.avi');
open(writerObj);

% Create a figure outside the loop
figure;
xlabel('X');
ylabel('Y');
title('Moving Dot Animation (Multiple Columns with Flipped Y)');
xlim([x_min, x_max]);
ylim([y_min, y_max]);
hold on;

% Plot the initial dots
dot_handle = plot(x_values_row1(1), -y_values_row1(1), 'r^', 'MarkerSize', 25);
dot_handle_X2 = plot(x_values_row1_X2(1), -y_values_row1_Y2(1), 'bo', 'MarkerSize', 15);
dot_handle_X3 = plot(x_values_row1_X3(1), -y_values_row1_Y3(1), 'g|', 'MarkerSize', 100);
dot_handle_X4 = plot(x_values_row1_X4(1), -y_values_row1_Y4(1), 'c^', 'MarkerSize', 15);

% Plot the dots for each frame
for i = 2:numel(x_values_row1)
    % Update the positions of the dots
    set(dot_handle, 'XData', x_values_row1(i), 'YData', -y_values_row1(i));
    set(dot_handle_X2, 'XData', x_values_row1_X2(i), 'YData', -y_values_row1_Y2(i));
    set(dot_handle_X3, 'XData', x_values_row1_X3(i), 'YData', -y_values_row1_Y3(i));
    set(dot_handle_X4, 'XData', x_values_row1_X4(i), 'YData', -y_values_row1_Y4(i));
    
    % Pause for X seconds
    % pause(0.025);
    pause(1/60);
    
    frame = getframe(gcf);
    
end
writeVideo(writerObj, frame);
% Close the video writer object
close(writerObj);