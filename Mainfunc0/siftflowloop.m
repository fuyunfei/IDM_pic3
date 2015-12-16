function siftflowloop(i,Target,Origin,DepthRef,DepthWarpedT1,Depth_RT,est_A)

patchsize=8; %half of the window size for computing SIFT
gridspacing=1; %sampling step (use 1 for registration)
withD=0;

% Compute SIFT image
if withD== 1 
% compute dense SIFT images
SiftTarget=iat_rgbd_sift(im2double(Target),DepthWarpedT1,patchsize,gridspacing);
SiftOrigin=iat_rgbd_sift(im2double(Origin),DepthRef,patchsize,gridspacing);
else 
SiftdepthRef=iat_dense_sift(im2double(DepthRef), patchsize,gridspacing);
SiftdepthWarpedT1=iat_dense_sift(im2double(DepthWarpedT1), patchsize,gridspacing);
SiftOrigin=iat_dense_sift(im2double(Origin), patchsize,gridspacing);
SiftTarget=iat_dense_sift(im2double(Target), patchsize,gridspacing);
end 

% figure;imshow(iat_sift2rgb(SiftdepthWarpedT1));title('SIFT image 1');
% figure;imshow(iat_sift2rgb(SiftdepthRef));title('SIFT image 2');


% SIFT-flow parameters
SIFTflowpara.alpha=2;
SIFTflowpara.d=40;
SIFTflowpara.gamma=0.005;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=5;
SIFTflowpara.topwsize=20;
SIFTflowpara.nIterations=60;


% Run the algorithm
[vx,vy,energylist]=iat_SIFTflow(SiftTarget,SiftOrigin,SIFTflowpara,SiftdepthRef,SiftdepthWarpedT1,Depth_RT,est_A);

% warp the image (inverse warping of Im2)
Originreduce=Origin(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
DepthRef=DepthRef(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);

[xx,yy]=meshgrid(1:size(DepthRef,1),1:size(DepthRef,2));
[nx ny nz]=surfnorm(xx,yy,DepthRef);

[warpImage, support] = iat_pixel_warping(Originreduce,vx,vy,nx,ny,nz,0);
imwrite(uint8(warpImage),['ImageWarped',num2str(i+1),'.jpg']); 

[DepthWarped, support] = iat_pixel_warping(DepthRef,vx,vy,nx,ny,nz,1);
DepthWarped(find(~DepthWarped))=DepthWarped(1,1);
save(['DepthWarped',num2str(i+1),'.mat'],'DepthWarped');

[pos_x,pos_y]= meshgrid(1:5:size(vx,1),1:5:size(vx,2)); 
u=vx(1:5:size(vx,1),1:5:size(vx,1));v=vy(1:5:size(vx,1),1:5:size(vx,1));
figure;
imshow(Origin);hold on;
quiver(pos_x,pos_y,u,v);



