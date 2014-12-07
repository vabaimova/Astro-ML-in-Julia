#=
    fitsHeaderData
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

## Reads in FITS file and takes the necessary Kepler data
## Formats the data in an array which will eventually be appended
## to one big file where each row is a star

using FITSIO
include("lightcurveFuncs.jl")

function getHeaderData(fileName::String, keywordList::String)
    
    fitsFile = FITS(fileName)
    header = readheader(fitsFile[1])
    keywordFile = open(keywordList,"r")

    ## Create an array of keywords that contain the desired data
    keywords = readdlm(keywordFile,String)
    keywords = map((x) -> normalize_string(x),keywords)

    ## Create array that will contain the extracted data
    starData = Float64[]

    for keyword in keywords
        ## Access the value stored in the header at the keyword
        data = header[keyword] 

        ## Test if there is not a value
        ## If no value exists, replace with -9999
        if typeof(data) == Nothing
            data = -9999
        end

        ## Append the acquired value to the data array
        append!(starData,[data])
    end

#    Used for testing the accuracy of code
#    println("Star Data: ", starData)
    
    return starData
end



## This function takes a directory name and a Kepler ID number
## and returns the first file instance for that KID
function firstInstOfKID(dirName::String, kid::String)

    ## Get the file names from the given directory
    files = readdir(dirName)

    ## Find the first instance of the Kepler ID in the file directory
    instance = files[findfirst(map((x) -> contains(x,kid),files))]
    
    println("instance: ", instance)
    return instance

end



## This function takes a directory and a Kepler ID number and returns
## The header data for that particular ID number by finding the first
## File that is for that KID
## The directory name is only used to pass on to the firstInstOFKID()
function headerDataForKID(kid::String,dirName::String,keywordList::String)

    ## Get the file name of the first instance for the KID
    file = firstInstOfKID(dirName,kid)

    ## Get the full path of the file
    file = dirName * file

    ## Get the header data for the file
    headerData = getHeaderData(file,keywordList)

    println("Data: ", headerData)

    return headerData
end



## Testing function
function for_to_test()
    #kid = "006921913"
    dirName = "/home/mark/lc_foo/"
    keywordList = "headerKeyWordList.txt"

    headerDataForKID(kid,dirName,keywordList)

end


function headerDriver(settings::Settings,allKIDs,chunkNum::Int64,statusIO::IOStream)

    ## Test all the directories to make sure they exist
    test_fits_dir(settings.fits_dir)
    make_if_needed(settings.header_dir)
    
    ## The settings initialization already has the full file path
    fits_list = readdir(settings.fits_dir)

    status = readdlm(statusIO,String)
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

        head_data = headerDataForKID(kid,fits_dir,settings.keyword_list)
        writecsv(header_file,head_data)
        flush(header_file)

        ## update the current status
        status[2] = kid
        writedlm(statusIO,status,delim="\n")
        flush(statusIO)
    end
end



### This function will probably not be used in lieu of a function
### that will do the same thing that this one does
### except that it will take a function that contains the file names of just
### one instance of any particular Kepler ID number
#function headerDataForDir(dirName::String,keywordList::String,beginPath::String)
#
#    fitsFiles = readdir(dirName)
#    headerData = Float64[]
#
#    for file in fitsFiles
###        fileName = "/home/CREATIVE_STATION/lc_foo/" * file
#        fileName = beginPath * file
##        println("Reading file: ", fileName)
#        data = getHeaderData(fileName,keywordList)
#        println("Data: ", data)
#        append!(headerData, [data])
#    end
#
### Used for testing the code    
##    println("Header data: ", headerData)
#
#    return headerData
#end




