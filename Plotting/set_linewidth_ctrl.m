function [] = set_linewidth_ctrl(Linewidth)
h_lines = findall(gcf, 'Type', 'line');
valid_line_handles = [];  % Initialize an empty array
for i = 1:numel(h_lines)
    xdata = get(h_lines(i), 'XData');  % Get XData for the current line
    if ~isempty(xdata) && ~any(isnan(xdata)) && numel(xdata)>5
        valid_line_handles = [valid_line_handles, h_lines(i)];
    end
end

switch nargin
    case 0
        Linewidth = 3;
end

set(valid_line_handles, 'Linewidth', Linewidth);
end