using Oscar
using DelimitedFiles
using TimerOutputs

to = TimerOutput()

linuxFileNames = readdlm("/home/gert/Projects/OptimizedNormalForms/Benchmarking/FileNamesLinux",'\n',String)

include("/home/gert/Projects/OptimizedNormalForms/oscarOut.jl")

numMatrices = 15

for i in 1:numMatrices
  mat = readdlm( "/home/gert/Projects/OptimizedNormalForms/JULIA/" * linuxFileNames[i] );
  matZZ = matrix( ZZ, mat );
  matBigInt = BigInt.(mat) 
  println(i);
  @timeit to string(i) * "_OSCAR"  hnf_with_transform(matZZ);
  @timeit to string(i) * "_OwnBigInt" bigint_hnf_with_transform(matBigInt);
end

show(to)
