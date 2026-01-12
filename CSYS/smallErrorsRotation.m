function [matrix] = smallErrorsRotation(eoa1, eoa2, eoa3)

%Provides a Matrix resulted from 3 small Rotations X, Y, Z

% Step 1 - rotateZ(err3)*rotateY(err2)*rotateX(err1)

%  [ cos(eoa2)*cos(eoa3), cos(eoa1)*sin(eoa3) + cos(eoa3)*sin(eoa1)*sin(eoa2), sin(eoa1)*sin(eoa3) - cos(eoa1)*cos(eoa3)*sin(eoa2)]
% [-cos(eoa2)*sin(eoa3), cos(eoa1)*cos(eoa3) - sin(eoa1)*sin(eoa2)*sin(eoa3), cos(eoa3)*sin(eoa1) + cos(eoa1)*sin(eoa2)*sin(eoa3)]
% [           sin(eoa2),                                -cos(eoa2)*sin(eoa1),                                 cos(eoa1)*cos(eoa2)]
 

%  Step 2 - small angles approximation sin(eps) = eps, cos(eps) = 1
% [    1,   eoa3 + eoa1*eoa2, eoa1*eoa3 - eoa2]
% [-eoa3, 1 - eoa1*eoa2*eoa3, eoa1 + eoa2*eoa3]
% [ eoa2,              -eoa1,                1]

% Step 3 - order analysis: eps1*eps2 = eps2*eps3 = eps3*eps1 = 0
matrix = [   1    ,  eoa3,    -eoa2; ...
           -eoa3,     1,       eoa1;....
            eoa2,   -eoa1,      1   ];
end