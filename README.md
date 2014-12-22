Astro-ML-in-Julia
=================

Using machine learning methods in Julia to analyze astronomical time series data.

##V: What I've done today
1. Created a helper function file and moved all helper functions from other files there

##Process
1. Galex data stuff
1. Split Data for Parallelization
1. Preprocessing
    1. more descriptive stuff here
    1. more stuff
1. Combine Features
1. Normalize and Impute Features
1. Cluster

##Keywords Extracted from Kepler FITS Files

- KEPLERID unique Kepler target identifier
- GRCOLOR [mag] \(g-r) color, SDSS bands
- JKCOLOR [mag] \(J-K) color, 2MASS bands
- GKCOLOR [mag] \(g-K) color, SDSS g - 2MASS K
- TEFF [K] Effective temperature
- LOGG [cm/s2] log10 surface gravity
- FEH [log10([Fe/H])] metallicity
- RADIUS [solar radii] stellar radius

##Things TO DO:
- Clean up the directory
- make this documentation more comprehensive
- ~~create multiplots~~
    - ~~lightcurve~~
    - ~~periodgrams~~
    - ~~phasefolded light curve~~
- finish multiplot driver
    - title the plot with KID
    - print the plots to a directory
- get membership of clustering results
- look at projections of the feature space
    - plot the targets against two features
