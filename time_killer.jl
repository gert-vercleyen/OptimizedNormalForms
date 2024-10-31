using Oscar
using DelimitedFiles
using Distributed

function readMatrix(filename)
   return readdlm(filename, '\t', Int, '\n')
end

@everywhere function longrun(result, m)
    x = @time m^2 // Put the call to the transform here. Just simply add another parameter f and call @time f(m)
    put!(result, (x, myid()))
    return x
end

function ready_or_not(result,wid)
    if !isready(result)
        println("Computation at $wid will be terminated")
        rmprocs(wid)
        return nothing
    else
        return take!(result)
    end
end

function timeIt(f, m, seconds)
   addprocs(1)
   wid = workers()[end]
   res = RemoteChannel()
   M = matrix(ZZ, m)
   remote_do(longrun, wid, res, M)
   for i in 1:seconds*100
      sleep(.01)
      println("$(isready(res))")
      if isready(res)
         break
      end
   end
   show(ready_or_not(res, wid))
end
