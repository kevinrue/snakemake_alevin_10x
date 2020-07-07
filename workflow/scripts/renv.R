# issue installing Rhdf5lib from source
# renv supports configure args: https://rstudio.github.io/renv/reference/install.html
# Could that be the solution?
# installation of RNetCDF may require us to set include paths for netcdf
# configure.args = c(RNetCDF = "--with-netcdf-include=/usr/include/udunits2"))
# options(configure.args = configure.args)

options(Ncpus = 2) # TODO: parameterize
options(renv.consent = TRUE)

renv::init()
