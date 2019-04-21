function varinrho = calcrhospace4d(varin,rhoedges,potdens)
% - Regrids 4D (lon,lat,depth,time) depth-gridded
% variables onto isopycnal space. 
varinrho = nan(size(varin,1),size(varin,2),length(rhoedges)-1,size(varin,4));
for irho = 1:(length(rhoedges)-1)
    for ilat = 1:size(varin,2)
        for ilon = 1:size(varin,1)
            for itime = 1:size(varin,4)
                rhoprofnow = potdens(ilon,ilat,:,itime);
                didxs = find(rhoprofnow>rhoedges(irho)&rhoprofnow<rhoedges(irho+1));
                if isempty(didxs)
                    varinrho(ilon,ilat,irho,itime) = nan;
                else
                    varinrho(ilon,ilat,irho,itime) = nanmean(varin(ilon,ilat,didxs,itime));
                end
            end
        end
    end
end
