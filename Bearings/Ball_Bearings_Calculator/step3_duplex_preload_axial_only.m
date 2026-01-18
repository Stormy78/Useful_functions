%% STEP 3 (CLEAN) — Duplex OPPOSED (DB/DF), Preload + External Axial Only
% -------------------------------------------------------------------------
% What this script does:
%   - Two identical bearings in opposed duplex (DB or DF)
%   - Preload per bearing: Fpre (internal)
%   - External axial load: Fz_ext applied to the pair
%   - Solves mid-plane axial deflection z_mid such that:
%         Fz_ext = FzA - FzB
%     where FzA, FzB are bearing axial reaction magnitudes (>=0)
%   - Reports:
%       preload-only internal states (A and B)
%       combined internal states (A and B) under Fz_ext
%       load sharing (FzA, FzB) + unloaded bearing detection
%       per-ball listing and polar plots for both bearings
%
% Units:
%   Inputs : d,D,Db,L [mm], Z [-], alpha0 [deg], Fpre, Fz_ext [N]
%   Outputs: z_mid [microns], per-ball Q [N], p0 [GPa]

clear; clc;

%% ---- Inputs ----
arr = upper(strtrim(input("Arrangement ('DB' or 'DF'): ", "s")));
if arr ~= "DB" && arr ~= "DF"
    error("Arrangement must be 'DB' or 'DF'");
end
sTilt = +1; if arr=="DF", sTilt = -1; end %#ok<NASGU> % (tilt not used in axial-only)

d_mm   = input('Bore d [mm]: ');
D_mm   = input('OD D [mm]: ');
Db_mm  = input('Ball diameter Db [mm]: ');
Z      = input('Ball count Z [-]: ');
alpha0 = deg2rad(input('Contact angle alpha0 [deg]: '));
L_mm   = input('Bearing separation L [mm]: ');

Fpre   = input('Preload force Fpre [N] (PER BEARING internal): ');
Fz_ext = input('External axial load Fz_ext [N] (+Z on pair): ');

if Z<=0 || Db_mm<=0 || d_mm<=0 || D_mm<=d_mm, error('Non-physical geometry inputs.'); end
if Fpre<=0, error('Fpre must be > 0'); end
if alpha0<=0 || alpha0>=pi/2, error('alpha0 must be between 0 and 90 deg'); end

%% ---- Geometry & preload baseline (SI) ----
geom = make_geom(d_mm, D_mm, Db_mm, Z, alpha0, L_mm);

% Preload-only: uniform ball normal load per bearing
Qpre = Fpre / (Z * sin(alpha0));          % [N] per ball
geom.delta0 = (Qpre / geom.Kh_eff)^(2/3); % [m] preload baseline

% Preload-only states (mid-plane z=0 => zA=0, zB=0)
A_pre = bearing_state_axial(0, geom); % zA=0
B_pre = bearing_state_axial(0, geom); % zB=0

%% ---- Solve z_mid for external axial equilibrium ----
% OPPOSED mapping:
%   zA = +z_mid
%   zB = -z_mid
% External equilibrium:
%   Fz_ext = FzA(zA) - FzB(zB)

opt.tol = 1e-10;
opt.maxBracket = 1e-2; % meters
z_mid = solve_1d(@(z) axial_pair_ext_from_z(z, geom) - Fz_ext, opt);

% Combined states
A_comb = bearing_state_axial(+z_mid, geom);
B_comb = bearing_state_axial(-z_mid, geom);

%% ---- Report ----
fprintf('\n================ STEP 3: DUPLEX OPPOSED (AXIAL ONLY) [%s] ================\n', arr);
fprintf('Inputs:\n');
fprintf('  d=%.3f mm, D=%.3f mm, Db=%.3f mm, Z=%d, alpha0=%.3f deg, L=%.3f mm\n', ...
    d_mm, D_mm, Db_mm, Z, rad2deg(alpha0), L_mm);
fprintf('  Fpre(per bearing)=%.3f N, Fz_ext=%.3f N\n', Fpre, Fz_ext);

fprintf('\nSolved mid-plane axial deflection:\n');
fprintf('  z_mid = %.6f microns\n', z_mid*1e6);

fprintf('\nPRELOAD-ONLY (each bearing):\n');
fprintf('  Bearing A: Fz=%.6f N, loaded balls=%d/%d, max p0=%.3f GPa\n', ...
    A_pre.Fz, nnz(A_pre.loaded), Z, A_pre.p0max_GPa);
fprintf('  Bearing B: Fz=%.6f N, loaded balls=%d/%d, max p0=%.3f GPa\n', ...
    B_pre.Fz, nnz(B_pre.loaded), Z, B_pre.p0max_GPa);

fprintf('\nCOMBINED (preload + external):\n');
fprintf('  Bearing A: FzA=%.6f N, loaded balls=%d/%d, max p0=%.3f GPa\n', ...
    A_comb.Fz, nnz(A_comb.loaded), Z, A_comb.p0max_GPa);
fprintf('  Bearing B: FzB=%.6f N, loaded balls=%d/%d, max p0=%.3f GPa\n', ...
    B_comb.Fz, nnz(B_comb.loaded), Z, B_comb.p0max_GPa);

fprintf('\nLoad sharing check:\n');
fprintf('  FzA - FzB = %.6f N (should equal Fz_ext)\n', A_comb.Fz - B_comb.Fz);

if nnz(B_comb.loaded)==0
    fprintf('  NOTE: Bearing B fully unloaded (no contact).\n');
elseif nnz(A_comb.loaded)==0
    fprintf('  NOTE: Bearing A fully unloaded (no contact).\n');
end

fprintf('=============================================================================\n\n');

%% ---- Per-ball listing ----
print_ball_report(A_comb, alpha0, 'Bearing A (COMBINED)');
print_ball_report(B_comb, alpha0, 'Bearing B (COMBINED)');

%% ---- Polar plots (A and B) ----
plot_polar_Q_p0(A_comb, 'Bearing A (COMBINED)');
plot_polar_Q_p0(B_comb, 'Bearing B (COMBINED)');

%% ===================== FUNCTIONS =====================

function geom = make_geom(d_mm, D_mm, Db_mm, Z, alpha0, L_mm)
    geom.d  = d_mm*1e-3;
    geom.D  = D_mm*1e-3;
    geom.Db = Db_mm*1e-3;
    geom.Z  = Z;
    geom.alpha = alpha0;
    geom.L  = L_mm*1e-3;

    geom.Dm = 0.5*(geom.d + geom.D);
    geom.rm = 0.5*geom.Dm;

    geom.f  = 0.53;
    geom.Rb = 0.5*geom.Db;
    geom.Rg = geom.f * geom.Db;

    geom.Rc_i = max(geom.rm - geom.Rb, 1e-12);
    geom.Rc_o = max(geom.rm + geom.Rb, 1e-12);

    E=210e9; nu=0.30;
    geom.Ered = E/(2*(1-nu^2));

    geom.phi = (0:Z-1)'*(2*pi/Z);

    Req_x  = rel_radius_concave(geom.Rb, geom.Rg);
    Req_y  = rel_radius_concave(geom.Rb, 0.5*(geom.Rc_i+geom.Rc_o));
    Req_eff = sqrt(max(Req_x,1e-30)*max(Req_y,1e-30));
    geom.Kh_eff = (4/3)*geom.Ered*sqrt(Req_eff);

    geom.delta0 = 0;
end

function Req = rel_radius_concave(Rb, Rconcave)
    denom = (1/max(Rb,1e-30) - 1/max(Rconcave,1e-30));
    if denom <= 0
        Req = 1e-12;
    else
        Req = 1/denom;
    end
end

function st = bearing_state_axial(zlocal, geom)
    % axial-only => delta_k identical for all balls
    sa = sin(geom.alpha);

    delta = geom.delta0 + zlocal*sa;   % [m], same for all balls
    loaded = delta > 0;

    Q = zeros(geom.Z,1);
    if loaded
        Q(:) = geom.Kh_eff * delta^(3/2);
    end

    Fz = sum(Q)*sa;

    Req_x  = rel_radius_concave(geom.Rb, geom.Rg);
    Req_yi = rel_radius_concave(geom.Rb, geom.Rc_i);
    Req_yo = rel_radius_concave(geom.Rb, geom.Rc_o);

    p0i = elliptic_p0_GPa(Q, Req_x, Req_yi, geom.Ered);
    p0o = elliptic_p0_GPa(Q, Req_x, Req_yo, geom.Ered);
    p0max_ball = max(p0i, p0o);

    st.phi_rad = geom.phi;
    st.loaded  = loaded * ones(geom.Z,1);
    st.Q_N     = Q;
    st.delta_m = delta * ones(geom.Z,1);

    st.Fz = Fz;

    st.p0i_GPa = p0i;
    st.p0o_GPa = p0o;
    st.p0max_ball_GPa = p0max_ball;
    st.p0max_GPa = max(p0max_ball);
end

function F = axial_pair_ext_from_z(zmid, geom)
    A = bearing_state_axial(+zmid, geom);
    B = bearing_state_axial(-zmid, geom);
    F = A.Fz - B.Fz;
end

function x = solve_1d(fun, opt)
    x0 = 0; f0 = fun(x0);
    x1 = 1e-9; f1 = fun(x1);
    while sign(f0) == sign(f1)
        x1 = x1*2 + 1e-9;
        f1 = fun(x1);
        if x1 > opt.maxBracket
            error('1D solver failed to bracket root. Check Fpre/Fz_ext.');
        end
    end
    x = fzero(fun, [x0 x1]);
end

function p0_GPa = elliptic_p0_GPa(Q, Req_x, Req_y, Ered)
    Q = max(Q,0);
    a = (3 .* Q .* max(Req_x,1e-30) ./ (4 .* Ered)).^(1/3);
    b = (3 .* Q .* max(Req_y,1e-30) ./ (4 .* Ered)).^(1/3);
    p0 = (3 .* Q) ./ (2 .* pi .* max(a.*b, 1e-30));
    p0_GPa = p0 / 1e9;
end

function print_ball_report(state, alpha0, tag)
    fprintf('\n--- PER BALL REPORT (%s) ---\n', tag);
    fprintf(' k |  phi[deg] | loaded | delta[um] |   Q[N]   | p0_i[GPa] | p0_o[GPa] | p0_max[GPa] | beta_rad[deg]\n');
    fprintf('---+----------+--------+-----------+----------+----------+----------+-------------+--------------\n');

    phi_deg  = rad2deg(state.phi_rad);
    delta_um = state.delta_m * 1e6;

    beta_deg = nan(numel(phi_deg),1);
    beta_deg(state.loaded>0) = rad2deg(alpha0); % from radial direction (fixed-alpha model)

    for k=1:numel(phi_deg)
        if state.loaded(k)
            fprintf('%2d | %8.2f |   %d    | %9.3f | %8.3f | %8.3f | %8.3f | %11.3f | %12.3f\n', ...
                k, phi_deg(k), 1, delta_um(k), state.Q_N(k), ...
                state.p0i_GPa(k), state.p0o_GPa(k), state.p0max_ball_GPa(k), beta_deg(k));
        else
            fprintf('%2d | %8.2f |   %d    | %9.3f | %8.3f | %8.3f | %8.3f | %11.3f | %12s\n', ...
                k, phi_deg(k), 0, delta_um(k), 0.0, ...
                state.p0i_GPa(k), state.p0o_GPa(k), state.p0max_ball_GPa(k), 'NaN');
        end
    end
end

function plot_polar_Q_p0(state, plotTitlePrefix)
    phi = state.phi_rad;
    phi_c = [phi; phi(1)];

    Q_c  = [state.Q_N; state.Q_N(1)];
    p0_c = [state.p0max_ball_GPa; state.p0max_ball_GPa(1)];

    figure;
    polarplot(phi_c, Q_c, '-o','LineWidth',1.5);
    title([plotTitlePrefix ' — Q per ball (polar)']);
    set(gca,'ThetaZeroLocation','right','ThetaDir','counterclockwise');
    grid on;

    figure;
    polarplot(phi_c, p0_c, '-o','LineWidth',1.5);
    title([plotTitlePrefix ' — max p0 per ball (polar)']);
    set(gca,'ThetaZeroLocation','right','ThetaDir','counterclockwise');
    grid on;
end
