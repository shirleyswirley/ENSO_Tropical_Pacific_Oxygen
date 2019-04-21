function varinrho = calcrhofromdepth(varin,depth,potdens)
% - Regrids 3D (lon,lat,time) depth
% variables (like TCD and THD) onto
% isopycnal space (i.e., tells you the density
% where that depth occurs). 
varinrho = nan(size(varin,1),size(varin,2),size(varin,3));
for ilat = 1:size(varin,2)
    for ilon= 1:size(varin,1)
        for itime = 1:size(varin,3)

            [jnk didx]=min(abs(varin(ilon,ilat,itime)-depth));
    
            % If TCD, THD, or other depth is exactly eq to a depth in 'depth' var:
            if (varin(ilon,ilat,itime)-depth(didx))==0
                varinrho(ilon,ilat,itime) = potdens(ilon,ilat,didx,itime);
    
            % If TCD, THD, or other depth < closest depth:
            elseif (varin(ilon,ilat,itime)-depth(didx))<0
                if didx==1
                    varinrho(ilon,ilat,itime) = potdens(ilon,ilat,didx,itime);
                else
                    varinrho(ilon,ilat,itime) = ...
                        interp1([depth(didx-1) depth(didx)],...
                        [potdens(ilon,ilat,didx-1,itime) potdens(ilon,ilat,didx,itime)],...
                        varin(ilon,ilat,itime));
                end
    
            % If TCD, THD, or other depth > closest depth:
            elseif (varin(ilon,ilat,itime)-depth(didx))>0
                if didx==length(depth)
                    varinrho(ilon,ilat,itime) = nan;
                else
                    varinrho(ilon,ilat,itime) = ...
                        interp1([depth(didx) depth(didx+1)],...
                        [potdens(ilon,ilat,didx,itime) potdens(ilon,ilat,didx+1,itime)],...
                        varin(ilon,ilat,itime));
                end
            end

        end        
    end
end
