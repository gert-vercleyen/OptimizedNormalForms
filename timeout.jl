using Oscar
using DelimitedFiles
using TimerOutputs

# Define the limits
time_limit = 0.005  # in seconds
memory_limit = 2 * 1024^3  # 2GBs
const to = TimerOutput()

# Define the long-running task with memory and time monitoring
function long_running_task()
    try
        fileName = "mat__7_1_6_1.dat"#"mat__2_1_0_2.dat"
        file_path = joinpath("OptimizedNormalForms/JULIA", fileName)
        mat = matrix(ZZ, readdlm(file_path, '\t', Int, '\n'))
       	 
        # Start the timed section
        @timeit to fileName snf_with_transform(mat)
        show(to)
       	println(mat) 
    catch e
        if e isa InterruptException
            println("Task interrupted due to time or memory limit.")
        else
            rethrow(e)
        end
    end
end

# Run the long-running task asynchronously
task = @async long_running_task()

# Monitor time
@async begin
    sleep(time_limit)  # Wait for the time limit
    if !istaskdone(task)
        println("Time limit exceeded. Interrupting task...")
        Base.throwto(task, InterruptException())
    end
end

# Monitor memory usage without delay
@async begin
    while !istaskdone(task)
        current_memory = Base.summarysize() #Base.gc_bytes()
        
        # Uncomment for debugging: println("Current memory usage: $(current_memory / 1024^2) MB")
        
        if current_memory > memory_limit
            println("Memory limit exceeded. Interrupting task...", current_memory)
            Base.throwto(task, InterruptException())
            break
        end
    end
end

# Wait for the main task to complete or be interrupted
wait(task)

