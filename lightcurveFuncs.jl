#=
    lightcurveFuncs
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>
        and Vera Abaimova <stormseecker@gmail.com>
    Distributed under terms of the MIT license.

    function list:
        dir_KIDs
        testing (temp)
        get_lc_segment
        get_qflat_lc
        do_dflat
        lightcurveDriver
=#

include("helperFuncs.jl")

using FITSIO
using Stats
using HDF5, JLD


function get_lc_segment(fitsfile::String)
    ## open the fits table for reading
    f = fits_open_table(fitsfile)
    ## read out the length of the arrays
    naxis2 = fits_read_keyword(f,"NAXIS2")
    length=int(naxis2[1])
    
    ## initialize arrays to be populated
    time = Array(Float64,length)
    flux = Array(Float64,length)
    ## read out the values
    ## column 1 is time 
    try fits_read_col(f,Float64,1,1,1,time)
        ## column 8 is pdcsap_flux
        fits_read_col(f,Float64,8,1,1,flux)

        ## close the fits file
        fits_close_file(f)

        ## find the indices of time that are well behaved
        good_inds = find(isfinite(time))
        time = time[good_inds]
        flux = flux[good_inds]

        ## find the indices of time that are well behaved
        good_inds = find(isfinite(flux))
        time = time[good_inds]
        flux = flux[good_inds]

        return time,flux

    catch
        println("Bad fitsfile: ",fitsfile)
        time = Float64[]
        flux = Float64[]
        return time,flux
    end
end


function get_qflat_lc(kid::String,file_list)
    #=
    This function returns the full lightcurve with the mean level subtracted
    for each quarter.
    =#

    #=
    see if each element contains kid string
    then find the "true" elements
    then returns the elements of file_list that contained kid
    =#
    all_fits_for_kid = file_list[find(map((x) -> contains(x,kid),file_list))]

    tot_time = Float64[]
    tot_flux = Float64[]

    for fits_file in all_fits_for_kid
#        println(fits_file)

        time,flux = get_lc_segment(fits_file)
        ## append time to tot_time
        append!(tot_time,time)
        ## subtract the mean from each quarter and append to tot_time
        append!(tot_flux,flux-mean(flux))


    end
    return tot_time,tot_flux
end


function do_dflat(time::Array{Float64},flux::Array{Float64},flat_period::Float64)
    #=
    This function will return an array that has been flattened using the
    flat_period.
    =#

    time_segments = floor(time/flat_period)
    flat_flux = Array(Float64,length(flux))
    
    first_segment = int(minimum(time_segments))
    last_segment = int(maximum(time_segments))

    for segment=first_segment:last_segment
        inds = findin(time_segments,segment)
        if length(inds) != 0
            flat_flux[inds] = flux[inds]-median(flux[inds])
        end
    end
    return flat_flux
end



function lightcurveDriver(settings,allKIDs,chunkNum::Int64,statusIO::IOStream)

    ## Test all the directories to make sure they exist
    test_fits_dir(settings.fits_dir)
    make_if_needed(settings.rlc_dir)
    make_if_needed(settings.flc_dir)
    

    ## The settings initialization already has the full file path
    fits_list = readdir(settings.fits_dir)

    status = readdlm(statusIO,String)
    seekstart(statusIO)
    currKID = status[2]

    ## Get the index of the current KID
    currInd = findfirst(allKIDs,currKID)
    ## Get the last index
    endInd = endof(allKIDs)

    ## Get the name of the flc_file
    flc_file_name = settings.flc_dir * "flc_" * string(chunkNum) * ".csv"
    flc_file = open(flc_file_name,"a")

#    fits_list = map((x) -> settings.fits_dir * "/"  * x, fits_list)
    fits_list = map((x) -> settings.fits_dir * x, fits_list)


    for i = currInd:endInd
        ## Set the current kid
        kid = allKIDs[i]

        ## Get the qflux lightcurve
        time,qflux = get_qflat_lc(kid,fits_list)

        ## Do feature extraction for qflux
        qvar = var(qflux)
        qskew = skewness(qflux)
        qkurt = kurtosis(qflux)

        ## Perform dflat on the qflux lightcurve
        dflux = do_dflat(time,qflux,1.0)    ## 1 day flattening

        ## Do feature extraction for dflux
        dvar = var(dflux)
        dskew = skewness(dflux)
        dkurt = kurtosis(dflux)

        ## Write out an hdf5 file with time, qflux, dflux
        rlc_file = settings.rlc_dir * kid * ".jld"
        save(rlc_file, "time", time, "qflux", qflux, "dflux", dflux)

        ## Write out to the lc feature file
        feat_line = [kid,qvar,qskew,qkurt,dvar,dskew,dkurt]
        feat_line = reshape(feat_line,1,length(feat_line))

        writecsv(flc_file,feat_line)
        flush(flc_file)

        ## update the current status
        status[2] = kid
        overwriteStatusFile(statusIO,status[1],status[2])
    end
end

