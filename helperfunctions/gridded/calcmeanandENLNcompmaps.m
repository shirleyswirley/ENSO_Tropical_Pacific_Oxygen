function [varinmean,varin_en,varin_ln] = calcmeanandENLNcompmaps(varin,en,ln)

%--------------------------------------
% Calculate mean 2-D or 3-D maps
%--------------------------------------
if ndims(varin)==3 % x,y,t
    varinmean = nanmean(varin,3);
elseif ndims(varin)==4 % x,y,z,t
    varinmean = nanmean(varin,4);
end

%--------------------------------------
% Calculate mean EN/LN composite 2-D or 3-D maps
%--------------------------------------
if ndims(varin)==3 % x,y,t
    varin_en = nanmean(varin(:,:,en==1),3);
    varin_ln = nanmean(varin(:,:,ln==1),3);
elseif ndims(varin)==4 % x,y,z
    varin_en = nanmean(varin(:,:,:,en==1),4);
    varin_ln = nanmean(varin(:,:,:,ln==1),4);
end
