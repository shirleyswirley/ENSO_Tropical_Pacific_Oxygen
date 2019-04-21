%--------------------------------------
% Define plot variables
%--------------------------------------
% - Subplot 1 (depth cross-section, abbrev xs)
yvarnamexs = 'po2anwod';
yvarnamexslong = 'pO_2';
xvarnamexs = 'tcdanwod'; 
xvarnamexslong = 'Thermocline Depth';

% - Subplot 2 (map)
yvarnamemap = 'thdanwod';
yvarnamemaplong = 'Tuna Hypoxic Depth';
xvarnamemap = 'tcdanwod';
xvarnamemaplong = 'Thermocline Depth';

%--------------------------------------
% Define plot parameters (both xs and map)
%--------------------------------------
% - Set plot appearance
rdylbunow = flipud(cbrewer('div','PuOr',15,'linear'));
rdylbunow(8,:) = [1.0000    1.0000    0.7490];

% - Define statistical significance stippling
stipsignif = 1; % stippling on = 1, off = 0
alphafdr = 0.1; % desired false discovery rate
stipms = 5; % stippling marker size
stipea = 0.5; % stippling marker edge alpha

%--------------------------------------
% Define plot parameters (xs only)
%--------------------------------------
% - Set plot appearance
fsnow = 10; % font size
xtlr = 0; % x-tick label rotation
linewidthc = 2; % contour line thickness (i.e., TCD, THD, etc. contours)

% - Define lon/lat limits and ticks to plot
nlatxs = 10; slatxs = nlatxs-20;
wlonxs = 120; elonxs = 280; % just for plot xlims
lonticksxs = [120 160 200 240 280];
if any(lonticksxs<180)
    lonticksxslabs = [strcat(cellstr(num2str(lonticksxs(lonticksxs<180)')),char(0176),'E')' ...
        strcat(cellstr(num2str(360-lonticksxs(lonticksxs>=180)')),char(0176),'W')'];
else
    lonticksxslabs = strcat(cellstr(num2str(360-lonticksxs(lonticksxs>180)')),char(0176),'W')';
end
latxsnow = lat(lat<nlatxs&lat>slatxs);

% - Define max depth to plot
maxdepth = 300;

%--------------------------------------
% Define plot parameters (map only)
%--------------------------------------
% - Set plot appearance
mapproj = 'gall-peters'; % map projection
coastlinewidth = 1; % coastline line width
landcolor = [0.6 0.6 0.6]; % land color

% - Define lon/lat limits and ticks to plot
wlonm = 100; elonm = 285;
lonticksm = [120 160 200 240 280];
slatm = -22.5; nlatm = 22.5;
latticksm = [-20 -10 0 10 20];

%--------------------------------------
% Define plot variables (xs only)
%--------------------------------------
% - Get pts over all desired lats
% and calc correls from those
xxsvarnow = eval(xvarnamexs);
if ndims(xxsvarnow)==3 % lon,lat,time 
    xxsvarnownow = nan(length(lon),length(lat),length(depth),length(timemoWOD));
    for itime = 1:length(timemoWOD)
        for idepth = 1:length(depth)
            xxsvarnownow(:,:,idepth,itime) = xxsvarnow(:,:,itime);
        end
    end
    xxsvarnow = xxsvarnownow(:,lat<nlatxs&lat>slatxs,:,:);
elseif ndims(xxsvarnow)==4 % lon,lat,depth,time 
    xxsvarnow = xxsvarnow(:,lat<nlatxs&lat>slatxs,:,:);
end

yxsvarnow = eval(yvarnamexs);
if ndims(yxsvarnow)==3 % lon,lat,time
    yxsvarnownow = nan(length(lon),length(lat),length(depth),length(timemoWOD));
    for itime = 1:length(timemoWOD)
        for idepth = 1:length(depth)
            yxsvarnownow(:,:,idepth,itime) = yxsvarnow(:,:,itime);
        end
    end
    yxsvarnow = yxsvarnownow(:,lat<nlatxs&lat>slatxs,:,:);
elseif ndims(yxsvarnow)==4 % lon,lat,depth,timemoWOD
    yxsvarnow = yxsvarnow(:,lat<nlatxs&lat>slatxs,:,:);
end

yvsxxs_tccnow = nan(length(lon),length(depth));
for ilon = 1:length(lon)
    for idepth = 1:length(depth)
        xynow = [reshape(squeeze(xxsvarnow(ilon,:,idepth,:)),[],1) ...
                reshape(squeeze(yxsvarnow(ilon,:,idepth,:)),[],1)];
        xynow = xynow(~any(isnan(xynow),2),:);
        if ~isempty(xynow)
            yvsxxs_tccnow(ilon,idepth) = corr(xynow(:,1),xynow(:,2));
        end
    end
end

% - Compute TCD contours:
tcmeannow = squeeze(nanmean(tcdmean(:,lat<nlatxs&lat>slatxs),2));
tcenoninow = tcmeannow+squeeze(nanmean(tcdanwod_enoni(:,lat<nlatxs&lat>slatxs),2));
tclnoninow = tcmeannow+squeeze(nanmean(tcdanwod_lnoni(:,lat<nlatxs&lat>slatxs),2));

%--------------------------------------
% Define plot variables (map only)
%--------------------------------------
yvsxmap = eval([yvarnamemap 'vs' xvarnamemap]);

%--------------------------------------
% Calc and plot significance (xs only)
%--------------------------------------
if stipsignif==1
    yvsxxs_pval = nan(length(lon),length(depth)); 
    for ilon = 1:length(lon)
        for idepth = 1:length(depth)
            xynow = [reshape(squeeze(xxsvarnow(ilon,:,idepth,:)),[],1) ...
                    reshape(squeeze(yxsvarnow(ilon,:,idepth,:)),[],1)];
            xynow = xynow(~any(isnan(xynow),2),:);
            if ~isempty(xynow)
                [~,yvsxxs_pval(ilon,idepth)] = corr(xynow(:,1),xynow(:,2));
            end
        end
    end
    yvsxxs_pvalnow = yvsxxs_pval(plon<=elonxs&plon>=wlonxs,plat<=nlatxs&plat>=slatxs);
    yvsxxs_pvalnow_sorted = sort(reshape(yvsxxs_pvalnow(~isnan(yvsxxs_pvalnow)),1,[]));
    N=numel(yvsxxs_pvalnow_sorted);
    %figure; plot(1:N,alphafdr*(1:N)/N); hold on; plot(1:N, yvsxxs_pvalnow_sorted);
    pfdrxs = yvsxxs_pvalnow_sorted( find( yvsxxs_pvalnow_sorted>=(alphafdr*(1:N)/N) ,1) );
end

%--------------------------------------
% Calc and plot significance (map only)
%--------------------------------------
if stipsignif==1
    yvsxmap_pvalnow = yvsxmap.pvalmap(plon<=elonm&plon>=wlonm,plat<=nlatm&plat>=slatm);
    yvsxmap_pvalnow_sorted = sort(reshape(yvsxmap_pvalnow(~isnan(yvsxmap_pvalnow)),1,[]));
    N=numel(yvsxmap_pvalnow_sorted);
    %figure; plot(1:N,alphafdr*(1:N)/N); hold on; plot(1:N, yvsxmap_pvalnow_sorted);
    pfdrmap = yvsxmap_pvalnow_sorted( find( yvsxmap_pvalnow_sorted>=(alphafdr*(1:N)/N) ,1) );
end

%--------------------------------------
% Plot
%--------------------------------------
f=figure;
set(f,'color','white','units','inches','position',[0 0 10 2.6],'resize','off');

%--------yvarnamexs vs xvarnamexs temporal correl coeff cross section subplot
ax1 = subplot(1,2,1);
colormap(ax1,rdylbunow);
set(ax1,'fontweight','bold');

pcolor(plon,pdepth,yvsxxs_tccnow'); shading flat; hold on;

% - Contour TCD
h2=plot(lon,tcmeannow,'k','linewidth',linewidthc);
h3=plot(lon,tcenoninow,'k-.','linewidth',linewidthc);
h4=plot(lon,tclnoninow,'k:','linewidth',linewidthc);

if stipsignif==1
    for ilon = 1:length(plon)
        for idepth = 1:length(pdepth)
            if yvsxxs_pval(ilon,idepth)<pfdrxs
                scatter(lon(ilon),depth(idepth),stipms,...
                    'MarkerEdgeColor','k','MarkerEdgeAlpha',stipea);
            end
        end
    end
end

ylim([0 maxdepth]);
xlim([wlonxs elonxs]);

caxis([-1 1]);
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');

lh=legend([h3 h2 h4],'El Nino TCD','Mean TCD','La Nina TCD','position',[140 40 1 1]);
set(lh,'color','none','box','off','fontweight','bold');

ylabel('Depth [m]');
title([yvarnamexslong ' vs. ' xvarnamexslong]);
set(ax1,'YDir','reverse','YMinorTick','on','XMinorTick','on','XTickLabelRotation',0,'XTick',lonticksxs,'XTickLabel',lonticksxslabs,'TickLength',[0.05, 0.005],'layer','top','fontsize',fsnow,'fontweight','bold','xticklabelrotation',xtlr);

%--------yvarnamemap vs xvarnamemap temporal correl coeff map subplot
ax2sp=subplot(1,2,2);
colormap(ax2sp,rdylbunow);
set(ax2sp,'fontweight','bold');

ax2=axesm('gortho','MapLatLimit',[slatm nlatm],'MapLonLimit',[wlonm elonm],...
  'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;

m_proj(mapproj,'lon',[wlonm elonm],'lat',[slatm nlatm]);

m_pcolor(plon,plat,yvsxmap.tempccmap');

m_grid('xtick',lonticksm,'ytick',latticksm,'xlabeldir','middle','fontsize',10);
caxis([-1 1]);
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out'); shading flat;

m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat

if stipsignif==1
    for ilon = 1:length(plon)
        for ilat = 1:length(plat)
            if yvsxmap.pvalmap(ilon,ilat)<pfdrmap
                m_scatter(lon(ilon),lat(ilat),'sizedata',stipms,...
                    'MarkerEdgeColor','k','MarkerEdgeAlpha',stipea);
            end
        end
    end
end

tightmap;
title([yvarnamemaplong ' vs. ' xvarnamemaplong]);

%--------Save out figure
print('mainfig3','-dpng');

%--------ADDITIONAL FEATURES ADDED IN POWERPOINT
% AFTER GENERATING THE FIGURES WERE:
% 1.) "Correlation coefficient" label
