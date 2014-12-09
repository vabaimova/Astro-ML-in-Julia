#=
    combineFeatures
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>
                     Mark Wells    <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

include("preProcessingMain.jl")
using PyCall
@pyimport sklearn.preprocessing as preprocessing



function imputeData(data)
    ## Create imputer
    imp = preprocessing.Imputer(missing_values=-9999,strategy="median",axis=0)
    ## Replace the missing values (represented by -9999)
    ## with the median of the column
    imputedData = imp[:fit_transform](data)
    
    return imputedData

end



function sortData(kids,features)
    ## Sort by Kepler ID number to make future merging easier
    ## Get the sorted indices for the first column after transforming the
    ## Kepler ID strings to integers
    indices = sortperm(kids,by=int)

    ## Reindex features with the new sorted indices
    features = features[indices,:]

    ## Reindex the kids
    kids = kids[indices]

    return kids,features

end



function getDataFromFile(dir::String,file::String)

    ## Make sure the file name has the full path
    file = dir * file
#    println(file)
    
    data = readcsv(file,ASCIIString)
    kids = data[:,1]
#    println("kids=",kids[1])
    data = data[:,2:end]
#    println(typeof(data[1]))
#    println(data[1])
    
    return kids,data

end



function combineFeatures(feat_dir::String,fileToWriteName::String)

    ## Get a list of all the header features files in the given directory
    featureFiles = readdir(feat_dir)

    ## Go through all the files and vcat the features of the list
    for file in featureFiles 

        ## If the file is the first features file being processed
        if file == featureFiles[1]

            ## Get the data from the file
            kids,data = getDataFromFile(feat_dir,file)

            ## Create an array to hold all the header features
            ## and add the first batch of data so that we can perform vcat()
            features = data
#            println("Header features KID: ", kids[1])
#            println("Header features for first file: ", headerFeatures[1,:])
        else

            ## Get the data from the file
            kids,data = getDataFromFile(feat_dir,file)

            features = vcat(features,data)
        end
    end

#    println("=====================================")

    ## Sort the features by the Kepler ID number
    kids,features = sortData(kids,features)
    features = imputeData(features)


#    println("Sorted header features KID: ", kids[1])
#    println("Sorted header features: ", headerFeatures[1,:])

    #combinedHeaderFeaturesFile = open(fileToWriteName,"w+")

    #println(combinedHeaderFeaturesFile)
    ## Write the file
    #writecsv(combinedHeaderFeaturesFile,headerFeatures)
    writecsv(fileToWriteName,features)

end



function sortGalex(galexFile::String)

end



function combineAllFeatures(settings)
    # Don't forget to do galex stuff here

end



function combinationDriver()


end
