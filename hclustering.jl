#=
    hclustering
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

using PyCall
using PyPlot
@pyimport scipy.spatial.distance as dist
@pyimport scipy.cluster.hierarchy as hier

function getNormKidsFeats()
    tab = readcsv("norm_cross_ref_feats_plus_kid.csv",String)
    kids = tab[:,1]
    feats = float(tab[:,2:end])
    return kids,feats
end

function testing()
    kids,feats = getNormKidsFeats()
    n = integer(sqrt(length(kids)))

    sample = feats[randperm(n),:]

    dist_matrix = dist.pdist(sample,"euclidean")
    link_matrix = hier.linkage(dist_matrix)

    color_thres = 0.9*maximum(link_matrix[:,2])
    hier.dendrogram(link_matrix,show_leaf_counts=true,p=50,
        truncate_mode="level",distance_sort="ascending",leaf_font_size=13)
    xlabel("Number of Members",fontsize=15)
    ylabel("Normalized Distance Between Children Nodes",fontsize=15)
    title("Dendrogram of Hierarchical Clustering Results",fontsize=17)
end

testing()
