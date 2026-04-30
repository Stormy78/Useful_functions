clearvars
%% ------- PARAMETERS ---------

theta_prism = 8; %[deg] - prism angle
d_prism = 25.4; %prism Diameter
t_prism = 3.7; %prism center thickness

% LOCATIONS
s_prism = 10.1; % prism separation distance
P_screen = [30;0;0]; % screen location

% MATERIALS
eta_air = 1;
eta_glass = 1.5;
%% ----- INITIAL GEOMETRY -------

P_A_front = [0;0;0]; %point on first face of prism A
P_A_back = [t_prism;0;0]; %point on second face of prism A

v_i = [1;0;0]; %incidence beam vector
Q_i = [-20;0;0]; %incidence beam source point

P_B_front = P_A_back + [s_prism;0;0]; %point on first face of prism B
P_B_back = P_B_front + [t_prism;0;0]; %point on second face of prism B

delta = d_prism/2 * tand(theta_prism); %prism edge axial distance to center point, inclined surface side

n_A = [-cosd(theta_prism);sind(theta_prism);0]; % prism A inclined face normal
n_B = [-cosd(theta_prism);sind(theta_prism);0]; % prism B inclined face normal

surfacesPoints = [P_A_front P_A_back P_B_front P_B_back P_screen];
%% ---- AUX FUNCTIONS ----

Rx = @(t) [1    0       0; 
           0   cosd(t) -sind(t); 
           0   sind(t)  cosd(t)];