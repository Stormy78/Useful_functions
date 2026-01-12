function [TS1, TS2] = importCreoResults(filename)

fid = fopen(filename,'r');
assert(fid>0, "Cannot open file: " + filename);

rows = {};  % {Surface, Axis, PointId, Val, X, Y, Z}
nBad = 0;

% Strict: S1|S2 _ X|Y|Z _ displ _ PNT<digits>
pat = '^(S1|S2)_(X|Y|Z)_displ_(PNT\d+)$';

while true
    line = fgetl(fid);
    if ~ischar(line), break; end
    line = strtrim(line);
    if line==""; continue; end

    % Simple CSV split (assumes no quoted commas inside fields)
    parts = split(string(line), ",");
    if numel(parts) < 5
        nBad = nBad + 1;
        continue;
    end

    label = strtrim(parts(1));
    m = regexp(label, pat, 'tokens', 'once');
    if isempty(m)
        nBad = nBad + 1;
        continue;
    end

    v  = str2double(strtrim(parts(2)));
    px = str2double(strtrim(parts(3)));
    py = str2double(strtrim(parts(4)));
    pz = str2double(strtrim(parts(5)));

    if any(isnan([v,px,py,pz]))
        nBad = nBad + 1;
        continue;
    end

    rows(end+1, :) = {string(m{1}), string(m{2}), string(m{3}), v, px, py, pz}; %#ok<AGROW>
end

fclose(fid);

if isempty(rows)
    TS1 = emptySurfaceTable();
    TS2 = emptySurfaceTable();
    warning("No valid rows found. Discarded %d bad rows.", nBad);
    return;
end

T = cell2table(rows, 'VariableNames', {'Surface','Axis','PointId','Val','X','Y','Z'});

% Build outputs even if one surface is missing entirely
TS1 = buildSurfaceTable(T(T.Surface=="S1",:));
TS2 = buildSurfaceTable(T(T.Surface=="S2",:));

fprintf("Parsed %d valid rows, discarded %d bad rows.\n", height(T), nBad);

end

function Tout = buildSurfaceTable(Ts)
% Returns columns: PointId, X, Y, Z, dX, dY, dZ
% Missing axis per point -> NaN in that displacement column

Tout = emptySurfaceTable();
if isempty(Ts)
    return; % surface absent -> empty table
end

% Unique points + coordinates (take first occurrence)
[pid, ia] = unique(Ts.PointId, 'stable');
Coord = Ts(ia, {'PointId','X','Y','Z'});

% Pivot displacements (may miss some axes)
Uwide = unstack(Ts(:,{'PointId','Axis','Val'}), 'Val', 'Axis');

% Normalize: ensure X/Y/Z displacement columns exist in Uwide
if ~ismember("X", string(Uwide.Properties.VariableNames)), Uwide.X = NaN(height(Uwide),1); end
if ~ismember("Y", string(Uwide.Properties.VariableNames)), Uwide.Y = NaN(height(Uwide),1); end
if ~ismember("Z", string(Uwide.Properties.VariableNames)), Uwide.Z = NaN(height(Uwide),1); end

% Align Uwide to Coord by PointId (safe even if some points have no disp after filtering)
[pid2, iC, iU] = intersect(Coord.PointId, Uwide.PointId, 'stable');

% Start with coords for all points found (even if a point somehow lacks disp)
Tout = table(Coord.PointId, Coord.X, Coord.Y, Coord.Z, ...
             NaN(height(Coord),1), NaN(height(Coord),1), NaN(height(Coord),1), ...
    'VariableNames', {'PointId','X','Y','Z','dX','dY','dZ'});

% Fill displacements where available
Tout.dX(iC) = Uwide.X(iU);
Tout.dY(iC) = Uwide.Y(iU);
Tout.dZ(iC) = Uwide.Z(iU);

% Optional: sort by numeric point index (PNT###)
pnum = sscanf(join(Tout.PointId, newline), "PNT%d");
if numel(pnum)==height(Tout)
    [~, idx] = sort(pnum);
    Tout = Tout(idx,:);
else
    Tout = sortrows(Tout, 'PointId');
end

end

function T0 = emptySurfaceTable()
T0 = table('Size',[0 7], ...
    'VariableTypes', {'string','double','double','double','double','double','double'}, ...
    'VariableNames', {'PointId','X','Y','Z','dX','dY','dZ'});
end
