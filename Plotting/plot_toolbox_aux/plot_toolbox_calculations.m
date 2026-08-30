function result = plot_toolbox_calculations(operation, varargin)
%PLOT_TOOLBOX_CALCULATIONS Numeric calculations used by Plot Toolbox.
%   RESULT = PLOT_TOOLBOX_CALCULATIONS("ruler", POINT1, POINT2)
%   calculates positive X, Y, and XY distances.
%
%   RESULT = PLOT_TOOLBOX_CALCULATIONS("statistics", X, Y, X1, X2)
%   calculates Y statistics for finite samples whose X values are in the
%   inclusive range bounded by X1 and X2.
%
%   RESULT = PLOT_TOOLBOX_CALCULATIONS("fft", X, Y) calculates the
%   single-sided magnitude spectrum for the complete data line.
%
%   RESULT = PLOT_TOOLBOX_CALCULATIONS("fft", X, Y, X1, X2) uses only
%   samples in the inclusive X range bounded by X1 and X2. X must be
%   uniformly sampled within the analyzed range.

arguments
    operation (1,1) string
end
arguments (Repeating)
    varargin
end

switch lower(operation)
    case "ruler"
        if numel(varargin) ~= 2
            error("plotToolbox:invalidInputCount", ...
                "Ruler calculations require two points.");
        end
        point1 = varargin{1};
        point2 = varargin{2};
        validateattributes(point1, {'numeric'}, ...
            {'real', 'finite', 'vector', 'numel', 2});
        validateattributes(point2, {'numeric'}, ...
            {'real', 'finite', 'vector', 'numel', 2});

        delta = abs(double(point2(:) - point1(:)));
        result = struct( ...
            XDistance=delta(1), ...
            YDistance=delta(2), ...
            XYDistance=hypot(delta(1), delta(2)));

    case "statistics"
        if numel(varargin) ~= 4
            error("plotToolbox:invalidInputCount", ...
                "Statistics calculations require X, Y, X1, and X2.");
        end
        x = varargin{1};
        y = varargin{2};
        x1 = varargin{3};
        x2 = varargin{4};
        validateattributes(x, {'numeric'}, {'real', 'vector'});
        validateattributes(y, {'numeric'}, ...
            {'real', 'vector', 'numel', numel(x)});
        validateattributes(x1, {'numeric'}, {'real', 'finite', 'scalar'});
        validateattributes(x2, {'numeric'}, {'real', 'finite', 'scalar'});

        limits = sort(double([x1, x2]));
        x = double(x(:));
        y = double(y(:));
        inRange = isfinite(x) & isfinite(y) & x >= limits(1) & x <= limits(2);
        selectedY = y(inRange);

        if isempty(selectedY)
            error("plotToolbox:noSamples", ...
                "The selected X range contains no finite samples.");
        end

        result = struct( ...
            XRange=limits, ...
            SampleCount=numel(selectedY), ...
            Minimum=min(selectedY), ...
            Maximum=max(selectedY), ...
            RMS=sqrt(mean(selectedY.^2)), ...
            Mean=mean(selectedY));

    case "fft"
        if numel(varargin) ~= 2 && numel(varargin) ~= 4
            error("plotToolbox:invalidInputCount", ...
                "FFT calculations require X and Y, optionally followed by X1 and X2.");
        end
        x = varargin{1};
        y = varargin{2};
        validateattributes(x, {'numeric'}, {'real', 'vector'});
        validateattributes(y, {'numeric'}, ...
            {'real', 'vector', 'numel', numel(x)});

        x = double(x(:));
        y = double(y(:));
        if numel(varargin) == 4
            x1 = varargin{3};
            x2 = varargin{4};
            validateattributes(x1, {'numeric'}, {'real', 'finite', 'scalar'});
            validateattributes(x2, {'numeric'}, {'real', 'finite', 'scalar'});
            limits = sort(double([x1, x2]));
            inRange = isfinite(x) & x >= limits(1) & x <= limits(2);
            x = x(inRange);
            y = y(inRange);
        else
            limits = [min(x), max(x)];
        end

        if numel(x) < 2
            error("plotToolbox:insufficientSamples", ...
                "The selected FFT span must contain at least two samples.");
        end

        if any(~isfinite(x)) || any(~isfinite(y))
            error("plotToolbox:nonfiniteFFTData", ...
                "The selected FFT span contains NaN or Inf data.");
        end

        sampleSteps = diff(x);
        sampleInterval = median(abs(sampleSteps));
        tolerance = max(1e-9 * sampleInterval, ...
            10 * eps(max(1, max(abs(x)))));

        if any(sampleSteps == 0) || ...
                any(sign(sampleSteps) ~= sign(sampleSteps(1))) || ...
                any(abs(abs(sampleSteps) - sampleInterval) > tolerance)
            error("plotToolbox:nonuniformSampling", ...
                "FFT analysis requires uniformly spaced X values.");
        end

        sampleCount = numel(y);
        sampleRate = 1 / sampleInterval;
        twoSidedMagnitude = abs(fft(y)) / sampleCount;
        oneSidedCount = floor(sampleCount / 2) + 1;
        magnitude = twoSidedMagnitude(1:oneSidedCount);
        if rem(sampleCount, 2) == 0
            magnitude(2:end-1) = 2 * magnitude(2:end-1);
        else
            magnitude(2:end) = 2 * magnitude(2:end);
        end
        frequency = sampleRate * (0:floor(sampleCount / 2)).' / sampleCount;

        result = struct( ...
            XRange=limits, ...
            Frequency=frequency, ...
            Magnitude=magnitude, ...
            SampleRate=sampleRate, ...
            SampleCount=sampleCount);

    otherwise
        error("plotToolbox:unknownOperation", ...
            "Unknown operation '%s'.", operation);
end
end
