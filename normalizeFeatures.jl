#=
    normalizeFeatures
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.

    This will define a set of functions that will be used to normalize the
    the feature space.
=#

function getFeatures(file::String)
    table = readcsv(file,String)
    kids = table[:,1]
    feats = float(table[:,2:end])
    return kids,feats
end



function rescaleFeat(array::Array{Float64})
    retval = (array - minimum(array))/(maximum(array)-minimum(array))
    return retval
end



function createNormalizedTable()
    kids,feats = getFeatures("cross_ref_feats_plus_kid.csv")

    numSamps = size(feats)[1]
    numFeats = size(feats)[2]
    rfeats = Array(Float64,numSamps,numFeats)
    for i = 1:numFeats
        rfeats[:,i] = rescaleFeat(feats[:,i]) 
    end

    table = hcat(kids,rfeats)
    println(size(table))
    writecsv("norm_cross_ref_feats_plus_kid.csv",table)
end

createNormalizedTable()
