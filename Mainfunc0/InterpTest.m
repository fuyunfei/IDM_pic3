 close all; clear all;
 [X,Y] = meshgrid(-3:3);
V = peaks(X,Y);
figure
surf(X,Y,V)
title('Original Sampling');
[Xq,Yq] = meshgrid(-3:3);
Xq(2,2)=Xq(2,2)+2;
Yq(2,2)=Yq(2,2)+4;
Vq = interp2(X,Y,V,Xq,Yq,'bicubic');
figure
surf(X,Y,Vq);
title('Linear Interpolation Using Finer Grid');
