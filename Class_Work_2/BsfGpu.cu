
// This algorithm is a rough work with hardcoded values . Please be aware!!!!


#include <stdio.h>
#include <cuda_runtime.h>
#include <stdlib.h>
#include <limits.h>

struct CSRGraph
{
   	int numVertices;
   	int *dst;
   	int *srcPtrs;
};

__global__ void Bfs(CSRGraph csrGraph, int* level, int* newVertexVisited, int currLevel);

int main()
{
   //----------------------------Memory declaraction for Host and Device---------------------------
   CSRGraph d_csr;
   
   int *d_srcPtrs;
   int *d_dst;
   cudaMalloc( (void**)&d_srcPtrs, 10*sizeof(int) ); 
   cudaMalloc( (void**)&d_dst, 15*sizeof(int) );
   
   //Array initialisation
   int copy_h_dst[] = {1,2,3,4,5,6,7,4,8,5,8,6,8,0,6};
   int copy_h_srcPtrs[] = {0,2,4,7,9,11,12,13,15,15};
   

   //For CSR from Host to Device
   cudaMemcpy(d_srcPtrs, copy_h_srcPtrs, 10*sizeof(int), cudaMemcpyHostToDevice);
   cudaMemcpy(d_dst, copy_h_dst, 15*sizeof(int), cudaMemcpyHostToDevice);

   d_csr.numVertices = 9;
   d_csr.dst = d_dst;
   d_csr.srcPtrs = d_srcPtrs;

   //-------------------------------------------------------------------------------------------------
   
   //---------------------------------Level , New vertex visited and CurrLevel------------------------

   int copy_level[] = {0, INT_MAX, INT_MAX, INT_MAX, INT_MAX, INT_MAX, INT_MAX, INT_MAX, INT_MAX};
   int* d_level;
   
   cudaMalloc( (void**)&d_level, 9*sizeof(int) ); 	
   cudaMemcpy(d_level, copy_level, 9*sizeof(int), cudaMemcpyHostToDevice);

   int* h_newVertexVisited;
   int* d_newVertexVisited;
   
   cudaMalloc( (void**)&d_newVertexVisited, sizeof(int) ); 
   h_newVertexVisited = (int*)malloc(sizeof(int));

   int h_currLevel = 1;

   //-------------------------------------------------------------------------------------------------

   while (1)
   {
	*h_newVertexVisited = 0;
        
	cudaMemcpy(d_newVertexVisited, h_newVertexVisited, sizeof(int), cudaMemcpyHostToDevice);
   	Bfs<<<1,32>>>(d_csr, d_level, d_newVertexVisited, h_currLevel);
        cudaError_t err = cudaDeviceSynchronize();
        if (err != cudaSuccess)
	{
		printf("Kernel error: %s\n", cudaGetErrorString(err));
	}
        cudaMemcpy(h_newVertexVisited, d_newVertexVisited, sizeof(int), cudaMemcpyDeviceToHost);
	
        h_currLevel++;
	if (*h_newVertexVisited == 0)
		break;
   }

   int* h_level = (int*)malloc(9*sizeof(int));
   cudaMemcpy(h_level, d_level, 9*sizeof(int), cudaMemcpyDeviceToHost);
   printf("[");
   for (int i = 0; i < 9; i++)
   {
	   printf("%d, ", h_level[i]);
   }
   printf("]\n");

}

//---------------------------------BFS Algorithm---------------------------------------------------
__global__ void Bfs(CSRGraph csrGraph, int* level, int* newVertexVisited, int currLevel)
{
	int vertex = blockIdx.x * blockDim.x + threadIdx.x;
	if (vertex < csrGraph.numVertices)
	{
		if (level[vertex] == currLevel-1)
		{
			for (int edge = csrGraph.srcPtrs[vertex]; edge < csrGraph.srcPtrs[vertex + 1]; edge++)
			{
				int neigbour = csrGraph.dst[edge];
		        	if ( level[neigbour] == INT_MAX )
				{
			   		level[neigbour] = currLevel;
		   	   		*newVertexVisited = 1;
				}
	     		}

		}
	}
}
//------------------------------------------------------------------------------------------------
