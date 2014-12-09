#=
    combineFeatures
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>
                     Mark Wells    <mwellsa@gmail.com>

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



function sortData(features)
    ## Sort by Kepler ID number to make future merging easier
    ## Get the sorted indices for the first column after transforming the
    ## Kepler ID strings to integers
    indices = sortperm(features[:,1],by=int)

    ## Reindex features with the new sorted indices
    features = features[indices,:]

    return features

end



function getImputedDataFromHeaderFeatFile(settings,file::String)

    ## Make sure the file name has the full path
    file = settings.header_dir * file
    println(file)
    
    f = open(file)
    data = readcsv(f)
    
    ## Close file once we have the data from it
    close(file)

    ## Impute the data to deal with missing values
    data = imputeHeaderData(data)

    return data

end



function combineHeaderFeatures(settings,fileToWriteName::String)

    ## Get a list of all the header features files in the given directory
    featureFiles = readdir(settings.header_dir)

    ## Go through all the files and vcat the features of the list
    for file in featureFiles 

        ## If the file is the first features file being processed
        if file == featureFiles[1]

            ## Get the data from the file
            data = getImputedDataFromHeaderFeatFile(settings,file)

            ## Create an array to hold all the header features
            ## and add the first batch of data so that we can perform vcat()
            headerFeatures = data
#            println("Header features for first file: ", headerFeatures)
        else

            ## Get the data from the file
            data = getImputedDataFromHeaderFeatFile(settings,file)

            headerFeatures = vcat(headerFeatures,data)
        end
    end

    ## Sort the features by the Kepler ID number
    headerFeatures = sortData(headerFeatures)

    combinedHeaderFeaturesFile = open(fileName,"w")


end



function sortGalex(galexFile::String)

end



function combineAllFeatures(settings)
    # Don't forget to do galex stuff here

end



function combinationDriver()

end
