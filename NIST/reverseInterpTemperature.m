function Tsol = reverseInterpTemperature(tbl, valueCol, Pq, Vq)

T = tbl{:,1};
P = tbl{:,2};
V = tbl.(valueCol);

% Build interpolant
F = scatteredInterpolant(T, P, V, 'linear', 'nearest');

% Root function
g = @(Temp) F(Temp, Pq) - Vq;

% Bounds
Tmin = min(T);
Tmax = max(T);

% Solve
Tsol = fzero(g, [Tmin Tmax]);

end
