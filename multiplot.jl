#=
    multiplot
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.

    this will produce plots of lightcurves, periodgrams and phase folded
    lightcurves
=#

using HDF5,JLD
using DSP
#using PyCall
#@pyimport matplotlib.pyplot as plt
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

    ## power spectrum
    plt.subplot(312)
    plt.xlabel(L"frequency [days$^{-1}$]",fontsize=font_size)
    plt.ylabel(L"power [e$^{-}$/ s]",fontsize=font_size)
    plt.tick_params(axis="both",which="major",labelsize=font_size)
    plt.tick_params(axis="both",which="minor",labelsize=font_size)
    plt.plot(freq,power,color="black")

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

function make_plot(file::String,plotfile::String,outdir::String)
    time_step = 0.020434

    time,flux = get_timeflux(file)

    freq,power = get_freqs(time,flux,time_step)

    tfold,period = get_tfold(time,freq,power)
    
    multiplot(time,flux,freq,power,tfold,"foo",period,outdir)
end

function testing()
    dir = "/home/mark/kepler_ML/rlc/"
    files = readdir(dir)
    file = dir * files[1]
    println("file: ",file)
    make_plot(file)
end

testing()
