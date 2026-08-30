% PLOT_TOOLBOX Add measurement and statistics tools to the current figure.
%
% Run this script after creating or opening a MATLAB figure.  The toolbox
% appears in a separate window and works with the figure that was current
% when this script started.

plotToolboxTarget = gcf;

if isappdata(plotToolboxTarget, "PlotToolboxController")
    plotToolboxOld = getappdata(plotToolboxTarget, "PlotToolboxController");
    if isa(plotToolboxOld, "PlotToolboxController") && isvalid(plotToolboxOld)
        delete(plotToolboxOld);
    end
end

plotToolboxApp = PlotToolboxController(plotToolboxTarget);
setappdata(plotToolboxTarget, "PlotToolboxController", plotToolboxApp);

clear plotToolboxTarget plotToolboxOld plotToolboxApp

