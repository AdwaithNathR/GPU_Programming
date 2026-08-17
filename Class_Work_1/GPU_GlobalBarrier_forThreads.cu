

// This CUDA program put barrier for all threads in the grid 


#include <cstdio>
#include <cuda.h>


__device__ int counter = 0;

__global__ void BarrierFunction()
{

	printf("Thread %d in Block %d Task1\n", threadIdx.x ,blockIdx.x);
	atomicAdd(&counter, 1);

	while ( atomicAdd(&counter, 0) < 512 ); 
	
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
