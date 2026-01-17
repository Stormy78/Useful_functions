function statsOut = analyze_2lvl_fullfact_with_interactions(varNames, lowLevels, highLevels, designFile, resultsFile, yCol)
% Fits main effects + all 2-factor interactions, ANOVA, and bar plot of relative effects.
% Inputs:
%   varNames, lowLevels, highLevels: 1xN
%   designFile : matrix used in sim (no headers)
%   resultsFile: sim outputs aligned by row order
%   yCol       : response column in resultsFile (default 1)

    if nargin < 6, yCol = 1; end

    X = readmatrix(designFile);
    n = numel(varNames);
    assert(size(X,2)==n, 'Design columns do not match varNames length.');

    R = readmatrix(resultsFile);
    assert(size(R,1)==size(X,1), 'Results rows must match number of design runs.');
    Y = R(:, yCol);

    % Code to -1/+1 using midpoints
    coded = zeros(size(X));
    for j = 1:n
        mid = (lowLevels(j) + highLevels(j)) / 2;
        coded(:,j) = sign(X(:,j) - mid);
        coded(coded(:,j)==0, j) = -1;
    end

    % Build table for fitlm
    T = array2table(coded, 'VariableNames', varNames);
    T.Y = Y;

    % ---- Model: main effects + all 2-factor interactions ----
    % Equivalent: "Y ~ A*B*C*... " truncated to 2nd order
    % In fitlm, 'interactions' includes main + pairwise interactions.
    lm = fitlm(T, 'interactions');

    % ANOVA table
    a = anova(lm, 'summary');

    % ---- Compute effects (main + 2-factor interactions) ----
    labels = {};
    effects = [];

    % Main effects: mean(Y|+1) - mean(Y|-1)
    for j = 1:n
        eff = mean(Y(coded(:,j)==+1)) - mean(Y(coded(:,j)==-1));
        labels{end+1} = varNames{j}; %#ok<AGROW>
        effects(end+1) = eff; %#ok<AGROW>
    end

    % 2-factor interaction effects:
    % For 2-level design, interaction column is product of coded columns.
    % Effect = mean(Y|prod=+1) - mean(Y|prod=-1)
    for j = 1:n-1
        for k = j+1:n
            prodCol = coded(:,j) .* coded(:,k);
            eff = mean(Y(prodCol==+1)) - mean(Y(prodCol==-1));
            labels{end+1} = sprintf('%s:%s', varNames{j}, varNames{k}); %#ok<AGROW>
            effects(end+1) = eff; %#ok<AGROW>
        end
    end

    rel = abs(effects);
    if max(rel) > 0
        rel = rel / max(rel);
    end

    % ---- Plot ----
    figure('Name','Main + 2-Factor Interaction Effects (Relative Magnitude)');
    bar(rel);
    grid on;
    xticks(1:numel(labels));
    xticklabels(labels);
    xtickangle(45);
    ylabel('Relative effect (|effect| normalized)');
    title('Main Effects + 2-Factor Interactions (2-level full factorial)');

    % ---- Optional: extract p-values from ANOVA rows when names match ----
    pMap = containers.Map();
    for r = 1:numel(a.pValue)
        rn = a.Properties.RowNames{r};
        if ~isempty(rn)
            pMap(rn) = a.pValue(r);
        end
    end

    pvals = nan(size(labels));
    for i = 1:numel(labels)
        key = labels{i};
        % anova row names may use "A:B" already; if it differs, keep NaN
        if isKey(pMap, key)
            pvals(i) = pMap(key);
        end
    end

    % annotate p-values where available
    yTop = max(rel) * 1.05;
    for i = 1:numel(labels)
        if ~isnan(pvals(i))
            text(i, min(yTop, rel(i)+0.03), sprintf('p=%.3g', pvals(i)), ...
                'HorizontalAlignment','center', 'Rotation', 90);
        end
    end

    statsOut = struct();
    statsOut.lm = lm;
    statsOut.anovaTable = a;
    statsOut.labels = labels;
    statsOut.effects = effects;
    statsOut.relativeEffects = rel;
    statsOut.pValues = pvals;
end