#=
    dataformatting
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

using FITSIO

#function some_funct(fits_filename::String)
#    f = fits_open_file(fits_filename)
#    kid = fits_read_keyword(f,"KEPLERID")

function dir_KIDs(dir_name::String)
    #=
    this function will return all the KIDs that are within the gived directory
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
