close all;clear all;
patchsize =8;
load('pic3.mat');Target=imread('3.jpg');Origin=imread('3I.png');
Depth_RT=[[est_R est_T'] * reshape(unproj_new,90000,4)']';
temp= est_A* Depth_RT'; 
for i=1:90000
    temp(1,i)=temp(1,i)/temp(3,i); 
    temp(2,i)=temp(2,i)/temp(3,i); 
end
Depth_RT=reshape(Depth_RT,300,300,3);
Depth_Raw= Depth_RT(:,:,3);


for i= 0:7 

    
    %load(['depthWarped',num2str(i),'.mat']);

    TargetReduce=Target(patchsize*i/2+1:end-patchsize*i/2,patchsize*i/2+1:end-patchsize*i/2,:);
 
    OriginReduce=Origin(patchsize*i/2+1:end-patchsize*i/2,patchsize*i/2+1:end-patchsize*i/2,:);
 
    DepthRef=Depth_Raw(patchsize*i/2+1:end-patchsize*i/2,patchsize*i/2+1:end-patchsize*i/2,:);
    
    Depth_RT1 = Depth_RT(patchsize*(i+1)/2+1:end-patchsize*(i+1)/2,patchsize*(i+1)/2+1:end-patchsize*(i+1)/2,:);
    
    if i==0 
    iat_mex('cpp_I');
    DepthWarpedT1=DepthRef;
    else
    % Originreduce=imread(['ImageWarped',num2str(i),'.jpg']);
   
    load(['DepthWarped',num2str(i),'.mat']);
    DepthWarpedT1=DepthWarped;  
    
    Depth_RT=zeros(3,size(DepthWarped,1)*size(DepthWarped,2));    
    [xx,yy]=meshgrid(1:size(DepthWarped,1),1:size(DepthWarped,2));
    Depth_RT(1,:)=reshape(xx,1,[]);
    Depth_RT(2,:)=reshape(yy,1,[]);
    Depth_RT(3,:)=reshape(DepthWarped,1,[]); 
    for index=1:size(Depth_RT,2) 
        Depth_RT(1,index)= Depth_RT(1,index)*Depth_RT(3,index);
        Depth_RT(2,index)= Depth_RT(2,index)*Depth_RT(3,index);
    end
    Depth_RT=(inv(est_A)*Depth_RT)';
    Depth_RT=reshape(Depth_RT,size(Depth_RT,1)^0.5,size(Depth_RT,1)^0.5,3);
    iat_mex('cpp_ID');
    end  

    siftflowloop(i,TargetReduce,OriginReduce,DepthRef,DepthWarpedT1,Depth_RT1,est_A');
    
end 









    