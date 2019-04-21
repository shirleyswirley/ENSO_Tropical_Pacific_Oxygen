function varinclim = calcWODclimatology(varin,initmonum)
% - Calculates seasonal cycle/climatology of
% 3D (lon,lat,time) or 4D (lon,lat,depth,time)
% monthly variables.
% initmonum refers to the month number in which
% the dataset starts (jan=1,feb=2,etc.)

if ndims(varin)==4
    varinclim = nan(size(varin,1),size(varin,2),size(varin,3),12);
    for imonth = [initmonum:12 initmonum:(initmonum-1)]
        montharrnow = (imonth-initmonum+1):12:size(varin,4);
        montharrnow = montharrnow(montharrnow>0);
        varinclim(:,:,:,imonth) = nanmean(varin(:,:,:,montharrnow),4);
    end
elseif ndims(varin)==3
    varinclim = nan(size(varin,1),size(varin,2),12);
    for imonth = [initmonum:12 initmonum:(initmonum-1)]
        montharrnow = (imonth-initmonum+1):12:size(varin,3);
        montharrnow = montharrnow(montharrnow>0);
        varinclim(:,:,imonth) = nanmean(varin(:,:,montharrnow),3);
    end
end
