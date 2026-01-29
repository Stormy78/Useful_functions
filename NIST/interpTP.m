function out = interpTP(tbl, valueCol, Tq, Pq)
T = tbl{:,1};
P = tbl{:,2};
V = tbl.(valueCol);

% robust approach (scattered)
F = scatteredInterpolant(T, P, V, 'linear', 'nearest');
out = F(Tq, Pq);
end