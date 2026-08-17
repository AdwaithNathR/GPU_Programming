

// This CUDA program put barrier for all threads in the grid 


#include <cstdio>
#include <cuda.h>


__device__ int valForBlock0 = 0;
__device__ int valForBlock1 = 0;
__device__ int valForBlock2 = 0;
__device__ int valForBlock3 = 0;

__global__ void BarrierFunction()
{

	printf("Thread %d in Block %d Task1\n", threadIdx.x ,blockIdx.x);
        if (blockIdx.x == 0)
	{
		atomicAdd(&valForBlock0, 1);
	}
	if (blockIdx.x == 1)
	{
		atomicAdd(&valForBlock1, 1);
	}
	if (blockIdx.x == 2)
	{
		atomicAdd(&valForBlock2, 1);
	}
	if (blockIdx.x == 3)
	{
		atomicAdd(&valForBlock3, 1);
	}
	while ( atomicAdd(&valForBlock0,0) < 128 || atomicAdd(&valForBlock1,0) < 128 || atomicAdd(&valForBlock2,0) < 128 || atomicAdd(&valForBlock3,0) <128 ); 
	
	printf("Thread %d in Block %d Task2\n", threadIdx.x, blockIdx.x );

}

int main()
{

	BarrierFunction<<< 4, 128>>>();
	
	cudaError_t launchErr = cudaGetLastError();
	if ( launchErr != cudaSuccess)
	{
		printf("Kernel launch failed: %s\n", cudaGetErrorString(launchErr));
		return 1;
	}

	cudaError_t syncErr = cudaDeviceSynchronize();
	if(syncErr != cudaSuccess)
	{
		printf("Kernal execution failed: %s\n", cudaGetErrorString(syncErr)); 
		return 1;
	}
	return 0;
}
