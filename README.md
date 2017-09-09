This repository provides a matlab script to help you compile cuda source files.

# Requirments

Your kernel functions and functions used to invoke kernel functions must placed into `cu` files.
You `mexFunction` must defined in a `cpp` file.


# Usage

```matlab
 compilecuda('file1.cpp file2.cu file3.cu')
```

# Example

We provide an example in the path of `test`

```matlab
 cd test  
 addpath ..  
 compilecuda('test_mex.cpp test_gpu.cu')
```

**IF you think this script is useful for you, please leave me a star. Thanks~~**
