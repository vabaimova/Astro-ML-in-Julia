using FITSIO
#using DataArrays, DataFrames
#using HDF5, JLD

function get_lc_segment(fitsfile::String)
    # open the fits table for reading
    f = fits_open_table(fitsfile)
    # read out the length of the arrays
    naxis2 = fits_read_keyword(f,"NAXIS2")
    length=int(naxis2[1])

    # initialize arrays to be populated
    time = Array(Float64,length)
    flux = Array(Float64,length)
    # read out the values
    # column 1 is time 
    fits_read_col(f,Float64,1,1,1,time)
    # column 8 is pdcsap_flux
    fits_read_col(f,Float64,8,1,1,flux)

    # close the fits file
    fits_close_file(f)

    # find the indices of flux that are finite
    good_inds = find(isfinite(flux))
    time = time[good_inds]
    flux = flux[good_inds]
    return time,flux
end



#function write_lc(fitsfile::String)
#    time_flux = get_lc(fitsfile)
#    file = jldopen("test.jld","w") 
#    @write file time_flux
#    close(file)
#end
