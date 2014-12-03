#=
    dataformatting
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

using FITSIO
using DataArrays, DataFrames

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


function testing()
    lc_dir = "/home/mark/lc_foo/"
    kids = dir_KIDs(lc_dir)
    fits_list = readdir(lc_dir)
    fits_list = map((x) -> lc_dir * x, fits_list)
    get_full_LC(kids[1],fits_list)
end


function get_full_LC(kid::String,file_list)
    #=
    This function returns the full lightcurve (with the mean level subtracted
    for each quarter.
    =#


    ## see if each element contains kid string
    ## then find the "true" elements
    ## then returns the elements of file_list that contained kid
    total_kid_fits = file_list[find(map((x) -> contains(x,kid),file_list))]


#    println(fits_file)
#    println(typeof(fits_file))

#    fits_file = total_kid_fits[1]       #developing for one then expand

    tot_time = DataArray{Float64}[]
    tot_flux = DataArray{Float64}[]

    for fits_file in total_kid_fits
        f = fits_open_table(fits_file)      #open the fits file
    
        # read out the length of the arrays
        naxis2 = fits_read_keyword(f,"NAXIS2")
        length=int(naxis2[1])
    
        # initialize arrays to be populated
        time = Array(Float64,length)
        flux = Array(Float64,length)
        # read out the values
        # column 1 is time 
        fits_read_col(f,Float64,1,1,1,time)
        # column 8 is pdcsap_flux
        fits_read_col(f,Float64,8,1,1,flux)
    
        # close the fits file
        fits_close_file(f)
    
        # hcat and convert
        d_time = DataArray(time)
        d_flux = DataArray(flux)
#        time_flux = DataArray([time flux])
        # replace Julia's NaN with DataArray's NA
        where_nan = findin(flux,NaN)
#        time_flux[where_nan] = NA
    end
#    return time_flux
end
