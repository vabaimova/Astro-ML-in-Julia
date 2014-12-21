#=
    hclustering
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

using PyCall
@pyimport scipy.spatial.distance as dist
@pyimport scipy.cluster.hierarchy as hier
@pyimport sklearn.neighbors.kneighbors_graph as kneighbors
@pyimport sklearn.cluster as cluster
@pyimport sklearn.metrics as metrics
using PyPlot


function getNormKidsFeats()
    tab = readcsv("norm_cross_ref_feats_plus_kid.csv",String)
    kids = tab[:,1]
    feats = float(tab[:,2:end])
    return kids,feats
end


function performCluster(features,kVal,con_matrix)
    estimator = cluster.AgglomerativeClustering(n_clusters=kVal,connectivity=con_matrix)

end


function testing()
    println("begun process")
    kids,feats = getNormKidsFeats()

    nkids = size(kids)[1]
    n =  int(sqrt(nkids))

    inds = randperm(nkids)[1:n]
    sample = feats[inds,:]


    ## Include connectivity constraints to only merge the nearest neighbors
    numNeighbors = 30
    connectivity_matrix = kneighbors(sample,numNeighbors)

    ## Cluster by scikit-learn to get the cluster membership
    estimator = cluster.AgglomerativeClustering( 


    dist_matrix = dist.pdist(sample,"euclidean")
    link_matrix = hier.linkage(dist_matrix)

    color_thres = 0.9*maximum(link_matrix[:,2])
    R = hier.dendrogram(link_matrix,show_leaf_counts=true,p=50,
        truncate_mode="level",distance_sort="ascending",leaf_font_size=13)
    xlabel("Number of Members",fontsize=15)
    ylabel("Normalized Distance Between Children Nodes",fontsize=15)
    title("Dendrogram of Hierarchical Clustering Results",fontsize=17)

    a=figure()
    leaf_counts = R["ivl"]
    ## deal with items with ()
    pinds = find(map((x) -> contains(x,"("),leaf_counts))
    for index in pinds
        leaf_counts[index] = leaf_counts[index][2:end-1]
    end

    lN = size(leaf_counts)[1]
    labels = int(linspace(1,lN,lN))

    leaf_counts = int(leaf_counts)

    bar(labels,leaf_counts)
    xlabel("Cluster",fontsize=15)
    ylabel("Number of Members",fontsize=15)
    title("Membership of Hierarchical Clustering",fontsize=17)

    ## For future reference
    ## leaves_list returns a list of leaf ids 
#    println("Leaves list: ", hier.leaves_list(link_matrix))

    

end

#testing()
