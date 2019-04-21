function [tcd,tcdinfo] = calctcd(tcdtype,temp,depth)
%----------------------
% Calculate thermocline depths
%----------------------
% Variable representative isotherm:
% “This method is a modification of Wang et al. (2000).
% The isotherm representing the thermocline is defined as
% thermocline temperature TT = T(MLD) – 0.25 [T(MLD) – T(400 m)],
% where the temperature at the base of the mixed layer T(MLD) = SST – 0.8."
% (Fiedler 2010)
% OR 20 degC isotherm
% --> tcdtype is either 'varit' or '20degC'
% This script works when temp is 4D (x,y,z,t) or 3D (x,y,z).

if strcmp(tcdtype,'varit')
    tmldnow = temp(:,:,1,:)-0.8;
    ttcvarit = tmldnow - 0.25*(tmldnow-temp(:,:,find(depth==400),:));
    ttcvarit = squeeze(ttcvarit);
end

tcd = nan(size(squeeze(temp(:,:,1,:))));
allnancounter = 0; tcdinfo.allnanprofidxs = [];
outofrangecounter = 0; tcdinfo.outofrangeprofidxs = [];
nmtdeccounter = 0; tcdinfo.nmtdecprofidxs = [];
mtdeccounter = 0; tcdinfo.mtdecprofidxs = [];
for ilon = 1:size(tcd,1)
    for ilat = 1:size(tcd,2)
        for itime = 1:size(tcd,3)

            if strcmp(tcdtype,'varit')
                ttcnow = ttcvarit(ilon,ilat,itime);
            elseif strcmp(tcdtype,'20degC')
                ttcnow = 20;
            end
            tempnow = squeeze(temp(ilon,ilat,:,itime));
            valdidxs = find(~isnan(tempnow));
            tempnow = tempnow(valdidxs);
            depthnow = depth(valdidxs); 

            if isempty(valdidxs)|isnan(ttcnow)
                tcd(ilon,ilat,itime) = nan;
                allnancounter = allnancounter+1;
                tcdinfo.allnanprofidxs(allnancounter,:)=[ilon ilat itime];
 
            elseif (max(tempnow)<ttcnow)|(min(tempnow)>ttcnow)
                tcd(ilon,ilat,itime) = nan;
                outofrangecounter = outofrangecounter+1;
                tcdinfo.outofrangeprofidxs(outofrangecounter,:)=[ilon ilat itime];

            else
                [~,uidxfirst] = unique(tempnow,'first');
                [utempnow uidxlast] = unique(tempnow,'last');
                tempdiff = utempnow - ttcnow;

                if any(tempdiff==0) 
                    exacttempuidx = find(tempdiff==0);
                    tcd(ilon,ilat,itime)=mean(depthnow(uidxfirst(exacttempuidx)));

                else
                    warmtempuidx = find(tempdiff==min(tempdiff(tempdiff>0))); 
                    coldtempuidx = find(tempdiff==max(tempdiff(tempdiff<0)));
                    % the following assumes that temps decrease monotonically w/ depth:
                    tcd(ilon,ilat,itime) = ...
                        interp1([utempnow(coldtempuidx) utempnow(warmtempuidx)],...
                        [depthnow(uidxfirst(coldtempuidx)) depthnow(uidxlast(warmtempuidx))],...
                        ttcnow);

                    % track the cases where temps DON'T decrease monot. w/ depth:
                    if uidxlast(warmtempuidx)>uidxfirst(coldtempuidx)
                        nmtdeccounter = nmtdeccounter+1;
                        tcdinfo.nmtdecprofidxs(nmtdeccounter,:)=[ilon ilat itime];
                    else
                        mtdeccounter = mtdeccounter+1;
                        tcdinfo.mtdecprofidxs(mtdeccounter,:)=[ilon ilat itime];
                    end

                end

            end % end if all nans or ttcnow not in range
        end % end time loop
    end % end lat loop
end % end lon loop

% --> Look at how many profiles are all nan, out of range of the corresponding isotherm,
% or non-monotonically decreasing right above/below TCD

%if strcmp(tcdtype,'varit')
%    disp('tcd, variable isotherm (all nan, out of range, non-monotonically decreasing, monotonically decreasing)')
%elseif strcmp(tcdtype,'20degC')
%    disp('tcd20, 20 deg C isotherm (all nan, out of range, non-monotonically decreasing, monotonically decreasing)')
%end
%[allnancounter outofrangecounter nmtdeccounter mtdeccounter]
