% load the imahes
close all;clear all;
load('depth1reduce8.mat'); 
load('depth2reduce8.mat');
Targetreduce8=imread('Targetreduce8.jpg');
Originreduce8=imread('Originreduce8.jpg');

% Compute SIFT images
patchsize=8; %half of the window size for computing SIFT
gridspacing=1; %sampling step (use 1 for registration)


% compute dense SIFT images
SiftTarget=iat_rgbd_sift(im2double(Targetreduce8),depth2reduce8,patchsize,gridspacing);
SiftOrigin=iat_rgbd_sift(im2double(Originreduce8),depth1reduce8,patchsize,gridspacing);

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
    Targetreduce16=Targetreduce8(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    imwrite(Targetreduce16,'Targetreduce16.jpg')
    Originreduce16=Originreduce8(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    imwrite(Originreduce16,'Originreduce16.jpg')
    depth1reduce16=depth1reduce8(patchsize/2+1:end-patchsize/2,patchsize/2+1:end-patchsize/2,:);
    save('depth1reduce16','depth1reduce16')
else
  im1filt=imfilter(Target,fspecial('gaussian',7,1.),'same','replicate');
  Targetreduce16 = im1filt(patchsize/2:gridspacing:end-patchsize/2,patchsize/2:gridspacing:end-patchsize/2,:);
  im2filt=imfilter(Originreduce8,fspecial('gaussian',7,1.),'same','replicate');
  Originreduce8 = im2filt(patchsize/2:gridspacing:end-patchsize/2,patchsize/2:gridspacing:end-patchsize/2,:);
end

% warp the image (inverse warping of Im2)
[warpImage2, support] = iat_pixel_warping(Originreduce16,vx,vy); 
imwrite(uint(warpImage2),'warpImage2.jpg'); 
[depth3reduce16, support] = iat_pixel_warping(depth1reduce16,vx,vy);
save('depth3reduce16','depth3reduce16');
figure;imshow(Targetreduce16);title('Image 1');
figure;imshow(uint8(warpImage2));title('WarpImage2');

figure;imshow(depth3reduce16);title('depth3reduce16');
figure;imshow(depth2reduce8);title('depth2reduce8');
% visualize alignment error
[~, grayerror] = iat_error2gray(Targetreduce16,warpImage2,support);
%figure;imshow(grayerror);title('Registration error');

% display flow
%figure;imshow(iat_flow2rgb(vx,vy));title('SIFT flow field');

