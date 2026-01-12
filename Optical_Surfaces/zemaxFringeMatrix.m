function A = zemaxFringeMatrix(rho, theta, nTerms)
% A = zemaxFringeMatrix(rho, theta, nTerms)
% Design matrix (Nx nTerms) for Zemax OpticStudio "Zernike Fringe" (Wyant) sag polynomials.
% Use: coeff = A \ dz;
%
% Inputs:
%   rho   : Nx1 normalized radius in [0,1]
%   theta : Nx1 azimuth angle [rad]
%   nTerms: number of Fringe terms (<=37)
%
% Output:
%   A     : Nx nTerms design matrix, columns are terms 1..nTerms in Zemax order

rho   = rho(:);
theta = theta(:);
assert(numel(rho) == numel(theta), 'rho and theta must be same length');
assert(nTerms >= 1 && nTerms <= 37, 'nTerms must be in [1,37]');

N = numel(rho);
A = zeros(N, nTerms);

c1 = cos(theta);   s1 = sin(theta);
c2 = cos(2*theta); s2 = sin(2*theta);
c3 = cos(3*theta); s3 = sin(3*theta);
c4 = cos(4*theta); s4 = sin(4*theta);
c5 = cos(5*theta); s5 = sin(5*theta);

r1 = rho;
r2 = rho.^2;
r3 = rho.^3;
r4 = rho.^4;
r5 = rho.^5;

% Helper to safely assign if term requested
    function put(k, v)
        if nTerms >= k, A(:,k) = v; end
    end

% --- Terms 1..20 (as listed earlier) ---
put( 1, 1);
put( 2, r1 .* c1);
put( 3, r1 .* s1);
put( 4, 2*r2 - 1);
put( 5, r2 .* s2);
put( 6, r2 .* c2);
put( 7, (3*r3 - 2*r1) .* s1);
put( 8, (3*r3 - 2*r1) .* c1);
put( 9, r3 .* s3);
put(10, r3 .* c3);
put(11, 6*r4 - 6*r2 + 1);
put(12, (4*r4 - 3*r2) .* s2);
put(13, (4*r4 - 3*r2) .* c2);
put(14, r4 .* s4);
put(15, r4 .* c4);
put(16, (10*r5 - 12*r3 + 3*r1) .* s1);
put(17, (10*r5 - 12*r3 + 3*r1) .* c1);
put(18, (5*r5 - 4*r3) .* s3);
put(19, (5*r5 - 4*r3) .* c3);
put(20, r5 .* s5);

% --- Terms 21..37 (complete the Zemax Fringe set up to 37) ---
% Notes:
% 21  Pentafoil X        rho^5 cos5θ
% 22  Secondary spherical 20ρ^6 - 30ρ^4 + 12ρ^2 - 1
% 23  Tertiary astig 45° (15ρ^6 - 20ρ^4 + 6ρ^2) sin2θ
% 24  Tertiary astig 0°  (15ρ^6 - 20ρ^4 + 6ρ^2) cos2θ
% 25  Secondary quad Y   (6ρ^6 - 5ρ^4) sin4θ
% 26  Secondary quad X   (6ρ^6 - 5ρ^4) cos4θ
% 27  Hexafoil Y         ρ^6 sin6θ
% 28  Hexafoil X         ρ^6 cos6θ
% 29  Tertiary coma Y    (35ρ^7 - 60ρ^5 + 30ρ^3 - 4ρ) sinθ
% 30  Tertiary coma X    (35ρ^7 - 60ρ^5 + 30ρ^3 - 4ρ) cosθ
% 31  Tertiary trefoil Y (21ρ^7 - 30ρ^5 + 10ρ^3) sin3θ
% 32  Tertiary trefoil X (21ρ^7 - 30ρ^5 + 10ρ^3) cos3θ
% 33  Secondary penta Y  (7ρ^7 - 6ρ^5) sin5θ
% 34  Secondary penta X  (7ρ^7 - 6ρ^5) cos5θ
% 35  Heptafoil Y        ρ^7 sin7θ
% 36  Heptafoil X        ρ^7 cos7θ
% 37  Tertiary spherical 70ρ^8 - 140ρ^6 + 90ρ^4 - 20ρ^2 + 1

r6 = rho.^6; r7 = rho.^7; r8 = rho.^8;
c6 = cos(6*theta); s6 = sin(6*theta);
c7 = cos(7*theta); s7 = sin(7*theta);

put(21, r5 .* c5);
put(22, 20*r6 - 30*r4 + 12*r2 - 1);
put(23, (15*r6 - 20*r4 + 6*r2) .* s2);
put(24, (15*r6 - 20*r4 + 6*r2) .* c2);
put(25, (6*r6 - 5*r4) .* s4);
put(26, (6*r6 - 5*r4) .* c4);
put(27, r6 .* s6);
put(28, r6 .* c6);
put(29, (35*r7 - 60*r5 + 30*r3 - 4*r1) .* s1);
put(30, (35*r7 - 60*r5 + 30*r3 - 4*r1) .* c1);
put(31, (21*r7 - 30*r5 + 10*r3) .* s3);
put(32, (21*r7 - 30*r5 + 10*r3) .* c3);
put(33, (7*r7 - 6*r5) .* s5);
put(34, (7*r7 - 6*r5) .* c5);
put(35, r7 .* s7);
put(36, r7 .* c7);
put(37, 70*r8 - 140*r6 + 90*r4 - 20*r2 + 1);

end
