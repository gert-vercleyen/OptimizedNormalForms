using Oscar
using DelimitedFiles

filenames = readdlm("fileNames.txt");

for i in range( 1, length(filenames) )
  mat = readdlm(filenames[i]);
  mat = sparse_matrix( ZZ, sparse( mat[1,:], mat[2,:], mat[3,:] ) |> Array );
  save("sparsematrix_" * string(i), mat )
end
