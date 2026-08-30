allPlots = findobj(gcf, 'Type', 'Line'); 

% 3. Loop through and customize the template for every tile
for k = 1:numel(allPlots)
    % Set font size globally for this plot's data tips
    allPlots(k).DataTipTemplate.FontSize = 14; 
    
    % Set numeric precision (e.g., 4 decimal places)
    allPlots(k).DataTipTemplate.DataTipRows(1).Format = '%0.4f'; % X-row
    allPlots(k).DataTipTemplate.DataTipRows(2).Format = '%0.4f'; % Y-row
end

clear allPlots  k