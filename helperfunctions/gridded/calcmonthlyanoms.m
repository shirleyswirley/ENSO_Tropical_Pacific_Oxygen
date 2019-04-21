function varinanom = calcmonthlyanoms(varin,varinclim,initmonum)
% - Calculates anomalies from the seasonal cycle/climatology
% of 3D (lon,lat,time) or 4D (lon,lat,depth,time)
% monthly variables.
% initmonum refers to the month number in which
% the dataset starts (jan=1,feb=2,etc.).

varinanom = nan(size(varin));
if ndims(varin)==4
    for imonth = [initmonum:12 initmonum:(initmonum-1)]
        montharrnow = (imonth-initmonum+1):12:size(varin,4);
        montharrnow = montharrnow(montharrnow>0);
        varinanom(:,:,:,montharrnow) = ...
            varin(:,:,:,montharrnow) - ...
            repmat(varinclim(:,:,:,imonth),1,1,1,size(varin(:,:,:,montharrnow),4));
    end
elseif ndims(varin)==3
    for imonth = [initmonum:12 initmonum:(initmonum-1)]
        montharrnow = (imonth-initmonum+1):12:size(varin,3);
        montharrnow = montharrnow(montharrnow>0);
        varinanom(:,:,montharrnow) = ...
            varin(:,:,montharrnow) - ...
            repmat(varinclim(:,:,imonth),1,1,size(varin(:,:,montharrnow),3)); 
    end
end
