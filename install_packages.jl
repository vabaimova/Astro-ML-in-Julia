#=
    install_packages
    Copyright © 2014 Mark Wells <mwellsa@gmail.com>

    Distributed under terms of the MIT license.
=#

Pkg.add("HDF5")
Pkg.add("DSP")
Pkg.add("ProgressMeter")
Pkg.add("FITSIO")
Pkg.add("Stats")
Pkg.add("Match")
Pkg.add("PyCall")
Pkg.update()
