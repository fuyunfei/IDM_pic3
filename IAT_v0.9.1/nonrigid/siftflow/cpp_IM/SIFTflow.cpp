#include "mex.h"
#include "project.h"
#include "Image.h"
#include "BPFlow.h"

double* outputMatrix2(mxArray*& plhs,int n1,int n2)
{
	int dims[2];
	dims[0]=n1;
	dims[1]=n2;
	plhs=mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
	return (double *)mxGetData(plhs);
}

double* outputMatrix3(mxArray*& plhs,int n1,int n2,int n3)
{
	int dims[3];
	dims[0]=n1;
	dims[1]=n2;
	dims[2]=n3;
	plhs=mxCreateNumericArray(3,dims,mxDOUBLE_CLASS,mxREAL);
	return (double *)mxGetData(plhs);
}

double* outputMatrix4(mxArray*& plhs,int n1,int n2,int n3,int n4)
{
	int dims[4];
	dims[0]=n1;
	dims[1]=n2;
	dims[2]=n3;
	dims[3]=n4;
	plhs=mxCreateNumericArray(4,dims,mxDOUBLE_CLASS,mxREAL);
	return (double *)mxGetData(plhs);
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	FImage Im1,Im2,D_Im1,D_Im2,D_RT; 
	Im1.LoadMatlabImage(prhs[0]);
	Im2.LoadMatlabImage(prhs[1]);
	D_Im1.LoadMatlabImage(prhs[7]);
	D_Im2.LoadMatlabImage(prhs[8]);
	D_RT.LoadMatlabImage(prhs[9]);  // 添加 D-RT ;
	// define default parameters
	double alpha=0.01;
	double d=1;
	double gamma=0.001;
	int nIterations=40;
	int nHierarchy=2;
	int wsize=5;

	// load the parameters for matching
	//=========================================================================================
    if(nrhs>=3)
    {
        int nDims=mxGetNumberOfDimensions(prhs[2]);// 获得右侧2号参数(para)维度
		if(nDims>2)
			mexErrMsgTxt("The third parameter must be a vector!");
		const int* dims=mxGetDimensions(prhs[2]);
		if(dims[0]!=1 && dims[1]!=1)
			mexErrMsgTxt("The third parameter must be a vector!");
		int nPara=dims[0]+dims[1]-1;  //获取para参数个数
        double* para=(double *)mxGetData(prhs[2]);

        if(nPara>=1)
            alpha=para[0];
        if(nPara>=2)
            d=para[1];
        if(nPara>=3)
			gamma=para[2];
		if(nPara>=4)
            nIterations=para[3];
		if(nPara>=5)
			nHierarchy=para[4];
        if(nPara>=6)
            wsize=para[5];//wsize the size of the matching window at lower levels (default: 3)
    }
		 double* est_A=(double *)mxGetData(prhs[10]); //  传递 est_A 矩阵 
	//printf("Alpha: %f   d: %f  gamma: %f  nIterations: %d   nHierarchy: %d   wsize: %d\n",alpha,d,gamma,nIterations,nHierarchy,wsize);
	// load offset information
	//=============================================================================================
	IntImage OffsetX,OffsetY;

	if(nrhs>=5)
	{
		OffsetX.LoadMatlabImage(prhs[3],false); // there is no force of conversion
		OffsetY.LoadMatlabImage(prhs[4],false);
	}
	
	IntImage WinSizeX,WinSizeY;
	if(nrhs>=7)
	{
		WinSizeX.LoadMatlabImage(prhs[5],false); // there is no force of conversion
		WinSizeY.LoadMatlabImage(prhs[6],false);
	}

	DImage Im_s,Im_d;
	//DImage Depth_s,Depth_d; 
	//if(nrhs==9)
	//{
	//	Depth_s.LoadMatlabImage(prhs[7],false); // no force of converstion
	//	Depth_d.LoadMatlabImage(prhs[8],false);
	//}
	// output parameters
	double* pEnergyList=NULL;
	if(nlhs>1)
		pEnergyList=outputMatrix2(plhs[1],1,nIterations);

	// the main function goes here
	BPFlow bpflow;
//	bpflow.LoadImages(Im1.width(),Im1.height(),Im1.nchannels(),Im1.data(),Im2.width(),Im2.height(),Im2.data());
	bpflow.LoadImages(Im1.width(),Im1.height(),Im1.nchannels(),Im1.data(),Im2.data(),D_Im1.data(),D_Im2.data(),D_RT.data());

	//if(nrhs>9)
	//	bpflow.setPara(Im_s,Im_d);
	//else
		bpflow.setPara(alpha,d);
 
	bpflow.setHomogeneousMRF(wsize); // first assume homogeneous setup

	if(nrhs>=4)
		bpflow.LoadOffset(OffsetX.data(),OffsetY.data());

	if(nrhs>=6)
		bpflow.LoadWinSize(WinSizeX.data(),WinSizeY.data());


	bpflow.ComputeDataTerm(bpflow.pDataTerm,bpflow.ptrDataTerm,bpflow.nTotalMatches,1);
	//bpflow.ComputeDataTerm(bpflow.pDepthTerm,bpflow.ptrDepthTerm,bpflow.D_nTotalMatches,2);
    bpflow.ComputeDataTerm(bpflow.pQmsgTerm,bpflow.ptrQmsgTerm,bpflow.M_nTotalMatches,3,est_A);
	

	bpflow.ComputeRangeTerm(gamma);
	
	bpflow.MessagePassing(nIterations,nHierarchy,pEnergyList);
	bpflow.ComputeVelocity();

	bpflow.flow().OutputToMatlab(plhs[0]);

}