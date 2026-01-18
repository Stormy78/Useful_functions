%% STEP 2 (CLEAN) — Single ACBB, PRELOAD + External Axial & Radial (Combined Internal State)
% -------------------------------------------------------------------------
% What this script does:
%   - Builds preload-only internal state (ball loads, p0, etc.)
%   - Solves incremental deflections [x; z] that create the requested external loads (Fz_ext, Fr_ext)
%   - Reports BOTH:
%       (1) Preload-only internal state
%       (2) Combined internal state = preload + external
%   - Polar (radial) plots for per-ball Q and per-ball max p0 (COMBINED state)
%
% Units:
%   Inputs : d,D,Db [mm], Z [-], alpha0 [deg], Fpre,Fz,Fr [N]
%   Outputs: x,z [microns], per-ball Q [N], p0 [GPa], loaded mask
%
% Model:
%   delta_k = delta0 + z*sin(alpha0) + x*cos(alpha0)*cos(phi_k)
%   Q_k = Kh_eff * delta_k^(3/2) for delta_k>0 else 0
%   Fz = sum(Q)*sin(alpha0)
%   Fr = sum(Q*cos(alpha0)*cos(phi))
%   Fixed alpha0 (no angle migration)

clear; clc;

%% ---- Inputs ----
d_mm   = input('Bore d [mm]: ');
D_mm   = input('OD D [mm]: ');
Db_mm  = input('Ball diameter Db [mm]: ');
Z      = input('Ball count Z [-]: ');
alpha0 = deg2rad(input('Contact angle alpha0 [deg]: '));

Fpre   = input('Preload force Fpre [N] (single bearing): ');
Fz_ext = input('External axial load Fz [N] (+Z): ');
Fr_ext = input('External radial load Fr [N] (+X): ');

% Basic validation
if Z<=0 || Db_mm<=0 || d_mm<=0 || D_mm<=d_mm, error('Non-physical geometry inputs.'); end
if Fpre<=0, error('Fpre must be > 0'); end
if alpha0<=0 || alpha0>=pi/2, error('alpha0 must be between 0 and 90 deg'); end

%% ---- Geometry & preload baseline (SI internally) ----
geom = make_geom(d_mm, D_mm, Db_mm, Z, alpha0);

% Preload-only: uniform ball normal load (all balls equal)
Qpre = Fpre / (Z * sin(alpha0));          % [N] per ball normal load
geom.delta0 = (Qpre / geom.Kh_eff)^(2/3); % [m] baseline normal approach from preload

fprintf('DEBUG: Qpre=%.6f N, Kh_eff=%.6e, delta0=%.6e m\n', Qpre, geom.Kh_eff, geom.delta0);


% Preload-only internal state (combined internal = preload + 0 external)
state_pre = bearing_state_xz(0, 0, geom);

%% ---- Solve incremental deflections [x; z] to match external loads ----
Fz_total = Fpre + Fz_ext;    % total axial reaction including preload
target   = [Fz_total; Fr_ext];

opt.maxIter = 80;
opt.tol = 1e-8;
opt.fd = 1e-9;

[q_xz, state_comb, Rcheck] = solve_xz(target, geom, opt);

x_um = q_xz(1)*1e6;
z_um = q_xz(2)*1e6;

%% ---- Report ----
fprintf('\n================ STEP 2: SINGLE BEARING (PRELOAD + Fz + Fr) ================\n');
fprintf('Inputs:\n');
fprintf('  d=%.3f mm, D=%.3f mm, Db=%.3f mm, Z=%d, alpha0=%.3f deg\n', ...
    d_mm, D_mm, Db_mm, Z, rad2deg(alpha0));
fprintf('  Dm(mean)=%.3f mm, conformity f=%.2f\n', geom.Dm*1e3, geom.f);
fprintf('  Fpre=%.3f N, Fz_ext=%.3f N, Fr_ext=%.3f N\n', Fpre, Fz_ext, Fr_ext);

fprintf('\nSolved incremental deflections (to generate external loads):\n');
fprintf('  x = %.3f microns\n', x_um);
fprintf('  z = %.3f microns\n', z_um);

fprintf('\nEquilibrium check (external):\n');
fprintf('  computed Fz=%.6f N, Fr=%.6f N\n', Rcheck(1), Rcheck(2));
fprintf('  residual dFz=%.3e, dFr=%.3e\n', Rcheck(1)-Fz_ext, Rcheck(2)-Fr_ext);

fprintf('\n--- PRELOAD-ONLY INTERNAL STATE ---\n');
fprintf('  loaded balls = %d/%d\n', nnz(state_pre.loaded), Z);
fprintf('  Qpre (per ball) = %.3f N\n', state_pre.Q_N(1));
fprintf('  max Q = %.3f N\n', max(state_pre.Q_N));
fprintf('  max p0 = %.3f GPa\n', state_pre.p0max_GPa);

fprintf('\n--- COMBINED INTERNAL STATE (preload + external) ---\n');
fprintf('  loaded balls = %d/%d\n', nnz(state_comb.loaded), Z);
fprintf('  max Q = %.3f N\n', max(state_comb.Q_N));
fprintf('  max p0 = %.3f GPa\n', state_comb.p0max_GPa);
fprintf('=============================================================================\n\n');

print_ball_report(state_comb, alpha0, 'COMBINED (preload + external)');
%% ---- Polar plots (COMBINED state) ----
phi = state_comb.phi_rad;

phi_c = [phi; phi(1)];
Q_c   = [state_comb.Q_N; state_comb.Q_N(1)];
p0_c  = [state_comb.p0max_ball_GPa; state_comb.p0max_ball_GPa(1)];

figure;
polarplot(phi_c, Q_c, '-o','LineWidth',1.5);
title('Step 2: Per-ball normal load Q (COMBINED state)');
set(gca,'ThetaZeroLocation','right','ThetaDir','counterclockwise');
grid on;

figure;
polarplot(phi_c, p0_c, '-o','LineWidth',1.5);
title('Step 2: Per-ball max Hertz p_0 (COMBINED state)');
set(gca,'ThetaZeroLocation','right','ThetaDir','counterclockwise');
grid on;

%% ===================== FUNCTIONS =====================

function geom = make_geom(d_mm, D_mm, Db_mm, Z, alpha0)
    geom.d  = d_mm*1e-3;
    geom.D  = D_mm*1e-3;
    geom.Db = Db_mm*1e-3;
    geom.Z  = Z;
    geom.alpha = alpha0;

    geom.Dm = 0.5*(geom.d + geom.D);  % mean pitch diameter assumption
    geom.rm = 0.5*geom.Dm;

    geom.f  = 0.53;
    geom.Rb = 0.5*geom.Db;
    geom.Rg = geom.f * geom.Db;

    geom.Rc_i = max(geom.rm - geom.Rb, 1e-12);
    geom.Rc_o = max(geom.rm + geom.Rb, 1e-12);

    E=210e9; nu=0.30;
    geom.Ered = E/(2*(1-nu^2));

    geom.phi = (0:Z-1)'*(2*pi/Z);

    % effective Hertz coefficient (approx)
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

function [q, state_comb, Rcheck] = solve_xz(target, geom, opt)
    % target = [Fz_ext; Fr_ext]
    q = zeros(2,1); % [x; z] incremental deflections from preload baseline

    for it=1:opt.maxIter
        st0 = bearing_state_xz(q(1), q(2), geom);
        R0  = [st0.Fz; st0.Fr];
        res = R0 - target;

        if norm(res) < opt.tol
            state_comb = st0;
            Rcheck = R0;
            return;
        end

        % Jacobian by finite differences
        J = zeros(2,2);
        for k=1:2
            dq = zeros(2,1); dq(k) = opt.fd;
            stp = bearing_state_xz(q(1)+dq(1), q(2)+dq(2), geom);
            Rp  = [stp.Fz; stp.Fr];
            J(:,k) = (Rp - R0)/opt.fd;
        end

        if rcond(J) < 1e-12
            step = -pinv(J)*res;
        else
            step = -J\res;
        end

        % Damped update to avoid stepping into "all unloaded" region
        lam = 1.0;
        accepted = false;
        for ls=1:12
            q_try = q + lam*step;
            st_try = bearing_state_xz(q_try(1), q_try(2), geom);
            R_try  = [st_try.Fz; st_try.Fr];

            if all(isfinite(R_try)) && norm(R_try-target) < norm(R0-target)
                q = q_try;
                accepted = true;
                break;
            end
            lam = 0.5*lam;
        end
        if ~accepted
            q = q + 1e-3*step;
        end
    end

    % final
    state_comb = bearing_state_xz(q(1), q(2), geom);
    Rcheck = [state_comb.Fz; state_comb.Fr];
end

function st = bearing_state_xz(x, z, geom)
    sa = sin(geom.alpha);
    ca = cos(geom.alpha);

    delta = geom.delta0 + z*sa + x*ca*cos(geom.phi);

    loaded = delta > 0;
    Q = zeros(geom.Z,1);
    Q(loaded) = geom.Kh_eff .* (delta(loaded)).^(3/2);

    Fz = sum(Q)*sa;
    Fr = sum(Q .* ca .* cos(geom.phi));

    % Hertz p0 inner/outer per ball, take max per ball
    Req_x  = rel_radius_concave(geom.Rb, geom.Rg);
    Req_yi = rel_radius_concave(geom.Rb, geom.Rc_i);
    Req_yo = rel_radius_concave(geom.Rb, geom.Rc_o);

    p0i = elliptic_p0_GPa(Q, Req_x, Req_yi, geom.Ered);
    p0o = elliptic_p0_GPa(Q, Req_x, Req_yo, geom.Ered);
    p0max_ball = max(p0i, p0o);

    st.phi_rad = geom.phi;
    st.loaded  = loaded;
    st.Q_N     = Q;
    st.delta_m = delta;

    st.Fz = Fz;
    st.Fr = Fr;

    st.p0i_GPa = p0i;
    st.p0o_GPa = p0o;
    st.p0max_ball_GPa = p0max_ball;
    st.p0max_GPa = max(p0max_ball);
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

    phi_deg   = rad2deg(state.phi_rad);
    delta_um  = state.delta_m * 1e6;

    beta_deg = nan(numel(phi_deg),1);
    beta_deg(state.loaded) = rad2deg(alpha0); % from radial direction

    for k = 1:numel(phi_deg)
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

    fprintf('Loaded balls = %d/%d\n', nnz(state.loaded), numel(state.loaded));
    fprintf('Max Q        = %.3f N\n', max(state.Q_N));
    fprintf('Max p0       = %.3f GPa\n', state.p0max_GPa);
end
