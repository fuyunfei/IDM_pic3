clear all; close all;
normb = [-1 0 0];
a = [1 1 1];
Angle=atan2(norm(cross(a,normb)), dot(a,normb));
c=a-normb*norm(a)*cos(Angle);


% VdotB=cross(a,b);
% Angle = acosd (VdotB / norm(v1)*norm(v2)) ; 

 