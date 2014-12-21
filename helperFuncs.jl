#=
    helperFuncs
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>
                     Mark Wells    <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

## This file contains all of the helper functions used throughout
## the project from preprocessing to clustering



## Get the normalized features and the KIDs associated with them
function getNormKidsFeats()
    tab = readcsv("norm_cross_ref_feats_plus_kid.csv",String)
    kids = tab[:,1]
    feats = float(tab[:,2:end])
    return kids,feats
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


