#=
    fitsHeaderData
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

## Reads in FITS file and takes the necessary Kepler data
## Formats the data in an array which will eventually be appended
## to one big file where each row is a star

using FITSIO
include("helperFuncs.jl")

function getHeaderData(fileName::String, settings)
    fitsFile = FITS(fileName)
    header = readheader(fitsFile[1])

    ## Create array that will contain the extracted data
    starData = Any[]

    for keyword in settings.keyword_list
        ## Access the value stored in the header at the keyword
        data = header[keyword]

        if keyword == "KEPLERID"
            data = @sprintf("%d",data)
            data = lpad(data,9,0)
        end

        ## Test if there is not a value
        ## If no value exists, replace with -9999
        if typeof(data) == Nothing
            data = -9999
        end

        ## Append the acquired value to the data array
        append!(starData,[data])
    end

    return starData
end



## This function takes a directory and a Kepler ID number and returns
## The header data for that particular ID number by finding the first
## File that is for that KID
## The directory name is only used to pass on to the firstInstOFKID()
function headerDataForKID(kid::String,settings)
    ## Get the file name of the first instance for the KID
    file = firstInstOfKID(settings.fits_dir,kid)

    ## Get the full path of the file
    file = settings.fits_dir * file

    ## Get the header data for the file
    headerData = getHeaderData(file,settings)

    return headerData
end



function headerDriver(settings,allKIDs,chunkNum::Int64,statusIO::IOStream)

    ## Test all the directories to make sure they exist
    test_fits_dir(settings.fits_dir)
    make_if_needed(settings.header_dir)
    
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
    header_file_name = settings.header_dir * "/head_feat_" * string(chunkNum) * ".csv"
    header_file = open(header_file_name,"a")

    for i = currInd:endInd
        ## Set the current kid
        kid = allKIDs[i]
#        println(typeof(kid))

        head_data = headerDataForKID(kid,settings)
        head_data = reshape(head_data,1,length(head_data))
        writecsv(header_file,head_data)
        flush(header_file)

        ## update the current status
        status[2] = kid
        overwriteStatusFile(statusIO,status[1],status[2])
    end
end



