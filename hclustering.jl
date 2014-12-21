#=
    hclustering
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

using PyCall
@pyimport scipy.spatial.distance as dist
@pyimport scipy.cluster.hierarchy as hier
@pyimport sklearn.neighbors as neighbors
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

    predictedLabels = estimator[:fit_predict](features)
    return predictedLabels

end


function evaluateCluster(features,predictedLabels)
#    println("sample size: ",size(features)[1])
    sample = sqrt(size(features)[1])
    sampleSize = int(sample)
#    println("sample size for silhouette: ",sampleSize, typeof(sampleSize))

    score = metrics.silhouette_score(features,predictedLabels,sample_size=sampleSize)

    return score

end


function testVariousK(features,con_matrix)
    ## Want a range from from 10 to 30 inclusive
    kList = range(10,1,21)
    scores = Array(Float64,length(kList))

    ## Perform clustering on a variety of k values
    maxscore = 0.0
    bestK = 0

    for i = 1:length(kList)
        labels = performCluster(features,kList[i],con_matrix)
        score = evaluateCluster(features,labels)
        scores[i] = score
        if score > maxscore
            maxscore = score
            println("Current max score: ", maxscore)
            bestK = kList[i] 
        end
    end

    println("Now writing silhouette scores file")
    sil_scores_file_name = "/home/CREATIVE_STATION/Astro-ML-in-Julia/sil_scores.csv"
    writecsv(sil_scores_file_name,scores)

    println("Now writing kList file")
    kList_file_name = "/home/CREATIVE_STATION/Astro-ML-in-Julia/kList.csv"
    writecsv(kList_file_name,kList)

    return bestK

end


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


function testing()
    println("begun process")
    kids,feats = getNormKidsFeats()

    nkids = size(kids)[1]
    #n =  int(sqrt(nkids))
#    n = int(nkids/50)
    n = nkids
    println("The overall sample size is: ", n)

    inds = randperm(nkids)[1:n]
    sample = feats[inds,:]


    ## Include connectivity constraints to only merge the nearest neighbors
    numNeighbors = 30
    connectivity_matrix = neighbors.kneighbors_graph(sample,numNeighbors)

    ## Test to see which k value is the best
    bestK = testVariousK(sample,connectivity_matrix)
    println("best k: ", bestK)

    ## Get the labels of the best k
    labels = performCluster(sample,bestK,connectivity_matrix)


    dist_matrix = dist.pdist(sample,"euclidean")
    link_matrix = hier.linkage(dist_matrix)

    color_thres = 0.9*maximum(link_matrix[:,2])
    R = hier.dendrogram(link_matrix,show_leaf_counts=true,p=50,
        truncate_mode="level",distance_sort="ascending",leaf_font_size=13)
    xlabel("Number of Members",fontsize=15)
    ylabel("Normalized Distance Between Children Nodes",fontsize=15)
    title("Dendrogram of Hierarchical Clustering Results",fontsize=17)

    createBarGraph(labels)

#    a=figure()
#    leaf_counts = R["ivl"]
#    ## deal with items with ()
#    pinds = find(map((x) -> contains(x,"("),leaf_counts))
#    for index in pinds
#        leaf_counts[index] = leaf_counts[index][2:end-1]
#    end
#
#    lN = size(leaf_counts)[1]
#    labels = int(linspace(1,lN,lN))
#
#    leaf_counts = int(leaf_counts)
#
#    bar(labels,leaf_counts)
#    xlabel("Cluster",fontsize=15)
#    ylabel("Number of Members",fontsize=15)
#    title("Membership of Hierarchical Clustering",fontsize=17)

    ## For future reference
    ## leaves_list returns a list of leaf ids 
#    println("Leaves list: ", hier.leaves_list(link_matrix))

    

end

testing()
