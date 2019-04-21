function [tcdrp,tcdrpproftype] = calctcd_rawprofs(tcdtype,temprp,depth)
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

%temprp dims: depth x # of profs

if strcmp(tcdtype,'varit')
    % - Calc vars used by both tcdrp and tcrp
    tmldrp = temprp(1,:)-0.8;
    ttcrp = tmldrp - 0.25*(tmldrp-temprp(find(depth==400),:));
end

tcdrp = nan(1,size(temprp,2));
allnancounter = 0; allnanprofidxs = [];
outofrangecounter = 0; outofrangeprofidxs = [];
nmtdeccounter = 0; nmtdecprofidxs = [];
mtdeccounter = 0; mtdecprofidxs = [];
for iprof = 1:size(temprp,2)

    if strcmp(tcdtype,'varit')
        ttcnow = ttcrp(iprof);
    elseif strcmp(tcdtype,'20degC')
        ttcnow = 20;
    end
    tempnow = temprp(:,iprof);
    valdidxs = find(~isnan(tempnow));
    tempnow = tempnow(valdidxs);
    depthnow = depth(valdidxs);

    % track profiles that are all nans
    if isempty(valdidxs)|isnan(ttcnow)
        tcdrp(iprof) = nan;
        allnancounter = allnancounter+1;
        allnanprofidxs(allnancounter)=iprof;

    % track profiles that are out of range of the isotherm of interest
    elseif (max(tempnow)<ttcnow)|(min(tempnow)>ttcnow)
        tcdrp(iprof) = nan;
        outofrangecounter = outofrangecounter+1;
        outofrangeprofidxs(outofrangecounter)=iprof;

    else 
        [~,uidxfirst] = unique(tempnow,'first');
        [utempnow uidxlast] = unique(tempnow,'last');
        tempdiff = utempnow - ttcnow;

        if any(tempdiff==0)
            exacttempuidx = find(tempdiff==0);
            tcdrp(iprof)=mean(depthnow(uidxfirst(exacttempuidx)));

        else
            warmtempuidx = find(tempdiff==min(tempdiff(tempdiff>0)));
            coldtempuidx = find(tempdiff==max(tempdiff(tempdiff<0)));
            % the following assumes that temps decrease monotonically w/ depth:
            tcdrp(iprof) = ...
                interp1([utempnow(coldtempuidx) utempnow(warmtempuidx)],...
                [depthnow(uidxfirst(coldtempuidx)) depthnow(uidxlast(warmtempuidx))],...
                ttcnow);

            % track the cases where temps DON'T decrease monot. w/ depth:
            if uidxlast(warmtempuidx)>uidxfirst(coldtempuidx)
                nmtdeccounter = nmtdeccounter+1;
                nmtdecprofidxs(nmtdeccounter)=iprof;
            else
            % track the cases where temps DO decrease monot. w/ depth:
                mtdeccounter = mtdeccounter+1;
                mtdecprofidxs(mtdeccounter)=iprof;
            end

        end

    end % end if all nans or ttcnow not in range

end % end for iprof

%----------------------
% Save out and look at counts of profile types
%----------------------
tcdrpproftype = nan(1,length(tcdrp));
tcdrpproftype(allnanprofidxs) = 1;
tcdrpproftype(outofrangeprofidxs) = 2;
tcdrpproftype(nmtdecprofidxs) = 3;
tcdrpproftype(mtdecprofidxs) = 4;
tcdrpproftype(isnan(tcdrpproftype)) = 5;

% --> Look at how many profiles are all nan,
% out of range of the corresponding isotherm,
% or non-monotonically decreasing right above/below TCD

%if strcmp(tcdtype,'varit')
%    disp('tcdrp, variable isotherm (all nan, out of range, non-monotically decreasing, monotonically decreasing)')
%elseif strcmp(tcdtype,'20degC')
%    disp('tcd20rp, 20 deg C isotherm (all nan, out of range, non-monotically decreasing, monotonically decreasing)')
%end
%[allnancounter outofrangecounter nmtdeccounter mtdeccounter]
