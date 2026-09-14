// This SSSP Graph Algo for GPU is a naive implementation



#include <stdlib.h>
#include <cuda_runtime.h>
#include <stdio.h>

struct CsrGraph
{
	int vertices;
	int* srcPtrs;
	int* dst;
	int* wt;
};

__global__ void SSSP (CsrGraph csrGraph, int *changed, int *distance);

int main()
{
	CsrGraph d_csr;
	
	int srcPtrs[] = {0,2,4,7,8,10,11,12,14,14};
	int dst[] = {1,2,3,4,5,6,7,8,5,8,6,8,0,6};
	int wt[] = {3,4,7,2,4,10,8,5,3,6,14,3,5,12};
	
	//-------------------------------------------Memory Allocation in Device-------------------------------------------
	
	int *d_srcPtrs, *d_dst, *d_wt;
	cudaMalloc ( (void**)&d_srcPtrs, 10*sizeof(int) );
	cudaMalloc ( (void**)&d_dst, 14*sizeof(int) );
	cudaMalloc ( (void**)&d_wt, 14*sizeof(int) );

	cudaMemcpy (d_srcPtrs, srcPtrs, 10*sizeof(int), cudaMemcpyHostToDevice);	
	cudaMemcpy (d_dst, dst, 14*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy (d_wt, wt, 14*sizeof(int), cudaMemcpyHostToDevice);

	d_csr.vertices = 9;
	d_csr.srcPtrs = d_srcPtrs;
	d_csr.dst = d_dst;
	d_csr.wt = d_wt;

	int *h_distance, *d_distance, *d_changed, *h_changed;

	h_changed = (int*)malloc(sizeof(int));	
	h_distance = (int*)malloc(9*sizeof(int));
	cudaMalloc ( (void**)&d_distance, 9*sizeof(int) );
	cudaMalloc ( (void**)&d_changed, sizeof(int) );
	int distance[] = {0, INT_MAX, INT_MAX, INT_MAX, INT_MAX, INT_MAX, INT_MAX, INT_MAX, INT_MAX};

	h_distance = distance;
	cudaMemcpy (d_distance, distance, 9*sizeof(int), cudaMemcpyHostToDevice);
  	
	//---------------------------------------------Call Device Kernal--------------------------------------------------
	
	while (1)
	{
		*h_changed = 0;
		cudaMemcpy (d_changed, h_changed, sizeof(int), cudaMemcpyHostToDevice);
				
		SSSP<<<1,32>>> (d_csr, d_changed, d_distance);
		
		cudaError_t err = cudaDeviceSynchronize();
		if (err != cudaSuccess)
		{
			printf ("error : %s ",cudaGetErrorString(err));
		}
		cudaMemcpy (h_changed, d_changed, sizeof(int), cudaMemcpyDeviceToHost);
		if (*h_changed == 0) 
			break;


	}

	//--------------------------------------------Print Distance from Source------------------------------------------
	
	cudaMemcpy (h_distance, d_distance, 9*sizeof(int), cudaMemcpyDeviceToHost);

	printf ("distance = [ ");
	for (int i = 0; i < 9; i++)
	{
		printf ("%d, ", h_distance[i]);
	}
	printf ("]\n");

	//----------------------------------------------------------------------------------------------------------------
}

//-----------------------------------------------------SSSP Kernal--------------------------------------------------------

__global__ void SSSP(CsrGraph csrGraph, int *changed, int *distance)
{
	int vertex = blockIdx.x * blockDim.x + threadIdx.x;

	if ( vertex < csrGraph.vertices )
	{
		if (distance[vertex] != INT_MAX)
		{
			for (int edge = csrGraph.srcPtrs[vertex]; edge < csrGraph.srcPtrs[vertex+1]; edge++)
			{
				int temp = distance[csrGraph.dst[edge]];
				atomicMin (&distance[csrGraph.dst[edge]], (distance[vertex] + csrGraph.wt[edge]));
				if ( distance[csrGraph.dst[edge]] < temp )
					*changed = 1;
			}
		}
	}
}

//------------------------------------------------------------------------------------------------------------------------

