# ENSO_Tropical_Pacific_Oxygen

The code in this repository reproduces figures and tables in the following paper:
<br>Leung et al. (2019).

Please cite the above paper if you use this code.

This code was written using MATLAB 9.0.0.341360 (R2016a).

How to run:
1. Download this repository.
2. Download data from http://doi.org/10.5281/zenodo.2648124. Place it in a folder called "data" within this downloaded repository's folder.
3. To recreate the figures and tables from the above paper, simply start up MATLAB, make sure your current working directory is the downloaded repository's folder, and run the following scripts: runall_globalgridded.m, runall_tropicalpacificonly.m, and runall_rawprofs.m (order doesn't matter). Each of these scripts creates and saves/prints out a different subset of the figures and tables in the paper. Read the comment blocks at the top of each script to see which figures/tables each script will generate.
