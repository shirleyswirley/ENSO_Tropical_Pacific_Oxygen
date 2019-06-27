# ENSO_Tropical_Pacific_Oxygen

The code in this repository reproduces figures and tables in the following paper:
<br>Leung, S., Thompson, L., McPhaden, M. J., & Mislan, K. A. S. (2019). ENSO drives near-surface oxygen and vertical habitat variability in the tropical Pacific. <i>Environmental Research Letters.</i>

Please cite the above paper and the code itself (see here: https://doi.org/10.5281/zenodo.2648131) if you use any of it.

This code was written using MATLAB 9.0.0.341360 (R2016a).

How to run:
1. Download this repository.
2. Download data from http://doi.org/10.5281/zenodo.2648124. Place it in a folder called "data" within this downloaded repository's folder.
3. To recreate the figures and tables from the above paper, simply start up MATLAB, make sure your current working directory is the downloaded repository's folder, and run the following scripts: runall_globalgridded.m, runall_tropicalpacificonly.m, and runall_rawprofs.m (order doesn't matter). Each of these scripts creates and saves/prints out a different subset of the figures and tables in the paper. Read the comment blocks at the top of each script to see which figures/tables each script will generate.
