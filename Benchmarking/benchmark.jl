using Oscar
using DelimitedFiles
using TimerOutputs

to = TimerOutput()

linuxFileNames = readdlm("Benchmarking/FileNamesLinux",'\n',String)

numMatrices = 30

# for i in 1:numMatrices
#   mat = matrix( ZZ, readdlm( "JULIA/" * linuxFileNames[i] ) );
#   println(i);
#   @timeit to linuxFileNames[i] snf_with_transform(mat);
# end

#show(to)

@time mat = matrix( ZZ, readdlm( "JULIA/" * linuxFileNames[30] ) );

@profview_allocs snf_with_transform(mat) sample_rate=0.1