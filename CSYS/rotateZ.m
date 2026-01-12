function [rotz] = rotateZ(t)

rotz = [cos(t)   sin(t)   0   ; 
       -sin(t)   cos(t)   0   ; 
         0        0       1]  ;
end