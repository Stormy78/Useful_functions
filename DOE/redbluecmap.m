function cmap = redbluecmap(m)
% redbluecmap
% Diverging red-white-blue colormap (seaborn-like)

    if nargin < 1
        m = size(get(gcf,'colormap'),1);
    end

    bottom = [0 0 0.5];
    middle = [1 1 1];
    top    = [0.5 0 0];

    cmap = zeros(m,3);
    for i = 1:3
        cmap(:,i) = interp1([1 m/2 m], ...
                            [bottom(i) middle(i) top(i)], ...
                            1:m);
    end
end