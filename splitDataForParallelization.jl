#=
    splitDataForParallelization
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

## This function takes a directory and a number of splits as parameters
## It runs dir_KIDs() to determine the number of unique Kepler IDs
## and then splits that list of ID numbers into the number of splits passed
## as the parameter
## Cretes text files containing the Kepler IDs for each group


## This function takes a file that contains the Kepler IDs to be grouped
## And then creates a text file that contains the full path for each file
## for each of the assigned Kepler IDs 
## It also creates a text file that contains the full path for only
## the first file that is for a specific ID


# At some point use cp(source,destination) to copy files
include("lightcurveFuncs.jl")
include("preProcessingMain.jl")

function create_chunk_files(dir::String,chunks::Int64)
    
    # dir = "/home/mark/bar/lc_foo"
    # chunks = 3
    
    kids = dir_KIDs(dir)
    numKIDs = length(kids)
    
    numKIDs_per_chunk = int(floor(numKIDs/chunks))
    println("numKIDs_per_chunk = ",numKIDs_per_chunk)
    numKIDs_left_over = numKIDs % chunks
    println("numKIDs_left_over = ",numKIDs_left_over)
    
    numKIDs_to_assign = Array(Int64,chunks)
    numKIDs_to_assign[1:end] = numKIDs_per_chunk
    
    for i=1:numKIDs_left_over
        numKIDs_to_assign[i] += 1
    end
    
    file_list = readdir(dir);
    
    start = 1
    
    for i=1:chunks
        chunk_files = String[]
        chunk_kids = kids[start:start+numKIDs_to_assign[i]-1]
    
        ## setting up a progress meter
        n = length(chunk_kids)
        progress_title = "Building chunk file " * string(i) * ": "
        p = Progress(n,1,progress_title,40)

        for kid in chunk_kids
            all_fits_for_kid = file_list[find(map((x) -> contains(x,kid),file_list))]
            append!(chunk_files,[all_fits_for_kid])
            ## update the progress meter
            next!(p)
        end
    
        start += numKIDs_to_assign[i]
    
        ## need to create files containing these
        fileName = "fits_files_" * string(i) * ".txt"
        file = open(fileName, "w+")
        writedlm(file,chunk_files)
        close(file)
    end
    println("done")
end



function create_chunk_copies(source::String,destination::String,chunks::Int64)
    #=
    source will be the file path which contains all the lightcurves

    destination will be the directory to save the chunk folders into
    =#



    ## Make sure destination and source directories has a "/" on the end
    destination = checkDirEnd(destination)
    make_if_needed(destination)
    source = checkDirEnd(source)

    ## setting up progress meter
    println("Setting up progress bar")
    n = length(readdir(source))
    p = Progress(n,2,"Copying FITs files: ",40) # minumum update interval: 2 seconds
    
    create_chunk_files(source,chunks)

    for i=1:chunks
        #get chunk file name
        chunk_file = "fits_files_" * string(i) * ".txt"

        #open chunk file
        f = open(chunk_file)
    
        #read it
        files = readdlm(f,String)
    
        #create output directory
        out_dir = destination * string(i) * "/"
        make_if_needed(out_dir)
    
        #create source file paths
        println("\nMapping source files for chunk ",i)
        source_files = map((x) -> source * x, files)
        println("Mapping destination files for chunk ",i)
        dest_files = map((x) -> out_dir * x, files)

        #copy files over
        for j=1:length(files)
            cp(source_files[j],dest_files[j])
            next!(p)
        end
    end
end


## script
using ProgressMeter
#source="/home/mark/bar/lc_foo/"
source="/home/mark/lightcurves/llc/"
#dest="/home/mark/bar/lc_foo_copy/"
dest="/media/MyBook/lightcurves/"
chunks=50
create_chunk_copies(source,dest,chunks)
