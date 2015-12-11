% load the imahes
close all;clear all;
load('depth1reduce16.mat'); 
load('depth3reduce16.mat');
Targetreduce16=imread('Targetreduce16.jpg');
Originreduce16=imread('Originreduce16.jpg');

% Compute SIFT images
patchsize=8; %half of the window size for computing SIFT
gridspacing=1; %sampling step (use 1 for registration)


% compute dense SIFT images
SiftTarget=iat_rgbd_sift(im2double(Targetreduce16),depth3reduce16,patchsize,gridspacing);
SiftOrigin=iat_rgbd_sift(im2double(Originreduce16),depth1reduce16,patchsize,gridspacing);

% visualize SIFT image
%figure;imshow(iat_sift2rgb(SiftTarget));title('SIFT image 1');
%figure;imshow(iat_sift2rgb(SiftOrigin));title('SIFT image 2');
 
iat_sift2rgb(SiftTarget);
iat_sift2rgb(SiftOrigin);

% SIFT-flow parameters
SIFTflowpara.alpha=2;
SIFTflowpara.d=40;
SIFTflowpara.gamma=0.005;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=5;
SIFTflowpara.topwsize=20;
SIFTflowpara.nIterations=60;

% Run the algorithm
tic;[vx,vy,energylist]=iat_SIFTflow(SiftTarget,SiftOrigin,SIFTflowpara);toc


% VISUALIZE RESULTS

% Keep the pixels that are present in SIFT images 
if gridspacing==1
    Targetreduce24=Targetreduce16(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    imwrite(Targetreduce24,'Targetreduce24.jpg')
    Originreduce24=Originreduce16(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    imwrite(Originreduce24,'Originreduce24.jpg')
    depth1reduce24=depth1reduce16(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    save('depth1reduce24','depth1reduce24')
else
  im1filt=imfilter(Target,fspecial('gaussian',7,1.),'same','replicate');
  Targetreduce24 = im1filt(patchsize/2:gridspacing:end-patchsize/2,patchsize/2:gridspacing:end-patchsize/2,:);
  im2filt=imfilter(Originreduce16,fspecial('gaussian',7,1.),'same','replicate');
  Originreduce16 = im2filt(patchsize/2:gridspacing:end-patchsize/2,patchsize/2:gridspacing:end-patchsize/2,:);
end

% warp the image (inverse warping of Im2)
[warpimage4, support] = iat_pixel_warping(Originreduce24,vx,vy);
[depth4reduce24, support] = iat_pixel_warping(depth1reduce24,vx,vy);
figure;imshow(Targetreduce24);title('Image 1');
figure;imshow(uint8(warpimage4));title('WarpImage4');
figure;imshow(depth4reduce24);title('depth4reduce24');

% visualize alignment error
[~, grayerror] = iat_error2gray(Targetreduce24,warpImage4,support);
%figure;imshow(grayerror);title('Registration error');

% display flow
%figure;imshow(iat_flow2rgb(vx,vy));title('SIFT flow field');

