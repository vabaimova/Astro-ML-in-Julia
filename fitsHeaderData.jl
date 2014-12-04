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



## This function will probably not be used in lieu of a function
## that will do the same thing that this one does
## except that it will take a function that contains the file names of just
## one instance of any particular Kepler ID number
function headerDataForDir(dirName::String,keywordList::String,beginPath::String)

    fitsFiles = readdir(dirName)
    headerData = Float64[]

    for file in fitsFiles
##        fileName = "/home/CREATIVE_STATION/lc_foo/" * file
        fileName = beginPath * file
#        println("Reading file: ", fileName)
        data = getHeaderData(fileName,keywordList)
        println("Data: ", data)
        append!(headerData, [data])
    end

## Used for testing the code    
#    println("Header data: ", headerData)

    return headerData
end



## This is a function that creates a file
## That lists the first instances of a particular KID
## In the given directory
function firstInstOfKID(dirName::String,fullPath::String)

    ## Get the file names from the given directory
    files = readdir(dirName)

    ## Get all the unique Kepler IDs in the given directory
    allKIDs = dir_KIDs(dirName)
    println("KIDs: ", allKIDs)

#    ## Create an array that will store all the file names
    instances = String[]
    
    for id in allKIDs
        ## Get the first file name with this Kepler ID
        theInstance = files[findfirst(map((x) -> contains(x,id),files))]
        ## Create the full path for the file name
        theInstance = fullPath * theInstance
        ## Append to the list of all of the first instances
        append!(instances, [theInstance])
    end

    ## Write out to a file


    println("instances: ", instances)
#    return instances

end

## This function does the same thing as headerDataForDir, except
## it takes a file that contains a list of FITS files that are unique
## instances of their Kepler IDs
function headerDataForUniqueKIDs(listOfFiles::String,keywordList::String,beginPath::String)

    fileList = open(listOfFiles,"r")
    files = readdlm(listOfFiles,String)
    files = map((x) -> normalize_string(x),files)

    headerData = Float64[]

    for file in files
##        fileName = "/home/CREATIVE_STATION/lc_foo/" * file
        fileName = beginPath * file
#        println("Reading file: ", fileName)
        data = getHeaderData(fileName,keywordList)
        println("Data: ", data)
        append!(headerData, [data])
    end

    return headerData
end




