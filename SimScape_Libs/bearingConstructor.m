function [S] = bearingConstructor(Kax,Krad, Kang, Tf, Jref, mref, zeta)

%% Bearing Object
%Kax - Bearing axial stiffness - [N/mm]
%Krad - Bearing radial stiffness - [N/mm]
%Kang - Bearing axial stiffness - [N/mm]
%Tf - Bearing Rotational Friction - [mNm]
%Jref - Reference Payload Inertia - [kg mm^2]
%mref - Reference Payload mass - [kg]
%zeta - Bearing Reference Damping Ratio - [%]
%Cax - Bearing axial damping coeff - [N/(m/s)]
%Crad - Bearing radial dampin2.0g coeff - [N/(m/s)]
%Cang - Bearing angular damping coeff - [Nm/(rad/s)]
%%

S.Kax = Kax; %[N/mm]
S.Krad = Krad; %[N/mm]
S.Kang = Kang; %[Nm/Rad]
S.Tf = Tf; %[mNm]
S.Jref = Jref; %[kg mm^2]
S.mref = mref; %[kg]
S.zeta = zeta/100;

S.Wax_ref = sqrt(S.Kax*1e3/S.mref); %[rad/s]
S.Wrad_ref = sqrt(S.Krad*1e3/S.mref); %[rad/s]
S.Wang_ref = sqrt(S.Kang/(S.Jref*1e-6)); %[rad/s]

S.Cax = 2*(S.zeta)*(S.Wax_ref)*(S.mref); %[N/(m/s)]
S.Crad = 2*(S.zeta)*(S.Wrad_ref)*(S.mref); %[N/(m/s)]
S.Cang = 2*(S.zeta)*(S.Wang_ref)*(S.Jref*1e-6); %[Nm/(rad/s)]

end