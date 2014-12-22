#=
    multiplot
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.

    this will produce plots of lightcurves, periodgrams and phase folded
    lightcurves
=#

include("helperFuncs.jl")
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


function get_freqs(time::Array{Float64},flux::Array{Float64},
    time_step::Float64)

    ## evenly pad the flux vector
    time,flux = evenly_space(time,flux,time_step)

    sample_rate = 1/time_step
    pgram = periodogram(flux,fs=sample_rate)
    f = freq(pgram)
    p = power(pgram)
    return f,p
end


function get_tfold(time::Array{Float64},freqs::Frequencies,
    power::Array{Float64})

    maxfreq = freqs[indmax(power)]
    println("Max freq = ",maxfreq)

    period = 1/maxfreq
    tfold = (time % period)/period

    return tfold,period
end


function multiplot(time::Array{Float64},flux::Array{Float64},
    freq::Frequencies,power::Array{Float64},tfold::Array{Float64},
    title::String,period::Float64,outdir::String)

    title_size=26
    font_size=18

    plt.clf()

    ## lightcurve
    plt.subplot(311)
    plt.title(title,fontsize=title_size)
    plt.xlim(minimum(time),maximum(time))
    plt.xlabel("time [days]",fontsize=font_size)
    plt.ylabel(L"flux [e$^{-}$/ s]",fontsize=font_size)
    plt.tick_params(axis="both",which="major",labelsize=font_size)
    plt.tick_params(axis="both",which="minor",labelsize=font_size)
    plt.plot(time,flux,"o",markersize=1,color="black")

    
#    ## power spectrum: 0 to 5
#    plt.subplot(121)
#    plt.xlim(0,5)
#    plt.xlabel(L"frequency [days$^{-1}$]",fontsize=font_size)
#    plt.ylabel(L"power [e$^{-}$/ s]",fontsize=font_size)
#    plt.tick_params(axis="both",which="major",labelsize=font_size)
#    plt.tick_params(axis="both",which="minor",labelsize=font_size)
#    plt.plot(freq,power,color="black")

    ## power spectrum: 0 to 24 
    ax = plt.subplot(312)
    plt.xlim(0.01,24)
    plt.xscale("log")
    plt.xlabel(L"frequency [days$^{-1}$]",fontsize=font_size)
    plt.ylabel(L"power [e$^{-}$/ s]",fontsize=font_size)
    plt.tick_params(axis="both",which="major",labelsize=font_size)
    plt.tick_params(axis="both",which="minor",labelsize=font_size)
    plt.plot(freq,power,color="black",drawstyle="steps-mid")


    ## phase folded lightcurve
    plt.subplot(313)
    speriod = @sprintf("%5.3f",period)
    plt.xlabel("phase [1 cycle = "*speriod*" days]",fontsize=font_size)
    plt.ylabel(L"flux [e$^{-}$/ s]",fontsize=font_size)
    plt.tick_params(axis="both",which="major",labelsize=font_size)
    plt.tick_params(axis="both",which="minor",labelsize=font_size)
    plt.plot(tfold,flux,"o",markersize=1,color="black")
    
    plt.tight_layout()
    outputfile = outdir * title * ".png"
    savefig(outputfile, bbox_inches="tight")
    println("Saved: ",outputfile)

end


## File: JLD file to read
## Title: title of the plot (KID)
## Outdir: directory where the plots are to be saved 
function make_plot(file::String,title::String,outdir::String)
    time_step = 0.020434

    time,flux = get_timeflux(file)

    freq,power = get_freqs(time,flux,time_step)

    tfold,period = get_tfold(time,freq,power)
    
    multiplot(time,flux,freq,power,tfold,title,period,outdir)
end


## Driver to run the plotting process
function plotDriver()
    ## This is where we will find the reduced lightcurves
    inputDir = "/home/CREATIVE_STATION/kepler_ML/rlc/"
    ## Make sure that the directory is properly formatted
    inputDir = checkDirEnd(inputDir)
    files = readdir(inputDir)

    ## Get the KIDs from this directory to serve as plot titles
    kids = map((x) -> x[1:9],files)

    ## Add the full directory path onto the files in that directory
    files = map((x) -> inputDir * x, files)

    ## Create the output directory
    outputDir = "/home/CREATIVE_STATION/kepler_ML/multiplots/"
    ## Make sure the end of the directory is correct
    outputDir = checkDirEnd(outputDir)
    ## Create the directory if it does not already exist
    make_if_needed(outputDir)

    for i = 1:length(files)
        make_plot(files[i],kids[i],outputDir)
        println("Made plot for kid: ", kids[i])
    end

#    make_plot(files[1],kids[1],outputDir)
#    println("Made plot for kid: ", kids[1])


end



function testing()
#    dir = "/home/mark/kepler_ML/rlc/"
    dir = "/home/CREATIVE_STATION/kepler_ML/rlc/"
    files = readdir(dir)
    file = dir * files[1]
    println("file: ",file)
    make_plot(file)
end

#testing()
plotDriver()
