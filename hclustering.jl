#=
    hclustering
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

using PyCall
@pyimport scipy.spatial.distance as dist
@pyimport scipy.cluster.hierarchy as hier

function getNormKidsFeats()
    tab = readcsv("norm_cross_ref_feats.csv",String)
    kids = tab[:,1]
    feats = float(tab[:,2:end])
    return kids,feats
end

function testing()
    kids,feats = getNormKidsFeats()
    dist_matrix = dist.pdist(feats,"euclidean")
    link_matrix = hier.linkage(dist_matrix)
    hier.dendogram(link_matrix)
end

testing()
