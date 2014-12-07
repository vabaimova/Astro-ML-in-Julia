#=
    testDrivers
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

## A program to test the drivers that preprocess the data

include("lightcurveFuncs.jl")
include("fitsHeaderData.jl")
include("preProcessingMain.jl")

function testLCDriver(settingsFile::String,headerKeywordList::String,chunkNum::Int64)
#    settingsFile = "CREATIVE_STATION_SETTINGS.txt"
#    chunkNum = 1
    mySettings = initializeSettings(settingsFile,headerKeywordList,chunkNum)

    allKIDs = dir_KIDs(settings.fits_dir)
    firstKID = allKIDs[1]

    lightcurveDriver(mySettings,firstKID,allKIDs,chunkNum)
end
