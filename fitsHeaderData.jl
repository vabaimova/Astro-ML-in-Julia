#=
    fitsHeaderData
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

## Reads in FITS file and takes the necessary Kepler data
## Formats the data in an array which will eventually be appended
## to one big file where each row is a star

using FITSIO

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
        ## Append the acquired value to the data array
        append!(starData,[data])
    end

#    Used for testing the accuracy of code
#    println("Star Data: ", starData)
    
    return starData

end


function headerDataForDir(dirName::String, keywordList::String)

    fitsFiles = readdir(dirName)
    headerData = Float64[]

    for file in fitsFiles
        fileName = "/home/CREATIVE_STATION/lc_foo/" * file
        println("Reading file: ", fileName)
        data = getHeaderData(fileName,keywordList)
#        append!(headerData, [data])
    end
#    
#    println("Header data: ", headerData)
end

