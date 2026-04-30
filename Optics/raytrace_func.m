function [trace_points] = raytrace_func(phiA, phiB, v_i, Q_i, n_A, n_B, eta_air, eta_glass, surfacesPoints, Rx)

n_A_i = Rx(phiA)*n_A; %prism A first surface normal , after rotation
n_B_i = Rx(phiB)*n_B; %prism B second surface normal , after rotation

% hit S1 of prism A
R1 = intersect_func(v_i, n_A_i, surfacesPoints(:,1), Q_i); %incidence ray on first surface of prism A
t1 = refraction_func(v_i, n_A_i, eta_air, eta_glass);

% hit S2 of prism A
R2 = intersect_func(t1, [-1;0;0], surfacesPoints(:,2), R1);
t2 = refraction_func(t1, [-1;0;0], eta_glass, eta_air);

% hit S1 of prism B
R3 = intersect_func(t2, [-1;0;0], surfacesPoints(:,3), R2);
t3 = refraction_func(t2, [-1;0;0], eta_air, eta_glass);

% his S2 of prism B
R4 = intersect_func(t3, n_B_i,surfacesPoints(:,4), R3);
t4 = refraction_func(t3, n_B_i, eta_glass, eta_air);

% his screen
R_screen = intersect_func(t4, [-1;0;0], surfacesPoints(:,5), R4);

%Summary
trace_points = [Q_i R1 R2 R3 R4 R_screen]';

end