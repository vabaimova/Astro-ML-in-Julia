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


function readSettings(settingsFile::String)

    f = open(settingsFile,"r")
    settings = readdlm(f,String,skipstart=6)
    println("Settings: ", settings)
end



function main(chunkNum::Int64,settingsfile::String,statusFile::String)
    # Need to somehow handle the chunk number thing
    # the chunk number will help the settings configuration
    # figure out which directory to look in to get the files for that chunk

    # Do something clever with all the settings
    

    ## Get the current status setup
    try status = readlines(f)
        ## A status file exists so process stopped in the middle
        ## These are the settings of where to set up
        step = status[1]
        currKID = status[2]
    catch
        ## The default settings are used if no status file exits
        step = "lightcurve"
        # currKID = whatever the first one in the chunk is
    end


#    ## Name the steps
#    lightcurve = "Starting lightcurve step"
#    headerData = "Starting headerData step"
#    combine = "Starting the combination step"

    ## Need to create a list of all of the unique KIDs in the
    ## directory of the chunk
    # allKIDs = dir_KIDs(dirName)

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
         "headerData"       =>  begin

                                step = "" 
                                @goto start
                                end

        ## The third step is to combine all the data we acquired
        ## Into one large feature space
        _                   =>  begin

                                end

    end
end
