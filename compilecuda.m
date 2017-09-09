% all rights reserved
% author: Zhihua Ban
% contact: sawpara@126.com

function compilecuda( src_files )

  nvcc_compiler = 'nvcc -w -arch sm_30 -c -O2 ';
  mexc_compiler = 'mex -O -c -largeArrayDims ';
  mexc_linker = 'mex -O -largeArrayDims ';
  cuda_libs = ' -lcudart ';
  
  file_list = strsplit(strtrim(src_files));
  
  % cuda file list
  cuda_file_list = {}; cuda_id = 1; cuda_file_outp = {};
  % c/c++ file list
  ccpp_file_list = {}; ccpp_id = 1; ccpp_file_outp = {};
  
  for i = 1:numel(file_list)
    cur_file = strtrim(file_list{i});
    if numel(cur_file) == 0
      continue;
    end
    [~, cur_file_stem, cur_ext] = fileparts(cur_file);
    if strcmp(cur_ext, '.cu')
      cuda_file_list(cuda_id) = {cur_file};
      if ispc
        cuda_file_outp(cuda_id) = {[cur_file_stem, '.obj']};
      else
        cuda_file_outp(cuda_id) = {[cur_file_stem, '.o']};
      end
      cuda_id = cuda_id + 1;      
    else
      ccpp_file_list(ccpp_id) = {cur_file};
       if ispc
        ccpp_file_outp(cuda_id) = {[cur_file_stem, '.obj']};
      else
        ccpp_file_outp(cuda_id) = {[cur_file_stem, '.o']};
      end
      ccpp_id = ccpp_id + 1;      
    end
  end
  
  % host compiler
  compilerForMex = mex.getCompilerConfigurations('C++','selected');
  compiler_arch = strtrim(compilerForMex(1).Details.CommandLineShellArg);
  
  if ispc && isempty(strfind(compiler_arch, '64'))
    error('we only suport 64-bit');
  end
  
  
  if ispc
    compiler_parent = fullfile(compilerForMex.Location, 'VC', 'bin', compiler_arch);
    host_compiler_opt = sprintf(' -ccbin "%s"', compiler_parent);
    host_compiler_flg = regexprep(compilerForMex.Details.CompilerFlags, '/[Ww][0-9]\s*', '');
  else
    host_compiler_opt = ' ';
    host_compiler_flg = regexprep(compilerForMex.Details.CompilerFlags, '-std\S*\s*', '');
  end  
  host_compiler_opt = sprintf('%s -Xcompiler "%s"', host_compiler_opt, host_compiler_flg);
  nvcc_command_line = [nvcc_compiler, ' ', host_compiler_opt];
  
  
  % find nvcc root
  if ispc 
    nvcc_root = getenv('CUDA_PATH');
    nvcc_root = regexprep(nvcc_root, '^"', '');
    nvcc_root = regexprep(nvcc_root, '"$', '');
  else
    [~, nvcc_root] = system('which nvcc');
    nvcc_root = regexprep(nvcc_root, '/nvcc\S*\s*$', '/../');
  end
  
  % cuda library path
  if ispc 
    nvcc_lib_root = ['"', fullfile(nvcc_root, 'lib/x64'), '"'];
  else
    nvcc_lib_root = fullfile(nvcc_root, 'lib64');
  end
  
  
  % compile cuda source
  for i = 1:numel(cuda_file_list)        
    nvcc_code = [nvcc_command_line, ' ', cuda_file_list{i}, ' -o ', cuda_file_outp{i}];
    fprintf('%s\n', nvcc_code);
    status = system(nvcc_code);
    if status < 0
      error('Error invoking nvcc');
    end
  end
  
  % compile c/c++ source
  for i = 1:numel(ccpp_file_list)
    ccpp_code = [mexc_compiler, ccpp_file_list{i}];
    fprintf('%s\n', ccpp_code);
    eval(ccpp_code);
  end
  
  
  % link
  link_files = ' ';
  for i = 1:numel(ccpp_file_outp)
    link_files = [link_files, ccpp_file_outp{i}, ' '];
  end 
  for i = 1:numel(cuda_file_outp)
    link_files = [link_files, cuda_file_outp{i}, ' '];
  end
  

  
  link_code = [mexc_linker, link_files];
  
  if numel(cuda_file_outp)>0
    link_libs = [' ', cuda_libs, ' -L', nvcc_lib_root];
  else
    link_libs = '';
  end
  
  link_code = [link_code, ' ', link_libs];
  fprintf('%s\n', link_code);
  
  eval(link_code);  
  
  % erase object files
  link_file_cells = strsplit(strtrim(link_files));
  for i = 1:numel(link_file_cells)
    delete(link_file_cells{i})
  end

end

