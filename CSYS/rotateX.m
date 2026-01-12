function [rotx] = rotateX(t)
rotx =  [1    0       0; 
         0   cos(t) sin(t); 
         0   -sin(t)  cos(t)];
end