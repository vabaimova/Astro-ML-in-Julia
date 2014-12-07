#=
    splitDataForParallelization
    Copyright © 2014 Vera Abaimova <stormseecker@gmail.com>

    Distributed under terms of the MIT license.
=#

## This function takes a directory and a number of splits as parameters
## It runs dir_KIDs() to determine the number of unique Kepler IDs
## and then splits that list of ID numbers into the number of splits passed
## as the parameter
## Cretes text files containing the Kepler IDs for each group


## This function takes a file that contains the Kepler IDs to be grouped
## And then creates a text file that contains the full path for each file
## for each of the assigned Kepler IDs 
## It also creates a text file that contains the full path for only
## the first file that is for a specific ID


# At some point use cp(source,destination) to copy files
