% This runall_tropicalpacificonlygridded.m MATLAB script
% loads and computes variables for re-creating
% figures in Leung et al. (2019).
% It runs the following figure creation scripts...

% mainfig1andsuppfig1de.m
% mainfig2andsuppfig4.m
% mainfig3.m
% mainfig4.m
% suppfig1abc.m
% suppfig2.m
% suppfig3.m
% suppfig6.m
% suppfig8.m
% suppfig9.m

% ...Thus, creating main figures 1-4 and
% suppplementary figures 1-3,6,8-9.
% Figure creation scripts with multiple figure
% names in their titles generate all figures in the
% title, but only one at a time, which must be specified
% (e.g., to generate Supp. Fig. 4, you will have to
% go into mainfig2andsuppfig4.m and specify that you
% want Supp. Fig. 4 rather than Main Fig. 2 plotted.
% Same for mainfig1andsuppfig1de.m). 

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
% (note that "tponly" mean Tropical Pacific only)
% lon (0-360), lat, depth (m), timemoWOD, timeyrWOD
%--------------------------
load('data/WODtropicalpacificonlygridded/WOD_gridandtime_195501-201705_tponly_5deg_700m.mat','lon','lat','depth','timemoWOD','timeyrWOD');

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
% Load the following variables: 
% temp (degC), sal (psu), po2 (kPa)
%--------------------------
load('data/WODtropicalpacificonlygridded/WOD_tempsalpo2_195501-201705_tponly_5deg_700m.mat','temp','sal','po2');

%--------------------------
% Compute monthly anomalies. 
% (note that "anwod" = monthly anomalies from WOD climatology)
% Get the following variables:
% tempanwod (degC), salanwod (psu), po2anwod (kPa)
% po250 (po2 at 50 m depth, kPa),
% po2100 (po2 at 100 m depth, kPa)
%--------------------------
tempclimwod = calcWODclimatology(temp,initmonum);
tempanwod = calcmonthlyanoms(temp,tempclimwod,initmonum);

salclimwod = calcWODclimatology(sal,initmonum);
salanwod = calcmonthlyanoms(sal,salclimwod,initmonum);

po2climwod = calcWODclimatology(po2,initmonum);
po2anwod = calcmonthlyanoms(po2,po2climwod,initmonum);

po250 = squeeze(po2(:,:,find(depth==50),:));
po2100 = squeeze(po2(:,:,find(depth==100),:));

%--------------------------
% Compute tuna hypoxic depth.
% Get the following variables:
% tunahypoxicpressure (kPa),
% thd (tuna hypoxic depth, m), thdanwod (m),
%--------------------------
load('data/WODtropicalpacificonlygridded/WOD_tunahypoxicdepth_195501-201705_tponly_5deg_700m.mat','thd','thdinfo','tunahypoxicpressure');
% --> Code to calculate the variables saved in WOD_tunahypoxicdepth_195501-201705_tponly_5deg_700m.mat:
%tunahypoxicpressure = 15; % kPa
%[thd,thdinfo] = calcthd(tunahypoxicpressure,po2,depth);
%save('data/WODtropicalpacificonlygridded/WOD_tunahypoxicdepth_195501-201705_tponly_5deg_700m.mat','thd','thdinfo','tunahypoxicpressure','-v7.3');

% Use only pO2 profiles where computing thd makes most sense
% (i.e., profiles shouldn't start inside an OMZ, there
% shouldn't be highly fluctuating pO2 values that would make
% deciding where thd really is difficult, etc.)
indxs = sub2ind(size(thd),...
    thdinfo.mtabovebelowprofidxs(:,1),...
    thdinfo.mtabovebelowprofidxs(:,2),...
    thdinfo.mtabovebelowprofidxs(:,3));
newthd = nan(size(thd));
newthd(indxs) = thd(indxs);
thd = newthd; clear newthd;

[thdclimwod,~] = calcthd(tunahypoxicpressure,po2climwod,depth);
thdanwod = calcmonthlyanoms(thd,thdclimwod,initmonum);

%--------------------------
% Compute thermocline depth.
% Get the following variables:
% tcdtype (thermocline depth calculation method),
% tcd (thermocline depth, m), tcdanwod (m)
%--------------------------
load('data/WODtropicalpacificonlygridded/WOD_thermoclinedepth_195501-201705_tponly_5deg_700m.mat','tcd','tcdinfo','tcdtype');
% --> Code to calculate the variables saved in WOD_thermoclinedepth_195501-201705_tponly_5deg_700m.mat:
%tcdtype='varit';
%[tcd,tcdinfo] = calctcd(tcdtype,temp,depth);
%save('data/WODtropicalpacificonlygridded/WOD_thermoclinedepth_195501-201705_tponly_5deg_700m.mat','tcd','tcdinfo','tcdtype');

% Use only temp profiles where computing tcd makes most sense
indxs = sub2ind(size(tcd),...
    tcdinfo.mtdecprofidxs(:,1),...
    tcdinfo.mtdecprofidxs(:,2),...
    tcdinfo.mtdecprofidxs(:,3));
newtcd = nan(size(tcd));
newtcd(indxs) = tcd(indxs);
tcd = newtcd; clear newtcd;

[tcdclimwod,tcdinfo] = calctcd(tcdtype,tempclimwod,depth);
tcdanwod = calcmonthlyanoms(tcd,tcdclimwod,initmonum);

%--------------------------
% Compute correlations.
% Get the following variable:
% thdanwodvstcdanwod (correlation coefficients
% and p-values between thdanwod and tcdanwod)
%--------------------------
[thdanwodvstcdanwod.tempccmap,~,~,~,~,~,thdanwodvstcdanwod.pvalmap]=tempcorrmapnanwithintandslopeuncertainty(tcdanwod,thdanwod);

%--------------------------
% Compute means and ENSO composites.
% (note that "enoni" = monthly El Nino composite anomalies,
% "lnoni" = monthly La Nina composite anomalies)
% Get the following variables:
% tcdmean (m), tcdanwod_enoni (m), tcdanwod_lnoni (m) 
%--------------------------
tcdmean = nanmean(tcd,3);
[tcdanwodmean,tcdanwod_enoni,tcdanwod_lnoni] = calcmeanandENLNcompmaps(tcdanwod,onien,oniln);

%--------------------------
% Regrid from depth space to isopycnal space.
% (note that "rho" = variable is in isopycnal space)
% Get the following variables:
% rho (kg/m^3), po2rho (kPa),
% po2rhoanwod (kPa), tcdrho (m)
%--------------------------
load('data/WODtropicalpacificonlygridded/WOD_varsinrhospace_195501-201705_tponly_5deg_700m.mat','rhoedges','rho','po2rho','po2rhoanwod','tcdrho');
% --> Code to calculate the variables saved in WOD_varsinrhospace_195501-201705_tponly_5deg_700m.mat:
%[pottemp_refsurf,potdens_refsurf]=calcpottempanddens(temp,sal,depth,0);
%potdens_refsurfclimwod = calcWODclimatology(potdens_refsurf,initmonum);
%rhoedges = [1020:0.2:1022.8 1023:1:1026 1026.5 1027 1027.2:0.2:1028];
%rho = (rhoedges(1:end-1)+rhoedges(2:end))/2;
%po2rho = calcrhospace4d(po2,rhoedges,potdens_refsurf);
%po2rhoclimwod = calcrhospace4d(po2climwod,rhoedges,potdens_refsurfclimwod);
%po2rhoanwod = calcmonthlyanoms(po2rho,po2rhoclimwod,initmonum);
%tcdrho = calcrhofromdepth(tcd,depth,potdens_refsurf);
%save('data/WODtropicalpacificonlygridded/WOD_varsinrhospace_195501-201705_tponly_5deg_700m.mat','rhoedges','rho','po2rho','po2rhoanwod','tcdrho','-v7.3');

%--------------------------
% Count how much data there is.
% (note that "np" = number of data points,
% "tot" = total)
% Get the following variables (all w/ units of # months): 
% po2nptot, po2np_enoni, po2np_lnoni,
% thdnptot, thdnp_enoni, thdnp_lnoni,
% tcdnptot, tcdnp_enoni, tcdnp_lnoni
%--------------------------
[po2nptot,po2np_enoni,po2np_lnoni] = calcmeanandENLNcompnumpts(po2,onien,oniln);

[thdnptot,thdnp_enoni,thdnp_lnoni] = calcmeanandENLNcompnumpts(thd,onien,oniln);

[tcdnptot,tcdnp_enoni,tcdnp_lnoni] = calcmeanandENLNcompnumpts(tcd,onien,oniln);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3.) Prepare helpful things for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------
% Set up for plotting EEZ outlines. 
% Get the following variables:
% allpid, nupid, eezmap0pt25, loneez0pt25, lateez0pt25
%--------------------------

% Load in EEZ shapefile attributes to get Country-PolygonID association
wlon = 100; elon = 300; slat = -30; nlat = 30;
[s,a] = shaperead('data/EEZs/EEZshapefile/World_EEZ_v9_2016_HR_0_360','UseGeoCoords',true,'BoundingBox',[wlon,slat;elon,nlat]);
c = struct2cell(a);

allctry = c(10,:); allpid = c(1,:);

nuctries = {'Micronesia','Kiribati','Marshall Islands','Nauru','Palau','Papua New Guinea','Solomon Islands','Tuvalu'};
nupid = cell(length(nuctries),1);
for ictry = 1:length(nuctries)
    cidx = find(strcmp(allctry,nuctries{ictry}));
    nupid{ictry} = allpid(cidx);
end

% Load nc files of gridded EEZs w/ PolygonID as identifier
fnamenc = 'data/EEZs/World_EEZ_v9_2016_HR_0_360_30Nto30S_polyid_0pt25deg.nc';
ncid=netcdf.open(fnamenc,'nc_nowrite');
varid = netcdf.inqVarID(ncid,'z'); % dims: lon, lat
eezmap0pt25 = netcdf.getVar(ncid,varid,'double');,
eezmap0pt25 = eezmap0pt25'; % x = lon, y = lat
netcdf.close(ncid);
numdegreseez = 0.25;
loneez0pt25 = 0:numdegreseez:360;
lateez0pt25 = (-30:numdegreseez:30)';

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
mainfig1andsuppfig1de; % go to figurescripts/mainfig1andsuppfig1de.m to specify the figure you want to create
mainfig2andsuppfig4; % go to figurescripts/mainfig2andsuppfig4.m to specify the figure you want to create
mainfig3;
mainfig4;
suppfig1abc;
suppfig2;
suppfig3;
suppfig6;
suppfig8;
suppfig9;
