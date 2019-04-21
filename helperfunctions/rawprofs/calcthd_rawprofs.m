function [thdrp,thdrpproftype,thdrpenufdata] = calcthd_rawprofs(tunahypoxicpressure,po2rp,depth)
%----------------------
% Calculate tuna hypoxic depths
%----------------------
thdrp = nan(1,size(po2rp,2));
allnancounter = 0; allnanprofidxs = [];
outofrangecounter = 0; outofrangeprofidxs = [];
nmtdecabovecounter = 0; nmtdecaboveprofidxs = [];
nmtdecbelowcounter = 0; nmtdecbelowprofidxs = [];
mtabovebelowcounter = 0; mtabovebelowprofidxs = [];
for iprof = 1:size(po2rp,2)
    po2now = po2rp(:,iprof);
    valdidxs = find(~isnan(po2now));
    po2now = po2now(valdidxs);
    depthnow = depth(valdidxs);

    % track profiles that are all nans
    if isempty(valdidxs)
        allnancounter=allnancounter+1;
        allnanprofidxs(allnancounter)=iprof;

    % track profiles that are out of range of the pressure of interest
    elseif (max(po2now)<=tunahypoxicpressure)|(min(po2now)>=tunahypoxicpressure)
        outofrangecounter=outofrangecounter+1;
        outofrangeprofidxs(outofrangecounter)=iprof;

    else
        if any(po2now==tunahypoxicpressure)
            exactpo2idx = find(po2now==tunahypoxicpressure);
            thdrp(iprof)=mean(depthnow(exactpo2idx));
        else
            didxdeep = find(po2now<tunahypoxicpressure,1);

            if didxdeep==1
            % track the case in which you have a strangely tiny
            % po2 pressure < tunahypoxicpressure at the top depth;
            % i.e., either start measuring in mid depth of OMZ or you
            % have erroneously small po2 pressure at/near the surface
            % (very rare, but saw this in some profiles)
                nmtdecabovecounter=nmtdecabovecounter+1;
                nmtdecaboveprofidxs(nmtdecabovecounter)=iprof;
            else
            % the following is calculated when o2 decreases monotonically (or at least
            % oscillates w/o reaching down to tunahypoxicpressure) w/ depth RIGHT above thd:
                thdrp(iprof) = ...
                    interp1([po2now(didxdeep-1) po2now(didxdeep)],...
                    [depthnow(didxdeep-1) depthnow(didxdeep)],...
                    tunahypoxicpressure);
            end % end if didxdeep==1

            % track the cases where po2 DOESN'T decrease w/ depth RIGHT below thd:
            if (length(po2now)>didxdeep)&(po2now(didxdeep+1)>po2now(didxdeep))
                nmtdecbelowcounter=nmtdecbelowcounter+1;
                nmtdecbelowprofidxs(nmtdecbelowcounter)=iprof;
            % track the cases where po2 decreases w/ depth RIGHT ABOVE AND BELOW thd:
            elseif (didxdeep~=1)&(length(po2now)>didxdeep)&(po2now(didxdeep+1)<po2now(didxdeep))
                mtabovebelowcounter=mtabovebelowcounter+1;
                mtabovebelowprofidxs(mtabovebelowcounter)=iprof;
            end

        end % end if po2now==tunahypoxicpressure exactly
    end % end if all nans or tunahypoxicpressure not in range
end % end iprof loop

%----------------------
% Calculate non-interpolated tuna hypoxic depths
%----------------------
% --> thdnirp = non-interpolated
% NOTE: don't interpolate b/c po2 profiles could be
% messy/non-monotonic --> thdnirp is thus a
% discrete estimate gridded to only a handful
% of possible depths
thdnirp = nan(1,size(po2rp,2));
for iprof = 1:size(po2rp,2)
    po2now = po2rp(:,iprof);
    valdidxs = find(~isnan(po2now));
    if isempty(valdidxs)
        thdnirp(iprof) = nan;
    elseif (max(po2now)<=tunahypoxicpressure)|(min(po2now)>=tunahypoxicpressure)
        thdnirp(iprof) = nan;
    else
        didx = find(po2now<tunahypoxicpressure,1);
        thdnirp(iprof) = depth(didx);
    end
end % end iprof for loop

%----------------------
% Save out and look at counts of profile types
%----------------------
thdrpproftype = nan(1,length(thdrp));
thdrpproftype(allnanprofidxs) = 1;
thdrpproftype(outofrangeprofidxs) = 2;
thdrpproftype(nmtdecaboveprofidxs) = 3;
thdrpproftype(nmtdecbelowprofidxs) = 4;
% the following b/c nmtdecaboveprofidxs and nmtdecbelowprofidxs have overlap:
thdrpproftype(nmtdecbelowprofidxs...
    (ismember(nmtdecbelowprofidxs,nmtdecaboveprofidxs))) = 5;
thdrpproftype(mtabovebelowprofidxs) = 6;
thdrpproftype(isnan(thdrpproftype)) = 7;

thdrpenufdata = nan(1,length(thdrp));
% Criteria 1 is whether thd non-interp and thd interp are within 150 m of each other
thdrpenufdata((thdnirp - thdrp)>150) = 1;
% Criteria 2 is whether there are more than 2 datapoints within 200 m of thd interp
% (i.e., 2 datapts centered on thd, max 400 m apart) 
enufdatanpnow = nan(1,length(thdrp));
for iprof = 1:length(thdrp)
    po2now = po2rp(:,iprof);
    thdnow = thdrp(iprof);
    enufdatanpnow(iprof) = sum(~isnan(po2now(depth>(thdnow-200)&depth<(thdnow+200))));
end
thdrpenufdata(enufdatanpnow<=2 & ~isnan(thdrp)) = 2;
% Criteria 3 is when both Criteria 1 and 2 are true
thdrpenufdata( ...
    (thdnirp - thdrp)>150 & ...
    enufdatanpnow<=2 & ~isnan(thdrp)) = 3;
% --> Any profiles that are not in the above categories
% (i.e., coded with 1, 2, or 3) have enough data
% to calculate thd.

% --> Now look at how many profiles are all nan,
% out of range of the tuna hypoxic pressure,
% or monotonically decreasing right above/below THD

%disp('thdrp (all nan, out of range, non-monotonically decreasing above, non-monotonically decreasing below, monotonically decreasing above and below)')
%[allnancounter outofrangecounter nmtdecabovecounter nmtdecbelowcounter mtabovebelowcounter]
