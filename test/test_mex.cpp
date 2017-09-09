#include "mex.h"
#include <iostream>
using namespace std;

void gpu_test(float *data, int N);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
  float h_data[16];
  gpu_test(h_data, 16);  
  for (int i = 0; i < 16; i++){
    mexPrintf("%d, %f\n", i, h_data[i]);
  }
}
