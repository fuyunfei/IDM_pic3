clear all; close all ;
%load('../test image/4D.mat');
load('DepthWarped8.mat');
Zvalue=DepthWarped; 
minD=min(Zvalue(:));
maxD=max(Zvalue(:));
for i=1:size(Zvalue,1)
for j=1:size(Zvalue,2)
if  Zvalue(i,j)==minD
    Zvalue(i,j)=maxD;
end
end
end
%Zvalue= -Zvalue+ones(size(Zvalue))*max(Zvalue(:));
[xx,yy]=meshgrid(1:size(Zvalue,1),1:size(Zvalue,2));

saveobjmesh('cpp_IM8.obj',xx,yy,Zvalue  )
disp('done!')