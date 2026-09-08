// This is the implementation of Single Source Shortest Path Algorithm by Bellman and Ford -[CPU Version]-

// CSR format is used for Graph Representation

#include <cstdio>
#include <vector>
#include <math.h>
#include <climits>

using namespace std;

int main (int argc , char** argv) // Graph is given in txt as CMD argument
{
	//***************************************** File to Array **********************************************************

	if ( argc < 2) 
	{
		printf (" Error CMD file read\n");
		return 0;
	}

	FILE* f = fopen (argv[1],"r");

	int V , E;

	fscanf ( f, "%d %d", &V, &E);
	
	vector<int> src(E), dest(E), wt(E);

	for (int i = 0; i < E; i++)
	{
		fscanf (f, "%d %d %d", &src[i], &dest[i], &wt[i]);
	}

	fclose(f);

	//******************************************************************************************************************
	
	//*************************************** Array To CSR Rep *********************************************************
	
	int deg[V]={0,0,0,0,0};
	for (int i = 0; i < E; i++)
	{
		deg[src[i]]++;
	}	
	
	int row_offset[V+1] = {0,0,0,0,0,0};
	for (int i = 1; i <= V; i++)
	{
		row_offset[i] = row_offset[i-1] + deg[i-1];
	}
	
	int col_offset[E], weight[E], cursor[V];
	for (int i = 0; i < V; i++)
	{
		cursor[i] = row_offset[i];
	}

	for (int i = 0; i < E; i++)
	{
		col_offset[cursor[src[i]]] = dest[i];
		weight[cursor[src[i]]] = wt[i];
		cursor[src[i]]++;
	}
	printf ("deg       = [ %d, %d, %d, %d, %d ]\n\n", deg[0], deg[1], deg[2], deg[3], deg[4]);
	printf ( "row_offset  col_offset  weight\n");
	for (int i = 0; i < E; i++)
	{	
		printf ("%d               %d          %d\n", row_offset[i], col_offset[i], weight[i]);
	}
	//*****************************************************************************************************************
	
	//************************************* SSSP Algo *****************************************************************
	
	int dst[V] = {INT_MAX,INT_MAX,INT_MAX,INT_MAX,INT_MAX}; 
	int s = 0;					// Vertex 0 is selected as source vertex
	dst[s] = 0;

	if (deg[s] != 0)
	{		
		int temp = s;
		for (int i = 0; i < V-1; i++)
		{
			s = temp;
			for (int k = 0 ; k < E ; )
			{
	         		if (dst[s] == INT_MAX) 
				{
					k++;
					s++;
					s %= (E-1);
					continue;
				}
				int j = 0;
		        	while (j < deg[s])
				{
					dst[col_offset[row_offset[s]+j]] = min (dst[col_offset[row_offset[s]+j]], dst[s] + weight[row_offset[s]+j]);
					j++;
				}
				k += j;
				s++;
				s %= (E-1);
			}
		}
	}

	//*****************************************************************************************************************
	
	//************************************ Dst Array ******************************************************************
	
	printf ("\ndst = [");
	for (int i = 0; i < V; i++)
	{
		printf(" %d,", dst[i]);
	}
	printf("]\n");

	//*****************************************************************************************************************
	
	return 0;
}
