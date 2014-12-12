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



function combineFeatures(feat_dir::String)

    ## Get a list of all the header features files in the given directory
    featureFiles = readdir(feat_dir)

    ## Go through all the files and vcat the features of the list
    for file in featureFiles 

        ## If the file is the first features file being processed
        if file == featureFiles[1]
            ## Get the data from the file
            kids,features = getDataFromFile(feat_dir,file)
        else
            ## Get the data from the file
            tempkids,tempfeats = getDataFromFile(feat_dir,file)
            kids = vcat(kids,tempkids)
            features = vcat(features,tempfeats)
        end
    end

    ## Sort the features by the Kepler ID number
    kids,features = sortData(kids,features)
    features = imputeData(features)

    return kids,features
end



function sortGalex(galexFile::String)
    data = readcsv(galexFile,String)
    kids = data[:,end]

    lastcoloffeatures = size(data)[2]-1

    features = data[:,1:lastcoloffeatures]
    features = float(features)

    indices = sortperm(kids,by=int)
    kids = kids[indices]
    features = features[indices,:]
    return kids,features
end




function matchAndCombine(kids1,feats1,kids2,feats2)
    ## find the indices of the unique elements for kids1
    indices = map((x) -> findfirst(kids1,x),kids1)
    indices = unique(indices)
    kids1 = kids1[indices]
    feats1 = feats1[indices,:]

    ## find the indices of the unique elements for kids2
    indices = map((x) -> findfirst(kids2,x),kids2)
    indices = unique(indices)
    kids2 = kids2[indices]
    feats2 = feats2[indices,:]

    indices = map((x) -> findfirst(kids1,x),kids2)
    indices = find(indices)
    kids2 = kids2[indices]
    feats2 = feats2[indices,:]

    indices = map((x) -> findfirst(kids2,x),kids1)
    indices = find(indices)
    kids1 = kids1[indices]
    feats1 = feats1[indices,:]

    println(size(kids1))
    println(size(kids2))
    @assert(kids1 == kids2) 

    feats = hcat(feats1,feats2)
    return kids1,feats
end



function combinationDriver()
    settings = initializeSettings("CREATIVE_STATION_SETTINGS.txt","headerKeyWordList.txt",1)
    headkids,headfeats = combineFeatures(settings.header_dir)
    lckids,lcfeats = combineFeatures(settings.flc_dir)
#    galexkids,galexfeats = sortGalex("galexData.csv")

    kids,feats = matchAndCombine(headkids,headfeats,lckids,lcfeats)
#    kids,feats = matchAndCombine(kids,feats,galexkids,galexfeats)
    writecsv("/home/CREATIVE_STATION/kepler_ML/cross_ref_feats.csv",feats)
end

combinationDriver()
