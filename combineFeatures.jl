#=
    combineFeatures
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

include("preProcessingMain.jl")
using PyCall
@pyimport sklearn.preprocessing as preprocessing

function combineLCFeatures(settings)

end



function imputeHeaderData(headerData)
    ## Create imputer
    imp = preprocessing.Imputer(missing_values=-9999,strategy="median",axis=0)
    ## Replace the missing values (represented by -9999)
    ## with the median of the column
    imputedData = imp[:fit_transform](headerData)
    
    return imputedData

end



function combineHeaderFeatures(settings)

end



function combineAllFeatures(settings)

end
