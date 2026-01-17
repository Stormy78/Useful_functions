function statsOut = analyze_2lvl_fullfact_interactions(varNames, lowLevels, highLevels, designFile, resultsFile, yCol)
% ANOVA for main effects + all 2-factor interactions; bar plot of relative effects.
% designFile: the design you fed to simulator (actual levels).
% resultsFile: simulator outputs aligned by row order.
% yCol: response column in resultsFile (default 1).

    if nargin < 6, yCol = 1; end

    X = readmatrix(designFile);
    n = numel(varNames);
    assert(size(X,2)==n, 'Design columns do not match varNames length.');

    R = readmatrix(resultsFile);
    assert(size(R,1)==size(X,1), 'Results rows must match number of design runs.');
    Y = R(:, yCol);

    % Code to -1/+1 using midpoint
    coded = zeros(size(X));
    for j = 1:n
        mid = (lowLevels(j) + highLevels(j)) / 2;
        coded(:,j) = sign(X(:,j) - mid);
        coded(coded(:,j)==0, j) = -1;
    end

    % Fit model: main + all pairwise interactions
    T = array2table(coded, 'VariableNames', varNames);
    T.Y = Y;

    lm = fitlm(T, 'interactions');          % includes main + 2-factor interactions
    a  = anova(lm, 'summary');

    % ---- Effects (main + 2-factor) ----
    labels = cell(1, n + n*(n-1)/2);
    effects = zeros(size(labels));

    idx = 0;

    % Main effects: mean(Y|+1) - mean(Y|-1)
    for j = 1:n
        idx = idx + 1;
        labels{idx} = varNames{j};
        effects(idx) = mean(Y(coded(:,j)==+1)) - mean(Y(coded(:,j)==-1));
    end

    % 2-factor interactions: use product column
    for j = 1:n-1
        for k = j+1:n
            idx = idx + 1;
            labels{idx} = sprintf('%s:%s', varNames{j}, varNames{k});
            prodCol = coded(:,j).*coded(:,k);
            effects(idx) = mean(Y(prodCol==+1)) - mean(Y(prodCol==-1));
        end
    end

    rel = abs(effects);
    if max(rel) > 0, rel = rel / max(rel); end

    % Try to map p-values from ANOVA rows (may miss some depending on naming)
    pvals = nan(size(labels));
    for i = 1:numel(labels)
        rn = labels{i};
        hit = find(strcmp(a.Properties.RowNames, rn), 1);
        if ~isempty(hit)
            pvals(i) = a.pValue(hit);
        end
    end

    % ---- Plot ----
    figure('Name','Relative Effects: Main + 2-Factor Interactions');
    bar(rel);
    grid on;
    xticks(1:numel(labels));
    xticklabels(labels);
    xtickangle(45);
    ylabel('Relative effect (|effect| normalized)');
    title('Main Effects + 2-Factor Interactions');

    % Annotate p-values where available
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