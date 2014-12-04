#=
    fitsHeaderData
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

## Reads in FITS file and takes the necessary Kepler data
## Formats the data in an array which will eventually be appended
## to one big file where each row is a star

using FITSIO
include("dataformatting.jl")

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
function headerDataForUniqueKIDs(kid::String,dirName::String,keywordList::String)

    files = readdir(dirName) 

    headerData = Float64[]

    for file in files
#        fileName = "/home/CREATIVE_STATION/lc_foo/" * file
#        println("Reading file: ", fileName)
        data = getHeaderData(fileName,keywordList)
        println("Data: ", data)
        append!(headerData, [data])
    end

    return headerData
end




