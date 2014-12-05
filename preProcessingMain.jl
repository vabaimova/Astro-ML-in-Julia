#=
    preProcessingMain
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

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



function initializeSettings(settingsFile::String,chunkNum::Int64)

    ## Make sure that a settings file exists
    try f = open(settingsFile,"r")
        ## The file exists so proceed to read it
        settings = readdlm(f,String,skipstart=6)
        ## Create a settings object that contains the data
        ## found in SETTINGS.txt
        mySettings = Settings(settings[1],settings[2],settings[3],settings[4])
    
        ## Check to make sure that the directory names end with "/"
        mySettings.fits_dir = checkDirEnd(mySettings.fits_dir)
        mySettings.rlc_dir = checkDirEnd(mySettings.rlc_dir)
        mySettings.flc_dir = checkDirEnd(mySettings.flc_dir)
        mySettings.header_dir = checkDirEnd(mySettings.header_dir)
    
        ## Modify the FITS directory in the settings
        ## to include the chunk number
        mySettings.fits_dir = mySettings.fits_dir * string(chunkNum)
    
        return mySettings

   catch
        ## The file does not exist
        println("Settings file does not exist!")
        throw("Make sure you have SETTINGS.txt")
    end
end



## Overwrites the status file with the current status and KID
function overwriteStatusFile(statusFile::String,step::String,kid::String)
    ## DO NOT WANT TO TRUNCATE, CAUSES ISSUES
#    ## Truncate file to rewrite current step
#    truncate(statusFile,0)
#    ## Write the current step
#    write(statusFile,step)


end



function main(chunkNum::Int64,settingsFile::String,statusFile::String)

    ## Initialize the settings
    settings = initializeSettings(settingsFile,chunkNum)

    ## Get the first KID in the chunk directory
    allKIDs = dir_KIDs(settings.fits_dir)
    firstKID = allKIDs[1]

    ## Get the current status setup
    ## Check if status file exists
    if isfile(statusFile)
        f = open(statusFile,"r+")
        status = readdlm(f,String)
        ## A status file exists so process stopped in the middle
        ## These are the settings of where to set up
        step = status[1]
        currKID = status[2]
   else
        ## The default settings are used if no status file exits
        step = "lightcurve"
        currKID = firstKID

        ## Create a status file
        statusFile = open("STATUS.txt","w")
   end

#   println("Status file: ", statusFile)
#   println("current KID: ", currKID)
#   println("step: ", step)

    ## Begin switch statement that controls process

    @label start
    @match step begin
        ## In this first step we are extracting the data 
        ## from the lightcurves
        "lightcurve"        =>  begin
                                    step = "headerData"
                                    @goto start
                                end

        ## The second step is to get the header data for each KID
        "headerData"        =>  begin

                                    step = "" 
                                    @goto start
                                end

        ## The third step is to combine all the data we acquired
        ## Into one large feature space
        _                   =>  begin

                                end

    end
end
