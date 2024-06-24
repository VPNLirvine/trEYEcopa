function overlayAQ(ax)
% Assuming you have another plot active,
% Overlay the expected distributions from the Baron Cohen AQ
% Input is the existing plot's gca

% Parse input
ylimvector = ax.YLim;

% Define parameters based on Baron-Cohen et al (2001)
controlmu = 16.4;
controlsigma = 6.3;
ashfamu = 35.8;
ashfasigma = 6.5;

% Generate distributions for plotting
x = 0:1:50;
controlDat = normpdf(x,controlmu,controlsigma);
ashfaDat = normpdf(x, ashfamu, ashfasigma);

% Rescale to match the existing plot's y height
controlDat = controlDat .* ylimvector(2) * 15;
ashfaDat = ashfaDat .* ylimvector(2) * 15;

% Implement the plots
hold on
    plot(x, controlDat, '--', 'Color', 	"#D95319");
    plot(x, ashfaDat, '--', 'Color', "#7E2F8E");
hold off