
// Cuda Program to display GPU Properties

#include <iostream>
#include <cuda_runtime.h>

using namespace std;

int getCoresPerSM(int major, int minor);

int main()
{
	int deviceCount = 0;
	cudaError_t error = cudaGetDeviceCount(&deviceCount);
	
	if(error != cudaSuccess)
	{
		cerr << "CUDA Error\n";
		return 0;
	}


	cout <<	"No. of devices: " << deviceCount << endl;

	for(int i = 0 ; i < deviceCount ; i++)
	{
		cudaDeviceProp prop;
		cudaGetDeviceProperties(&prop, i);

		cout << "Device " << i << ": " << prop.name << endl;

		cout << " Compute Capability:        " << prop.major << "." << prop.minor << endl;
		cout << " Total Global Memory:       " << prop.totalGlobalMem/ (1024 * 1024) << " MB" << endl;
		cout << " Streaming Multiprocessors: " << prop.multiProcessorCount << endl;
	       	cout << " Cores per SM:              " << getCoresPerSM(prop.major, prop.minor) << endl;
		cout << " Max Threads per Block:     " << prop.maxThreadsPerBlock << endl;
		cout << " Shared Memory per Block:   " << prop.sharedMemPerBlock / 1024 << " KB" << endl;
		cout << " Warp Size:                 " << prop.warpSize << endl;
		cout << " \n";
	}

	return 0;
}

// To get cores per SM based on architecture 
int getCoresPerSM(int major, int minor)
{
	switch(major)
	{
		case 2: // Fermi
			return (minor == 1)? 48 : 32;
		
		case 3: // Kepler
			return 192;
		
		case 5: // Maxwell
			return 128;
		
		case 6: // Pascal
			return (minor == 0)? 64 : 128; // 128 Default for Pascal
		
		case 7: // Volta (7.0), Turing (7.5)
			return 64;
		
		case 8: // Ampere (8.0, 8.6, 8.7), Ada Lovelace (8.9)
			return (minor == 6 || minor == 9)? 128 : 64; // 64 Default for Ampere variants
		
		case 9: // Hopper (9.0), Blackwell (9.5)
			return 128;
		
		default: // Default for future architecture
			return 128;

	}
	
}
