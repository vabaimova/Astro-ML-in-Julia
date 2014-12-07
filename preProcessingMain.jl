#=
    preProcessingMain
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>
        and Mark Wells <mwellsa@gmail.com>
    

    Distributed under terms of the MIT license.
=#

## Include the files that contain all of our functions

using Match
include("lightcurveFuncs.jl")
include("fitsHeaderData.jl")


type Settings
    ## This is the definition of a Settings object
    ## Each field of this object contains settings info
    ## to be used in our functions

    ## The name of the directory that contains the FITS files
    fits_dir::String
    ## The name of the directory that contains the reduced lightcurves
    rlc_dir::String
    ## The name of the directory that contains the features from lightcurves
    flc_dir::String
    ## The name of the directory that contains the header data
    header_dir::String
    ## Directory that will contain the status file
    status_dir::String
    ## Header keyword list
    keyword_list::Array{String}
end



## Make sure that the end of the directory name has a /
## so that any operation that involved appending to the file path
## would be carried out successfully
function checkDirEnd(dirName::String)
    
    if dirName[end] != '/'
        dirName = dirName * "/"
#        println("Needed / addition")
    end
#    println(dirName)
    return dirName

end



## Read in header keyword list
function readHeaderKeywords(keywordListFile::String)
    ## Make sure that a keyword file exists
    try f = open(keywordListFile,"r")
        ## The file exists so proceed to read it
        keywords = readdlm(f,String)
        ## Explicitly convert to strings from substrings
        println("typeof(keywords)=",typeof(keywords))
        keywords = convert(Array{ASCIIString},keywords)

    
        return keywords

   catch
        ## The file does not exist
        println("Keyword file does not exist!")
        throw("Make sure you have headerKeyWordList.txt")
    end

end




function initializeSettings(settingsFile::String,keywordListFile::String,chunkNum::Int64)

    ## Make sure that a settings file exists
    try f = open(settingsFile)
        ## The file exists so proceed to read it
#        settings = readdlm(f,String,comments=true,comment_char=':')
        settings = readdlm(f,String,skipstart=10)

        ## Get the header keywords
        keyword_list = readHeaderKeywords(keywordListFile)

        ## Create a settings object that contains the data
        ## found in SETTINGS.txt
        mySettings = Settings(settings[1],settings[2],settings[3],settings[4],settings[5],keyword_list)
    
        ## Modify the FITS directory in the settings
        ## to include the chunk number
        mySettings.fits_dir = mySettings.fits_dir * string(chunkNum)

        ## Check to make sure that the directory names end with "/"
        mySettings.fits_dir = checkDirEnd(mySettings.fits_dir)
        mySettings.rlc_dir = checkDirEnd(mySettings.rlc_dir)
        mySettings.flc_dir = checkDirEnd(mySettings.flc_dir)
        mySettings.header_dir = checkDirEnd(mySettings.header_dir)
        mySettings.status_dir = checkDirEnd(mySettings.status_dir)

        return mySettings

   catch
        ## The file does not exist
        println("Settings file does not exist!")
        throw("Make sure you have SETTINGS.txt")
    end
end



## Overwrites the status file with the current status and KID
function overwriteStatusFile(statusFile::IOStream,step::String,kid::String)
    status = [step,kid]
    writedlm(statusFile,status)
    flush(statusFile)
    seekstart(statusFile)
end



function main(chunkNum::Int64,settingsFile::String,statusFileName::String,headerKeywordFile::String)

    ## Initialize the settings
    settings = initializeSettings(settingsFile,headerKeywordFile,chunkNum)

    ## Get the first KID in the chunk directory
    allKIDs = dir_KIDs(settings.fits_dir)
    firstKID = allKIDs[1]

    ## Get the current status setup
    ## Check if status file exists
    ## Needs to be the full directory
    if isfile(statusFileName)
        statusFile = open(statusFileName,"r+")
        status = readdlm(statusFile,String)
        seekstart(statusFile)
        ## A status file exists so process stopped in the middle
        ## These are the settings of where to set up
        step = status[1]
        currKID = status[2]
   else
        ## The default settings are used if no status file exits
        step = "lightcurve"
        currKID = firstKID

        ## Create a status file
        statusFileName = settings.status_dir * "STATUS_" * string(chunkNum) * ".txt"
        statusFile = open(statusFileName,"w+")
        overwriteStatusFile(statusFile,step,currKID)
   end

   println("Status file: ", statusFile)
#   println("current KID: ", currKID)
#   println("step: ", step)

    ## Begin switch statement that controls process

    @label start
    @match step begin
        ## In this first step we are extracting the data 
        ## from the lightcurves
        "lightcurve"        =>  begin
                                    println("Starting lightcurve driver!")
                                    lightcurveDriver(settings,allKIDs,chunkNum,statusFile)
                                    step = "headerData"
                                    currKID = firstKID

                                    overwriteStatusFile(statusFile,step,currKID)
                                    println("Finished lightcurve driver!")
                                    @goto start
                                end

        ## The second step is to get the header data for each KID
        "headerData"        =>  begin
                                    println("Starting header driver!")
                                    headerDriver(settings,allKIDs,chunkNum,statusFile)
                                    step = "" 
                                    currKID = firstKID
                                    println("Finished header driver!")
                                    @goto start
                                end

        ## The third step is to combine all the data we acquired
        ## Into one large feature space
        _                   =>  begin

                                end

    end
end
