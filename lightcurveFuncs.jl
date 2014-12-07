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

using FITSIO
using Stats
using HDF5, JLD

function dir_KIDs(dir_name::String)
    #=
    this function will return all the KIDs that are within the given directory
    uses the filenames (assumes the form of kplr#########-#############_llc.fits)
    =#

    println("Reading directory: " * dir_name)

    fits_files = readdir(dir_name)          #returns all the files from dir_name

    
    kids = String[]                         #initialize an empty string array
    temp_kid = ""                           #this will be used to compare kids

    for file in fits_files
        kid = file[5:13]                    #extract the 9 digit id number
        if kid != temp_kid
            append!(kids,[kid])
        end
        temp_kid = kid
    end

    println("Discovered ",length(kids)," unique Kepler ID numbers")
    return kids
end



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
    fits_read_col(f,Float64,1,1,1,time)
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



function test_fits_dir(dir::String)
    #=
    Produces a warning message if directory does not exist
    name will be used to generate warning message
    =#
    try readdir(dir)
        println("Found FITs directory!")
    catch
        println("Please check SETTINGS.txt file")
        ## this will halt execution of the entire program with a helpful message
        throw("Could not find FITs directory!")
    end
end



function make_if_needed(dir::String)
    #=
    Produces a warning message if directory does not exist
    name will be used to generate warning message
    =#
    try readdir(dir)
    catch
        mkdir(dir)
    end
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

    fits_list = map((x) -> settings.fits_dir * "/"  * x, fits_list)


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



#function testing()
#    fits_dir = "/home/mark/lc_foo/"   ## should come from settings file
#    test_fits_dir(fits_dir)
#
#    #kids_file = "/home/mark/foo.txt   ## this will 
#    #kids = readdlm(kids_file)         ## this will be the 'chunk file' that will be passed to main
#    kids = dir_KIDs(lc_dir)   ## this will need to come from a file specified by settings file
#
#    reduced_lc_dir = "/home/mark/rlc_foo/"  ## should come from settings file
#    make_if_needed(reduced_lc_dir)
#    
#    feature_lc_dir = "/home/mark/flc_foo/"  ## should come from settings file
#    make_if_needed(feature_lc_dir)
#
#    fits_list = readdir(fits_dir)
#    ## get the full fits file path
#    fits_list = map((x) -> fits_list_dir * x, fits_list)
#    ## loop over the kids
#    for kid in kids
#        ## get the qflux lightcurve
#        time,qflux = get_qflat_lc(kid,fits_list)
#
#        ## do feature extraction for qflux
#        qvar = var(qflux)
#        qskew = skewness(qflux)
#        qkurt = kurtosis(qflux)
#
#        ## perform dflat on the qflux lightcurve
#        dflux = do_dflat(time,qflux,1.0)    ## 1 day flattening
#
#        ## do feature extraction for dflux
#        dvar = var(dflux)
#        dskew = skewness(dflux)
#        dkurt = kurtosis(dflux)
#
#        ## write out an hdf5 file with time, qflux, dflux
#        rlc_file = rlc_dir*kid
#        save(rlc_file, "time", time, "qflux", qflux, "dflux", dflux)
#
#        ## write out to the lc_feature file
#        feat_line = [kid,qvar,qskew,qkurt,dvar,dskew,dkurt]
#
#    end
#    
#end
