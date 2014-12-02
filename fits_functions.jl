using FITSIO
using DataArrays, DataFrames
#using HDF5, JLD

function get_lc(fitsfile::String)
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

    # hcat and convert
    time_flux = DataArray([time flux])
    # replace Julia's NaN with DataArray's NA
    where_nan = findin(time_flux,NaN)
    time_flux[where_nan] = NA
    return time_flux
end

function meanNorm(darray::DataArray)
    norm = mean(dropna(darray))
    norm_array = darray/norm
    return norm_array
end

#function write_lc(fitsfile::String)
#    time_flux = get_lc(fitsfile)
#    file = jldopen("test.jld","w") 
#    @write file time_flux
#    close(file)
#end
