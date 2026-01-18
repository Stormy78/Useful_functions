%% STEP 1 — Single ACBB, Preload Only (No duplex, no external load)
% Units:
%   Inputs : d,D,Db [mm], Z [-], alpha0 [deg], Fpre [N]
%   Outputs: delta0 [microns], z_pre [microns], Q0 [N], p0 [GPa]
%
% Assumptions (general-case):
%   - Steel: E=210 GPa, nu=0.30
%   - Conformity f=0.53 => groove radius Rg = f*Db
%   - Pitch diameter Dm: mean of bore/OD: Dm=(d+D)/2
%   - Hertz load law (effective): Q = Kh_eff * delta^(3/2)
%     where Kh_eff derived from equivalent radii in two directions (approx)
%   - All balls carry equal load under pure preload

clear; clc;

%% ---- User inputs ----
d_mm   = input('Bore d [mm]: ');
D_mm   = input('OD D [mm]: ');
Db_mm  = input('Ball diameter Db [mm]: ');
Z      = input('Ball count Z [-]: ');
alpha0 = deg2rad(input('Contact angle alpha0 [deg]: '));
Fpre   = input('Preload force Fpre [N] (single bearing axial preload): ');

if Z <= 0 || Db_mm <= 0 || d_mm <= 0 || D_mm <= d_mm
    error('Non-physical geometry inputs.');
end
if Fpre <= 0
    error('Fpre must be > 0 for preload-only step.');
end
if alpha0 <= 0 || alpha0 >= pi/2
    error('alpha0 must be between 0 and 90 deg.');
end

%% ---- Geometry (SI) ----
d  = d_mm*1e-3;
D  = D_mm*1e-3;
Db = Db_mm*1e-3;

Dm = 0.5*(d + D);         % mean pitch diameter assumption
rm = 0.5*Dm;

f  = 0.53;
Rb = 0.5*Db;
Rg = f*Db;                % concave groove radius

% Circumferential radii (approx)
Rc_i = max(rm - Rb, 1e-12);
Rc_o = max(rm + Rb, 1e-12);

%% ---- Material ----
E  = 210e9; nu = 0.30;
Ered = E/(2*(1-nu^2));    % identical steel bodies

%% ---- Preload ball load (preload-only: all balls equal) ----
% Axial preload relates to normal load via sin(alpha)
Q0 = Fpre / (Z * sin(alpha0));    % [N] per ball normal load

%% ---- Hertz effective stiffness for load-deflection (approx) ----
% Relative radii:
Req_x  = rel_radius_concave(Rb, Rg);                 % groove direction
Req_y  = rel_radius_concave(Rb, 0.5*(Rc_i + Rc_o));  % circumferential approx
Req_eff = sqrt(max(Req_x,1e-30) * max(Req_y,1e-30));

Kh_eff = (4/3) * Ered * sqrt(Req_eff);   % Q = Kh_eff * delta^(3/2)

% Normal approach delta0
delta0_m  = (Q0 / Kh_eff)^(2/3);         % [m]
delta0_um = delta0_m * 1e6;              % [microns]

% Axial deflection due to preload
zpre_m  = delta0_m / sin(alpha0);        % [m]
zpre_um = zpre_m * 1e6;                  % [microns]

%% ---- Hertz peak pressure p0 (inner & outer, elliptical approx) ----
% Use two different circumferential radii for inner/outer contacts
Req_yi = rel_radius_concave(Rb, Rc_i);
Req_yo = rel_radius_concave(Rb, Rc_o);

p0i_GPa = elliptic_p0_GPa(Q0, Req_x, Req_yi, Ered);
p0o_GPa = elliptic_p0_GPa(Q0, Req_x, Req_yo, Ered);
p0max_GPa = max(p0i_GPa, p0o_GPa);

%% ---- Report ----
fprintf('\n================ STEP 1: SINGLE BEARING, PRELOAD ONLY ================\n');
fprintf('Inputs:\n');
fprintf('  d=%.3f mm, D=%.3f mm, Db=%.3f mm, Z=%d, alpha0=%.3f deg\n', ...
    d_mm, D_mm, Db_mm, Z, rad2deg(alpha0));
fprintf('  Dm(mean)=%.3f mm, conformity f=%.2f\n', Dm*1e3, f);
fprintf('  Fpre=%.3f N\n', Fpre);

fprintf('\nPer-ball preload:\n');
fprintf('  Q0 = %.3f N (normal load per ball)\n', Q0);

fprintf('\nDeflections:\n');
fprintf('  delta0 = %.3f microns (normal approach)\n', delta0_um);
fprintf('  z_pre  = %.3f microns (axial deflection under preload)\n', zpre_um);

fprintf('\nHertz peak pressure (elliptical approx):\n');
fprintf('  p0 inner = %.3f GPa\n', p0i_GPa);
fprintf('  p0 outer = %.3f GPa\n', p0o_GPa);
fprintf('  p0 max   = %.3f GPa\n', p0max_GPa);
fprintf('======================================================================\n\n');

%% ---- Optional quick plots (flat lines) ----
doPlots = upper(strtrim(input("Plot per-ball Q and p0? (Y/N): ","s")));
if doPlots=="Y"
    k = (1:Z)';
    Qk = Q0*ones(Z,1);
    p0k = p0max_GPa*ones(Z,1);

    phi = (0:Z-1)' * 2*pi/Z;

    % --- Polar plot: normal load ---
    figure;
    polarplot([phi; phi(1)], [Qk; Qk(1)], '-o','LineWidth',1.5);
    title('Preload-only: per-ball normal load Q [N]');
    set(gca,'ThetaZeroLocation','right','ThetaDir','counterclockwise');
    grid on;

    % --- Polar plot: Hertz stress ---
    figure;
    polarplot([phi; phi(1)], [p0k; p0k(1)], '-o','LineWidth',1.5);
    title('Preload-only: per-ball Hertz p_0 [GPa]');
    set(gca,'ThetaZeroLocation','right','ThetaDir','counterclockwise');
    grid on;
end

%% ===================== helper functions =====================
function Req = rel_radius_concave(Rb, Rconcave)
% Convex ball vs concave groove: 1/Req = 1/Rb - 1/Rconcave
denom = (1/max(Rb,1e-30) - 1/max(Rconcave,1e-30));
if denom <= 0
    Req = 1e-12;
else
    Req = 1/denom;
end
end

function p0_GPa = elliptic_p0_GPa(Q, Req_x, Req_y, Ered)
% Elliptical Hertz approximation:
% a = (3 Q Req_x /(4E'))^(1/3), b = (3 Q Req_y /(4E'))^(1/3)
% p0 = 3Q /(2*pi*a*b)
Q = max(Q,0);
a = (3 .* Q .* max(Req_x,1e-30) ./ (4 .* Ered)).^(1/3);
b = (3 .* Q .* max(Req_y,1e-30) ./ (4 .* Ered)).^(1/3);
p0 = (3 .* Q) ./ (2 .* pi .* max(a.*b, 1e-30));
p0_GPa = p0 / 1e9;
end