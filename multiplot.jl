#=
    multiplot
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.

    this will produce plots of lightcurves, periodgrams and phase folded
    lightcurves
=#

using HDF5,JLD
using DSP
using PyPlot

function get_timeflux(file::String)
    data = jldopen(file,"r") do jldfile
        read(jldfile)
    end
    return data["time"], data["qflux"]
end

function evenly_space(time::Array{Float64},flux::Array{Float64},
    time_step::Float64)

    time_tol = time_step/100      ## one percent tolerance
    
    len_time = length(time)
    ## initialize padded time and flux arrays (may have to expand them)
    ##      initializing them should save time from having to build them up
    ##      element by element
    ptime = Array(Float64,len_time)
    pflux = Array(Float64,len_time)

    j = 1   ## an index for the padded arrays
    for i = 1:len_time-1
        tcur = time[i]
        tnext = time[i+1]
        ptime[j] = tcur
        pflux[j] = flux[i]

        while !isapprox(tcur+time_step,tnext,atol=time_tol)
            append!(ptime,[0.0])
            append!(pflux,[0.0])

            tcur += time_step
            ptime[j+1] = tcur
            pflux[j+1] = 0.0
            j += 1
        end

        j += 1
    end
    ptime[end]=time[end]
    pflux[end]=flux[end]

    return ptime,pflux
end

function testing()
    time_step = 0.020434
    sample_rate = 1/time_step
    dir = "/home/mark/kepler_ML/rlc/"
    files = readdir(dir)
    file = dir * files[1]
    println("file: ",file)
    stime,sflux = get_timeflux(file)
    ptime,pflux = evenly_space(stime,sflux,time_step)
    pgram = periodogram(pflux,fs=sample_rate)
    freqs = freq(pgram)
    powers = power(pgram)
    plot(freqs,powers) 
end

testing()
