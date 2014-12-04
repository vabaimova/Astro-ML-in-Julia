#=
    preProcessingMain
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

## Include the files that contain all of our functions

using Match

function main(chunkNum::Int64,step::String)
    # Need to somehow handle the chunk number thing
    # the chunk number will help the settings configuration
    # figure out which directory to look in to get the files for that chunk

    # Do something clever with all the settings

#    ## Name the steps
#    lightcurve = "Starting lightcurve step"
#    headerData = "Starting headerData step"
#    combine = "Starting the combination step"

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
