#=
    testDrivers
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

## A program to test the drivers that preprocess the data

include("lightcurveFuncs.jl")
include("headerData.jl")
include("preProcessingMain.jl")

function testLCDriver()
    settingsFile = "CREATIVE_STATION_SETTINGS.txt"
    mySettings = initializeSettings(settingsFile,1)

    allKIDs = dir_KIDs(settings.fits_dir)
    firstKID = allKIDs[1]

    lightcurveDriver(mySettings,firstKID,allKIDs,1)
end
