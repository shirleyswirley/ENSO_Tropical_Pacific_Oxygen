function [thd,thdinfo] = calcthd(tunahypoxicpressure,po2,depth)
%----------------------
% Calculate tuna hypoxic depths
%----------------------
thd = nan(size(squeeze(po2(:,:,1,:))));
allnancounter = 0; thdinfo.allnanprofidxs = [];
outofrangecounter = 0; thdinfo.outofrangeprofidxs = [];
nmtdecabovecounter = 0; thdinfo.nmtdecaboveprofidxs = [];
nmtdecbelowcounter = 0; thdinfo.nmtdecbelowprofidxs = [];
mtabovebelowcounter = 0; thdinfo.mtabovebelowprofidxs = [];
for ilon = 1:size(thd,1)
    for ilat = 1:size(thd,2)
        for itime = 1:size(thd,3)
            po2now = squeeze(po2(ilon,ilat,:,itime));
            valdidxs = find(~isnan(po2now));
            po2now = po2now(valdidxs);
            depthnow = depth(valdidxs);

            if isempty(valdidxs)
                allnancounter = allnancounter + 1;
                thdinfo.allnanprofidxs(allnancounter,:) = [ilon ilat itime];
            elseif (max(po2now)<=tunahypoxicpressure)|(min(po2now)>=tunahypoxicpressure)
                outofrangecounter = outofrangecounter + 1;
                thdinfo.outofrangeprofidxs(outofrangecounter,:) = [ilon ilat itime];
            else
                if any(po2now==tunahypoxicpressure)
                    exactpo2idx = find(po2now==tunahypoxicpressure);
                    thd(ilon,ilat,itime) = mean(depthnow(exactpo2idx));
                else
                    didxdeep = find(po2now<tunahypoxicpressure,1);

                    if didxdeep==1
                    % case in which you have a strangely tiny po2 pressure < tunahypoxicpressure
                    % at the top depth; i.e., either started measuring in mid depth
                    % of OMZ or you have erroneously small po2 pressure at/near the surface
                    % (very rare, but saw this in some profiles)
                        nmtdecabovecounter = nmtdecabovecounter+1;
                        thdinfo.nmtdecaboveprofidxs(nmtdecabovecounter,:) = [ilon ilat itime];

                    else
                    % the following is calculated when po2 decreases monotonically (or at least
                    % oscillates w/o reaching down to tunahypoxicpressure) w/ depth RIGHT ABOVE thd:
                        thd(ilon,ilat,itime) = ...
                            interp1([po2now(didxdeep-1) po2now(didxdeep)],...
                            [depthnow(didxdeep-1) depthnow(didxdeep)],...
                            tunahypoxicpressure);
                    end
     
                    % count the cases where po2 DOESN'T decrease w/ depth RIGHT BELOW thd:
                    if (length(po2now)>didxdeep)&(po2now(didxdeep+1)>po2now(didxdeep))
                        nmtdecbelowcounter=nmtdecbelowcounter+1;
                        thdinfo.nmtdecbelowprofidxs(nmtdecbelowcounter,:)=[ilon ilat itime];
                    elseif (didxdeep~=1)&(length(po2now)>didxdeep)&(po2now(didxdeep+1)<po2now(didxdeep))
                        mtabovebelowcounter=mtabovebelowcounter+1;
                        thdinfo.mtabovebelowprofidxs(mtabovebelowcounter,:)=[ilon ilat itime];
                    end
        
                end % end if po2now==tunahypoxicpressure exactly

            end % end if all nans or tunahypoxicpressure not in range
        end
    end
end

% --> Look at how many profiles are all nan, out of range of the tuna hypoxic pressure,
% or monotonically decreasing right above/below THD

%disp('thd (all nan, out of range, non-monotonically decreasing above, non-monotonically decreasing below, monotonically decreasing above and below)')
%[allnancounter outofrangecounter nmtdecabovecounter nmtdecbelowcounter mtabovebelowcounter]
