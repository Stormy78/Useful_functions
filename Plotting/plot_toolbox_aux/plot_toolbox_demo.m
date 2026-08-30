% PLOT_TOOLBOX_DEMO Create sample data and launch Plot Toolbox.
%
% Manual test:
%   1. Run this script.
%   2. Choose either Sine or Damped cosine in the toolbox dropdown.
%   3. Click Ruler and select two points in the plot.
%   4. Click Statistics and select two points that bound an X range.
%   5. Click FFT, select two points that bound an X range, and inspect the
%      single-sided magnitude spectrum created from that span only.
%   6. Click Reset to remove the point-selection graphics and clear results.
%   7. Check both the floating Results area and Command Window history.

x = linspace(0, 8*pi, 500);
y1 = sin(2*pi*3*x);
y2 = 0.8 .* exp(-0.08 .* x) .* cos(2 .* x);

figure(Name="Plot Toolbox Demo", NumberTitle="off");
plot(x, y1, LineWidth=1.5, DisplayName="Sine");
hold on
plot(x, y2, LineWidth=1.5, DisplayName="Damped cosine");
hold off
grid on
xlabel("X")
ylabel("Y")
title("Plot Toolbox Test Data")
legend(Location="best")

plot_toolbox
