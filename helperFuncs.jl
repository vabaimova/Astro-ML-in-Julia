#=
    helperFuncs
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>
                     Mark Wells    <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

## This file contains all of the helper functions used throughout
## the project from preprocessing to clustering

using FITSIO

#############################################################
## Get desired data (not directly related to a singular purpose)


## Get the KIDs that are found in the directory of FITS files
function dir_KIDs(dir_name::String)
    #=
    this function will return all the KIDs that are within the given directory
    uses the filenames (assumes the form of kplr#########-#############_llc.fits)
    =#

    println("Reading directory: " * dir_name)

    #returns all the files from dir_name
    fits_files = readdir(dir_name)

    #initialize an empty string array
    kids = String[]
    #this will be used to compare kids
    temp_kid = ""

    for file in fits_files
        #extract the 9 digit id number
        try kid = file[5:13]                    
            
            if kid != temp_kid
                append!(kids,[kid])
            end
            temp_kid = kid
        catch
            println("Unexpected file in source directory: ",file)
        end
    end

    println("Discovered ",length(kids)," unique Kepler ID numbers")
    return kids
end


## This function takes a directory name and a Kepler ID number
## and returns the first file instance for that KID
function firstInstOfKID(dirName::String, kid::String)

    ## Get the file names from the given directory
    files = readdir(dirName)

    ## Find the first instance of the Kepler ID in the file directory
    instance = files[findfirst(map((x) -> contains(x,kid),files))]
    
    return instance

end


## Get the features from the file indicated
function getFeatures(file::String)
    table = readcsv(file,String)
    kids = table[:,1]
    feats = float(table[:,2:end])
    return kids,feats
end


## Get data from a file, specifically when combining it 
function getDataFromFile(dir::String,file::String)

    ## Make sure the file name has the full path
    file = dir * file
#    println(file)
    
    println("reading: ",file)
    data = readcsv(file,ASCIIString)
    kids = data[:,1]
#    println("kids=",kids[1])
    data = data[:,2:end]
#    println(typeof(data[1]))
#    println(data[1])
    
    return kids,data

end


##############################################################
## Process and Sort Data

## Impute data to handle missing values
function imputeData(data)
    ## Create imputer
    imp = preprocessing.Imputer(missing_values=-9999,strategy="median",axis=0)
    ## Replace the missing values (represented by -9999)
    ## with the median of the column
    imputedData = imp[:fit_transform](data)
    
    return imputedData

end


## Sort the data by Kepler ID number
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


## Sort the Galex data by Kepler ID
function sortGalex(galexFile::String)
    data = readcsv(galexFile)

    kids = int(data[:,end])
    kids = map((x) -> lpad(x,9,"0"),kids)

    features = data[:,1]
    features = float(features)

    indices = sortperm(kids,by=int)
    kids = kids[indices]
    features = features[indices,:]
    return kids,features
end



##############################################################
## Testing Directories

## Test to see if a directory exists
function test_fits_dir(dir::String)
    #=
    Produces a warning message if directory does not exist
    name will be used to generate warning message
    =#
    try readdir(dir)
        println("Found FITs directory!")
    catch
        println("Please check SETTINGS.txt file")
        ## this will halt execution of the entire program with a helpful message
        throw("Could not find FITs directory!")
    end
end


## Make a directory if one by that name is not present
function make_if_needed(dir::String)
    #=
    Produces a warning message if directory does not exist
    name will be used to generate warning message
    =#
    try readdir(dir)
    catch
        mkdir(dir)
    end
end
  

##############################################################
## Graphing

## Create a bar graph indicating the cluster membership
function createBarGraph(labels)
    figure()
    ## Get the unique label names for the x-axis
    labelNames = unique(labels)
    labelNames = sort(labelNames)
    println("length of labelNames: ", length(labelNames))
    println("labelNames: ", labelNames)

    ## Get the counts for each label 
    counts = hist(labels,length(labels))[2]
    println("size of counts: ", length(counts))
    println("counts: ", counts)

    ## Graph it
    width = .9 
    bar(labelNames-width/2,counts,width=width)

end


