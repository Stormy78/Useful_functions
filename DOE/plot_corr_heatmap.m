function [R, p] = plot_corr_heatmap(X, labels, method)
% plot_corr_heatmap
% Computes and visualizes correlation matrix as a heatmap (Python-style).
%
% Inputs:
%   X      : NxM numeric matrix (observations x variables)
%   labels : 1xM cell array of variable names
%   method : 'pearson' (default) or 'spearman'
%
% Outputs:
%   R : correlation matrix
%   p : p-value matrix

    if nargin < 3 || isempty(method)
        method = 'pearson';
    end

    assert(size(X,2) == numel(labels), 'Number of labels must match columns of X.');

    % Correlation + p-values
    [R, p] = corr(X, 'Type', method, 'Rows', 'pairwise');

    % ---- Plot heatmap ----
    figure('Name','Correlation Heatmap');
    imagesc(R);
    axis equal tight;

    % Colormap similar to seaborn "coolwarm"
    colormap(redbluecmap(256));
    clim([-1 1]);
    colorbar;

    % Axes
    xticks(1:numel(labels));
    yticks(1:numel(labels));
    xticklabels(labels);
    yticklabels(labels);
    xtickangle(45);

    % Grid-like cell borders
    ax = gca;
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridColor = [0.85 0.85 0.85];
    ax.GridAlpha = 1;
    ax.Layer = 'top';

    % Annotate correlation values
    for i = 1:size(R,1)
        for j = 1:size(R,2)
            text(j, i, sprintf('%.2f', R(i,j)), ...
                'HorizontalAlignment','center', ...
                'Color', textColor(R(i,j)));
        end
    end

    title(sprintf('Correlation matrix (%s)', method), 'Interpreter','none');
end

% -------- helper --------
function c = textColor(val)
    if abs(val) > 0.6
        c = 'w';
    else
        c = 'k';
    end
end