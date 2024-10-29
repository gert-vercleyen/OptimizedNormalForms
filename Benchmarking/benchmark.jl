using Oscar
using DelimitedFiles
using TimerOutputs

const to = TimerOutput()

linuxFileNames = readdlm("Benchmarking/FileNamesLinux",'\n',String)

numMatrices = 30

for i in 1:numMatrices
  mat = matrix( ZZ, readdlm( "JULIA/" * linuxFileNames[i] ) );
  println(i);
  @timeit to linuxFileNames[i]*"_" snf_with_transform(mat);
end

show(to)