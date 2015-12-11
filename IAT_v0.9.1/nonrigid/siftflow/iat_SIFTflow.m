function [vx,vy,energylist]=iat_SIFTflow(im1,im2,par,DepthRef,DepthT1,Depth_RT,est_A)

% default parameters
par0.alpha = 0.01;
par0.gamma = 0.001;
par0.nlevels = 4;
par0.wsize = 3;
par0.topwsize = 10;
par0.nIterations = 40;
par0.nTopIterations = 100;

if exist('par','var')
    if ~isstruct(par)
        error('iat_SIFTflow: parameter structure is not a matlab struct');
    end
    % merge default with given values
    params = iat_merge_param(par0, par);
else
    params = par0;
end

alpha = params.alpha;
gamma = params.gamma;
nlevels = params.nlevels;
wsize = params.wsize;
topwsize = params.topwsize;
nIterations = params.nIterations;
nTopIterations = params.nTopIterations;


if isfield(params,'d')
    d=params.d;
else
    d=alpha*20;
end
            
if ~isfloat(im1)
    im1=im2double(im1);
end

if ~isfloat(im2)
    im2=im2double(im2);
end

% build the Gaussian pyramid for the SIFT images
pyrd(1).im1=im1;
pyrd(1).im2=im2;
pyrd(1).DepthRef=DepthRef;
pyrd(1).DepthT1=DepthT1;
pyrd(1).Depth_RT=Depth_RT;




for i=2:nlevels
    pyrd(i).im1=imresize(imfilter(pyrd(i-1).im1,fspecial('gaussian',5,0.67),'same','replicate'),0.5,'bicubic');
    pyrd(i).im2=imresize(imfilter(pyrd(i-1).im2,fspecial('gaussian',5,0.67),'same','replicate'),0.5,'bicubic');
    
    pyrd(i).DepthRef=imresize(imfilter(pyrd(i-1).DepthRef,fspecial('gaussian',5,0.67),'same','replicate'),0.5,'bicubic');
    pyrd(i).DepthT1=imresize(imfilter(pyrd(i-1).DepthT1,fspecial('gaussian',5,0.67),'same','replicate'),0.5,'bicubic');  
    pyrd(i).Depth_RT=imresize(imfilter(pyrd(i-1).Depth_RT,fspecial('gaussian',5,0.67),'same','replicate'),0.5,'bicubic');  
end

for i=1:nlevels
    [height,width,nchannels]=size(pyrd(i).im1);
    [height2,width2,nchannels]=size(pyrd(i).im2);
    [xx,yy]=meshgrid(1:width,1:height);
    pyrd(i).xx=round((xx-1)*(width2-1)/(width-1)+1-xx);
    pyrd(i).yy=round((yy-1)*(height2-1)/(height-1)+1-yy);
end

%nIterationArray=round(linspace(nIterations,nIterations*0.6,nlevels));
nIterationArray = nIterations*ones(1,nlevels);
if nlevels==1
    fprintf('SIFTflow is running in single-level mode\n');
else
    fprintf('SIFTflow is running in multi-level mode\n');
end
for i=nlevels:-1:1
    if nlevels>1
        fprintf('Level: %d....',i);
    end
    [height,width,nchannels]=size(pyrd(i).im1);
    if i==nlevels % top level
        vx=pyrd(i).xx;
        vy=pyrd(i).yy;
        
        winSizeX=ones(height,width)*topwsize;
        winSizeY=ones(height,width)*topwsize;
    else % lower levels
        vx=round(pyrd(i).xx+imresize(vx-pyrd(i+1).xx,[height,width],'bicubic')*2);
        vy=round(pyrd(i).yy+imresize(vy-pyrd(i+1).yy,[height,width],'bicubic')*2);
        winSizeX=ones(height,width)*wsize;
        winSizeY=ones(height,width)*wsize;
    end
    
    Im1=pyrd(i).im1;
    Im2=pyrd(i).im2;
    DepthRef=pyrd(i).DepthRef;
    DepthT1=pyrd(i).DepthT1;
    Depth_RT=pyrd(i).Depth_RT./2^(i-1);
 %=========================================================================================    
%     Ratio_Current =  int32(size(pyrd(1).im1,1)/size(Im1,1));    
%        figure;        
%        Pos_modi=int32(Q_mark (:,:))./Ratio_Current; 
%        Diff_modi=int32(UV_mark(:,:))./Ratio_Current;
%     for index_out=1:1:size(Pos_modi,1)
% 
%         vx(Pos_modi(index_out,2),Pos_modi(index_out,1))=-Diff_modi(index_out,1);
%         vy(Pos_modi(index_out,2),Pos_modi(index_out,1))=-Diff_modi(index_out,2);
%         quiver(pos_modi(index_out,1),pos_modi(index_out,2),Diff_modi(index_out,1),Diff_modi(index_out,2),'color',[1 0 0]); hold on; 
%     end
%=========================================================================================    

    
    if i==nlevels
        [flow,foo]=iat_SIFTflow_mex(Im1,Im2,[alpha,d,gamma*2^(i-1),nTopIterations,2,topwsize],vx,vy,winSizeX,winSizeY,DepthRef,DepthT1,Depth_RT,est_A);      %
    else
        [flow,foo]=iat_SIFTflow_mex(Im1,Im2,[alpha,d,gamma*2^(i-1),nIterationArray(i),nlevels-i,wsize],vx,vy,winSizeX,winSizeY,DepthRef,DepthT1,Depth_RT,est_A);    %  
    end
    
    energylist(i).data=foo;
    vx=flow(:,:,1);
    vy=flow(:,:,2);
    
    
     if nlevels>1
        fprintf('done\n');
     end
end

