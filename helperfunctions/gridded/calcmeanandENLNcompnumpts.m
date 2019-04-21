function [varinnptot,varinnp_en,varinnp_ln] = calcmeanandENLNcompnumpts(varin,en,ln)

%--------------------------------------
% Calculate total 2-D or 3-D maps numpts
%--------------------------------------
if ndims(varin)==3 % x,y,t
    varinnptot = nan(size(varin(:,:,1)));
    for ilon = 1:size(varin,1)
        for ilat = 1:size(varin,2)
           varinnptot(ilon,ilat) = sum(~isnan(varin(ilon,ilat,:))); 
        end
    end
elseif ndims(varin)==4 % x,y,z,t
    varinnptot = nan(size(varin(:,:,:,1)));
    for ilon = 1:size(varin,1)
        for ilat = 1:size(varin,2)
            for idepth = 1:size(varin,3)
               varinnptot(ilon,ilat,idepth) = sum(~isnan(varin(ilon,ilat,idepth,:)));
            end
        end
    end
end

%--------------------------------------
% Calculate EN/LN composite 2-D or 3-D maps numpts
%--------------------------------------
if ndims(varin)==3 % x,y,t
    varinnp_en = nan(size(varin(:,:,1)));
    varinnp_ln = nan(size(varin(:,:,1)));
    for ilon = 1:size(varin,1)
        for ilat = 1:size(varin,2)
            varinnp_en(ilon,ilat) = sum(~isnan(varin(ilon,ilat,en==1))); 
            varinnp_ln(ilon,ilat) = sum(~isnan(varin(ilon,ilat,ln==1))); 
        end
    end
elseif ndims(varin)==4 % x,y,z,t
    varinnp_en = nan(size(varin(:,:,:,1)));
    varinnp_ln = nan(size(varin(:,:,:,1)));
    for ilon = 1:size(varin,1)
        for ilat = 1:size(varin,2)
            for idepth = 1:size(varin,3)
                varinnp_en(ilon,ilat,idepth) = sum(~isnan(varin(ilon,ilat,idepth,en==1)));
                varinnp_ln(ilon,ilat,idepth) = sum(~isnan(varin(ilon,ilat,idepth,ln==1)));
            end
        end
    end
end
