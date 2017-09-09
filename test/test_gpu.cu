
void __global__ kernel_test(float *data, int N){
  int tx = threadIdx.x + blockIdx.x*blockDim.x;
  if (tx < N)
    data[tx] = tx;  
}

void gpu_test(float *data, int N){
  float *d_data = NULL;	
	cudaMalloc(&d_data, N*sizeof(float));	
	kernel_test<<<1,N>>>(d_data, N);
	cudaMemcpy(data, d_data, N*sizeof(float), cudaMemcpyDeviceToHost);
  if (d_data)
    cudaFree(d_data);
}