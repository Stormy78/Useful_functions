classdef PlotToolboxController < handle
    %PLOTTOOLBOXCONTROLLER Floating tools for an existing MATLAB figure.

    properties (Access = private)
        TargetFigure
        ToolFigure
        LineDropDown
        ResultArea
        Lines = gobjects(0)
        IsDeleting = false
    end

    methods
        function app = PlotToolboxController(targetFigure)
            arguments
                targetFigure (1,1) matlab.ui.Figure
            end

            app.TargetFigure = targetFigure;
            app.createComponents();
            app.refreshLines();
        end

        function delete(app)
            if app.IsDeleting
                return
            end
            app.IsDeleting = true;

            if isgraphics(app.TargetFigure) && ...
                    isappdata(app.TargetFigure, "PlotToolboxController")
                storedApp = getappdata(app.TargetFigure, "PlotToolboxController");
                if isequal(storedApp, app)
                    rmappdata(app.TargetFigure, "PlotToolboxController");
                end
            end

            if isgraphics(app.ToolFigure)
                delete(app.ToolFigure);
            end
        end
    end

    methods (Access = private)
        function createComponents(app)
            targetPosition = app.TargetFigure.Position;
            toolWidth = 360;
            toolHeight = 350;
            toolLeft = targetPosition(1) + targetPosition(3) + 15;
            toolBottom = targetPosition(2) + targetPosition(4) - toolHeight;

            app.ToolFigure = uifigure( ...
                Name="Plot Toolbox", ...
                Position=[toolLeft toolBottom toolWidth toolHeight], ...
                Resize="on", ...
                CloseRequestFcn=@(~, ~) delete(app));

            layout = uigridlayout(app.ToolFigure, [7 2]);
            layout.RowHeight = {"fit", "fit", "fit", "fit", "fit", "fit", "1x"};
            layout.ColumnWidth = {"1x", "1x"};
            layout.Padding = [10 10 10 10];

            heading = uilabel(layout, ...
                Text="Tools for the current figure", ...
                FontWeight="bold");
            heading.Layout.Row = 1;
            heading.Layout.Column = [1 2];

            lineLabel = uilabel(layout, Text="Data line");
            lineLabel.Layout.Row = 2;
            lineLabel.Layout.Column = 1;

            refreshButton = uibutton(layout, ...
                Text="Refresh", ...
                BackgroundColor=[0.78 0.94 0.78], ...
                ButtonPushedFcn=@(~, ~) app.refreshLines());
            refreshButton.Layout.Row = 2;
            refreshButton.Layout.Column = 2;

            app.LineDropDown = uidropdown(layout);
            app.LineDropDown.Layout.Row = 3;
            app.LineDropDown.Layout.Column = [1 2];

            rulerButton = uibutton(layout, ...
                Text="Ruler", ...
                Tooltip="Measure X, Y, and XY distance", ...
                ButtonPushedFcn=@(~, ~) app.runRuler());
            rulerButton.Layout.Row = 4;
            rulerButton.Layout.Column = 1;

            statisticsButton = uibutton(layout, ...
                Text="Statistics", ...
                Tooltip="Calculate statistics between two selected points", ...
                ButtonPushedFcn=@(~, ~) app.runStatistics());
            statisticsButton.Layout.Row = 4;
            statisticsButton.Layout.Column = 2;

            fftButton = uibutton(layout, ...
                Text="FFT", ...
                Tooltip="Plot the single-sided spectrum within a selected X span", ...
                ButtonPushedFcn=@(~, ~) app.runFFT());
            fftButton.Layout.Row = 5;
            fftButton.Layout.Column = 1;

            resetButton = uibutton(layout, ...
                Text="Reset", ...
                BackgroundColor=[1.00 0.78 0.78], ...
                Tooltip="Remove selection graphics and clear results", ...
                ButtonPushedFcn=@(~, ~) app.resetMeasurements());
            resetButton.Layout.Row = 5;
            resetButton.Layout.Column = 2;

            resultLabel = uilabel(layout, Text="Results");
            resultLabel.Layout.Row = 6;
            resultLabel.Layout.Column = [1 2];

            app.ResultArea = uitextarea(layout, ...
                Editable="off", ...
                Value="Select a line, then choose a tool.");
            app.ResultArea.Layout.Row = 7;
            app.ResultArea.Layout.Column = [1 2];
        end

        function refreshLines(app)
            if ~isgraphics(app.TargetFigure)
                app.showError("The target figure has been closed.");
                return
            end

            candidates = findobj(app.TargetFigure, Type="line");
            keep = arrayfun(@(line) app.isDataLine(line), candidates);
            app.Lines = flipud(candidates(keep));

            if isempty(app.Lines)
                app.LineDropDown.Items = {"No data lines found"};
                app.LineDropDown.ItemsData = 0;
                app.LineDropDown.Enable = "off";
                app.ResultArea.Value = "No numeric data lines were found.";
                return
            end

            names = strings(1, numel(app.Lines));
            for index = 1:numel(app.Lines)
                names(index) = app.lineName(app.Lines(index), index);
            end
            app.LineDropDown.Items = names;
            app.LineDropDown.ItemsData = 1:numel(app.Lines);
            app.LineDropDown.Value = 1;
            app.LineDropDown.Enable = "on";
        end

        function runRuler(app)
            lineHandle = app.selectedLine();
            if isempty(lineHandle)
                return
            end

            fprintf("\nRULER TOOL\nSelect point 1 and point 2 on the plot.\n");
            points = app.selectTwoPoints(lineHandle);
            if isempty(points)
                return
            end

            result = plot_toolbox_calculations("ruler", points(1, :), points(2, :));
            lines = {
                sprintf("X distance:  %.6g", result.XDistance)
                sprintf("Y distance:  %.6g", result.YDistance)
                sprintf("XY distance: %.6g", result.XYDistance)
                };
            app.publishResult("RULER RESULTS", lines);
        end

        function runStatistics(app)
            lineHandle = app.selectedLine();
            if isempty(lineHandle)
                return
            end

            fprintf("\nSTATISTICAL TOOL\nSelect point 1 and point 2 to define the X range.\n");
            points = app.selectTwoPoints(lineHandle);
            if isempty(points)
                return
            end

            try
                result = plot_toolbox_calculations("statistics", ...
                    lineHandle.XData, lineHandle.YData, points(1, 1), points(2, 1));
            catch exception
                app.showError(exception.message);
                return
            end

            lines = {
                sprintf("X range:    %.6g to %.6g", result.XRange(1), result.XRange(2))
                sprintf("Samples:    %d", result.SampleCount)
                sprintf("MIN VALUE:  %.6g", result.Minimum)
                sprintf("MAX VALUE:  %.6g", result.Maximum)
                sprintf("RMS VALUE:  %.6g", result.RMS)
                sprintf("MEAN VALUE: %.6g", result.Mean)
                };
            app.publishResult("STATISTICAL RESULTS", lines);
        end

        function runFFT(app)
            lineHandle = app.selectedLine();
            if isempty(lineHandle)
                return
            end

            fprintf("\nFFT TOOL\nSelect point 1 and point 2 to define the X range.\n");
            points = app.selectTwoPoints(lineHandle);
            if isempty(points)
                return
            end

            try
                result = plot_toolbox_calculations( ...
                    "fft", lineHandle.XData, lineHandle.YData, ...
                    points(1, 1), points(2, 1));
            catch exception
                app.showError(exception.message);
                return
            end

            lineTitle = app.lineName(lineHandle, app.LineDropDown.Value);
            fftFigure = figure( ...
                Name="Single-Sided FFT - " + lineTitle, ...
                NumberTitle="off");
            fftAxes = axes(fftFigure);
            plot(fftAxes, result.Frequency, result.Magnitude, ...
                LineWidth=1.5);
            grid(fftAxes, "on");
            xlabel(fftAxes, "Frequency (cycles per X unit)");
            ylabel(fftAxes, "Magnitude");
            title(fftAxes, "Single-Sided Magnitude Spectrum - " + lineTitle);

            [peakMagnitude, peakIndex] = max(result.Magnitude);
            peakFrequency = result.Frequency(peakIndex);
            lines = {
                sprintf("X range:        %.6g to %.6g", ...
                    result.XRange(1), result.XRange(2))
                sprintf("Samples:        %d", result.SampleCount)
                sprintf("Sample rate:    %.6g per X unit", result.SampleRate)
                sprintf("Peak frequency: %.6g cycles per X unit", peakFrequency)
                sprintf("Peak magnitude: %.6g", peakMagnitude)
                };
            app.publishResult("FFT RESULTS", lines);
        end

        function resetMeasurements(app)
            if isgraphics(app.TargetFigure)
                measurementLines = findall(app.TargetFigure, ...
                    Type="line", Tag="PlotToolboxMeasurement");
                delete(measurementLines);
            end
            app.ResultArea.Value = "Selections and results cleared.";
            fprintf("\nPLOT TOOLBOX RESET\nSelections and results cleared.\n");
        end

        function points = selectTwoPoints(app, lineHandle)
            points = [];
            if ~isgraphics(app.TargetFigure) || ~isgraphics(lineHandle)
                app.showError("The selected plot or line is no longer available.");
                return
            end

            axesHandle = ancestor(lineHandle, "axes");
            figure(app.TargetFigure);
            axes(axesHandle);
            titleBefore = axesHandle.Title.String;
            axesHandle.Title.String = "Select point 1, then point 2";
            titleCleanup = onCleanup(@() app.restoreTitle(axesHandle, titleBefore));
            drawnow;

            try
                [clickX, clickY] = ginput(2);
            catch exception
                app.showError("Point selection was cancelled: " + exception.message);
                return
            end

            if numel(clickX) ~= 2
                app.showError("Two points are required.");
                return
            end

            points = [app.snapToLine(lineHandle, clickX(1), clickY(1)); ...
                      app.snapToLine(lineHandle, clickX(2), clickY(2))];

            holdState = ishold(axesHandle);
            hold(axesHandle, "on");
            plot(axesHandle, points(:, 1), points(:, 2), "o--", ...
                Color=[0.85 0.20 0.10], ...
                MarkerFaceColor=[1.00 0.85 0.20], ...
                LineWidth=1.5, ...
                Tag="PlotToolboxMeasurement", ...
                DisplayName="Tool selection");
            if ~holdState
                hold(axesHandle, "off");
            end
            drawnow;

            fprintf("Point 1: X = %.6g, Y = %.6g\n", points(1, 1), points(1, 2));
            fprintf("Point 2: X = %.6g, Y = %.6g\n", points(2, 1), points(2, 2));
            clear titleCleanup
        end

        function point = snapToLine(~, lineHandle, clickX, clickY)
            x = double(lineHandle.XData(:));
            y = double(lineHandle.YData(:));
            finite = isfinite(x) & isfinite(y);
            x = x(finite);
            y = y(finite);

            xScale = max(max(x) - min(x), eps);
            yScale = max(max(y) - min(y), eps);
            distanceSquared = ((x - clickX) ./ xScale).^2 + ...
                ((y - clickY) ./ yScale).^2;
            [~, index] = min(distanceSquared);
            point = [x(index), y(index)];
        end

        function lineHandle = selectedLine(app)
            lineHandle = [];
            if isempty(app.Lines) || app.LineDropDown.Enable == "off"
                app.showError("No data line is available. Plot data and click Refresh.");
                return
            end

            index = app.LineDropDown.Value;
            if index < 1 || index > numel(app.Lines) || ~isgraphics(app.Lines(index))
                app.refreshLines();
                app.showError("The line list changed. Choose a line and try again.");
                return
            end
            lineHandle = app.Lines(index);
        end

        function publishResult(app, heading, resultLines)
            app.ResultArea.Value = [string(heading); string(resultLines)];
            fprintf("%s\n", heading);
            fprintf("%s\n", resultLines{:});
        end

        function showError(app, message)
            fprintf(2, "Plot Toolbox: %s\n", message);
            if isgraphics(app.ToolFigure)
                uialert(app.ToolFigure, message, "Plot Toolbox");
            end
        end
    end

    methods (Static, Access = private)
        function tf = isDataLine(lineHandle)
            tf = isgraphics(lineHandle) && ...
                lineHandle.Tag ~= "PlotToolboxMeasurement" && ...
                isnumeric(lineHandle.XData) && isnumeric(lineHandle.YData) && ...
                isvector(lineHandle.XData) && isvector(lineHandle.YData) && ...
                numel(lineHandle.XData) == numel(lineHandle.YData) && ...
                any(isfinite(lineHandle.XData) & isfinite(lineHandle.YData));
        end

        function name = lineName(lineHandle, index)
            displayName = strtrim(string(lineHandle.DisplayName));
            if strlength(displayName) == 0
                name = sprintf("Line %d", index);
            else
                name = sprintf("%d: %s", index, displayName);
            end
        end

        function restoreTitle(axesHandle, oldTitle)
            if isgraphics(axesHandle)
                axesHandle.Title.String = oldTitle;
            end
        end
    end
end
