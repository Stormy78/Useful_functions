function D = make_design_2lvl_fullfact(varNames, lowLevels, highLevels, outFile)
% make_design_2lvl_fullfact
% Creates a 2-level full factorial design for N variables and writes to file
% with NO column names (plain numeric matrix).
%
% Inputs:
%   varNames   : 1xN cellstr (e.g., {'A','B','C'})
%   lowLevels  : 1xN numeric
%   highLevels : 1xN numeric
%   outFile    : char/string, e.g. "design.txt"
%
% Output:
%   D          : (2^N)xN numeric design matrix (actual levels)

    n = numel(varNames);
    assert(numel(lowLevels)==n && numel(highLevels)==n, 'Level vectors must match varNames length.');

    % Coded design in {-1, +1}
    coded = fullfact(2*ones(1,n));      % values in {1,2}
    coded(coded==1) = -1;
    coded(coded==2) = +1;

    % Map coded levels to actual levels
    D = zeros(size(coded));
    for j = 1:n
        D(:,j) = lowLevels(j) + (coded(:,j)==+1) .* (highLevels(j)-lowLevels(j));
    end

    % Write design to file (no headers)
    writematrix(D, outFile, 'Delimiter', 'tab');  % change delimiter if needed
end