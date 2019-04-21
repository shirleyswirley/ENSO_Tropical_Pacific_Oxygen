% This runall_globalgridded.m MATLAB script
% loads and computes variables for re-creating
% a figure in Leung et al. (2019).
% It runs the following figure creation script...

% suppfig5.m

% ...Thus, creating supplementary figure 5.

clear all;
addpath(genpath('.'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.) Define and load spatial grid, time variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
begdate = datetime(1955,1,1); % beginning date of WOD dataset
enddate = datetime(2017,5,1); % end date of WOD dataset
numdegres = 5; % horiz grid resolution in degrees
initmonum = 1; % WOD dataset's initial month (jan=1,feb=2,etc.)

%--------------------------
% Load the following space/time grid variables:
% (note that "global" mean Tropical Pacific only)
% lon (0-360), lat, depth (m), timemoWOD, timeyrWOD
%--------------------------
load('data/WODglobalgridded/WOD_gridandtime_195501-201705_global_5deg_700m.mat','lon','lat','depth','timemoWOD','timeyrWOD');

%--------------------------
% Load/calculate the following ENSO index (ONI) variables:
% oni (degC), onitime,
% onien (0 = non-El Nino month, 1 = El Nino month),
% oniln (0 = non-La Nina month, 1 = La Nina month)
%--------------------------
loadoni;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2.) Load and/or compute gridded variables from WOD data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------
% Load the following variable: 
% po2 (kPa)
%--------------------------
load('data/WODglobalgridded/WOD_tempsalpo2_195501-201705_global_5deg_700m.mat','po2');

%--------------------------
% Compute monthly anomalies. 
% (note that "anwod" = monthly anomalies from WOD climatology)
% Get the following variable:
% po2anwod (kPa)
%--------------------------
po2climwod = calcWODclimatology(po2,initmonum);
po2anwod = calcmonthlyanoms(po2,po2climwod,initmonum);

%--------------------------
% Regrid from depth space to isopycnal space.
% (note that "rho" = variable is in isopycnal space)
% Get the following variables:
% rho (kg/m^3), po2rho (kPa), po2rhoanwod (kPa)
%--------------------------
load('data/WODglobalgridded/WOD_varsinrhospace_195501-201705_global_5deg_700m.mat','rhoedges','rho','po2rho','po2rhoanwod');
% --> Code to calculate the variables saved in WOD_varsinrhospace_195501-201705_global_5deg_700m.mat:
%[~,potdens_refsurf]=calcpottempanddens(temp,sal,depth,0);
%potdens_refsurfclimwod = calcWODclimatology(potdens_refsurf,initmonum);
%rhoedges = [1023 1024 1025];
%rho = (rhoedges(1:end-1)+rhoedges(2:end))/2;
%po2rho = calcrhospace4d(po2,rhoedges,potdens_refsurf);
%po2rhoclimwod = calcrhospace4d(po2climwod,rhoedges,potdens_refsurfclimwod);
%po2rhoanwod = calcmonthlyanoms(po2rho,po2rhoclimwod,initmonum);
%save('data/WODglobalgridded/WOD_varsinrhospace_195501-201705_global_5deg_700m.mat','rhoedges','rho','po2rho','po2rhoanwod','-v7.3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3.) Prepare helpful things for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------
% Shift axes for proper plotting w/ pcolor
% (essentially defines bottom/left border of grid cell).
% Get the following variables:
% plon, plat, pdepth (m), prho (kg/m^3)
%--------------------------
plat = lat-numdegres/2;
plon = lon-numdegres/2;
pdepth = [(depth(1)-depth(2))/2; depth(2:end)-diff(depth/2)];
prho = rhoedges(1:end-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4.) Create and save figures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
suppfig5;
