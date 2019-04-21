function [pottemp,potdens] = calcpottempanddens(temp,sal,depth,refdepth)
% - Calculate potential density from in situ temp and salinity
pottemp = nan(size(temp));
potdens = nan(size(temp));
for ilon = 1:size(temp,1)
    for ilat = 1:size(temp,2)
        pottemp(ilon,ilat,:,:) = sw_ptmp(squeeze(sal(ilon,ilat,:,:)),squeeze(temp(ilon,ilat,:,:)),depth,refdepth);
        potdens(ilon,ilat,:,:) = sw_dens(squeeze(sal(ilon,ilat,:,:)),squeeze(pottemp(ilon,ilat,:,:)),refdepth);
    end
end
