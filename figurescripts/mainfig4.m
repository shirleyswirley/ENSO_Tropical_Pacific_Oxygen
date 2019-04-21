%--------------------------------------
% Define plot variable and parameters
%--------------------------------------
varname = 'po2';
varunits = 'kPa';
longname = 'pO_2';

% - Define colorbar ranges
climsdefined = 1; % use automatic range = 0, specify range = 1
cminmax = [0 23.5]; % defines limits for subplot 1
cdiffmax = 3; % defines limits for subplots 2-3

% - Set plot appearances
ylgnbunow = cbrewer('seq','YlGnBu',11,'linear'); % colormap for subplot 1
rdylbunow = flipud(cbrewer('div','PuOr',11,'linear')); % colormap for subplots 2-3
rdylbunow(6,:) = [1.0000    1.0000    0.7490];
fsnow = 10; % font size
xtlr = 0; % x-tick label rotation
linewidthc = 2; % contour line thickness (i.e., TCD, THD, etc. contours)

% - Define statistical significance stippling
stipsignif = 1; % stippling on = 1, off = 0
alphafdr = 0.1; % desired false discovery rate
stipms = 8; % stippling marker size
stipea = 0.5; % stippling marker edge alpha

% - Define lon/lat limits and ticks to plot
nlat = 10; slat = nlat-20;
wlon = 120; elon = 280; % just for plot xlims
lonticks = [120 160 200 240 280];
if any(lonticks<180)
    lonticklabs = [strcat(cellstr(num2str(lonticks(lonticks<=180)')),char(0176),'E')' ...
    strcat(cellstr(num2str(360-lonticks(lonticks>180)')),char(0176),'W')'];
else
    lonticklabs = strcat(cellstr(num2str(360-lonticks(lonticks>180)')),char(0176),'W')';
end
latnow = lat(lat<nlat&lat>slat);

% - Define min and max densities to plot
rhomin = 1021; rhomax = 1027.5;

% - Set colorbar unit label positioning
unitlabelX = 1.055*interp1( [0 1], [wlon elon], 1 );
unitlabelY = interp1( [0 1], [rhomin rhomax], 0.58 );

%--------------------------------------
% Calculate plot variables
%--------------------------------------
varnow = eval([varname 'rho']); % lon,lat,rho,time
varannow = eval([varname 'rhoanwod']); % lon,lat,rho,time
varmeannow = nan(length(lon),length(rho));
varanenoninow = nan(length(lon),length(rho));
varanlnoninow = nan(length(lon),length(rho));
for ilon = 1:length(lon)
    for irho = 1:length(rho)
        varmeannow(ilon,irho) = nanmean(reshape(squeeze(varnow(ilon,lat<nlat&lat>slat,irho,:)),1,[]));
        varanenoninow(ilon,irho) = nanmean(reshape(squeeze(varannow(ilon,lat<nlat&lat>slat,irho,onien==1)),1,[]));
        varanlnoninow(ilon,irho) = nanmean(reshape(squeeze(varannow(ilon,lat<nlat&lat>slat,irho,oniln==1)),1,[]));
    end
end

% - Compute TCD contours:
tcdmeannow = nan(length(lon),1);
tcdenoninow = nan(length(lon),1);
tcdlnoninow = nan(length(lon),1);
for ilon = 1:length(lon)
    tcdmeannow(ilon) = nanmean(reshape(squeeze(tcdrho(ilon,lat<nlat&lat>slat,:)),1,[]));
    tcdenoninow(ilon) = nanmean(reshape(squeeze(tcdrho(ilon,lat<nlat&lat>slat,onien==1)),1,[]));
    tcdlnoninow(ilon) = nanmean(reshape(squeeze(tcdrho(ilon,lat<nlat&lat>slat,oniln==1)),1,[]));
    %tcdenoninow(ilon) = nanmean(reshape(squeeze(tcdanpmeanrho(ilon,lat<nlat&lat>slat,onien==1)),1,[]));
    %tcdlnoninow(ilon) = nanmean(reshape(squeeze(tcdanpmeanrho(ilon,lat<nlat&lat>slat,oniln==1)),1,[]));
end

%--------------------------------------
% Calc and plot significance
%--------------------------------------
if stipsignif==1
    varenlnxs_wrspvals = nan(length(lon),length(rho));
    varenlnxs_wrsh01 = nan(length(lon),length(rho));
    for ilon = 1:length(lon)
        for irho = 1:length(rho)
            enoninow = reshape(squeeze(varannow(ilon,lat<nlat&lat>slat,irho,onien==1)),1,[]);
            lnoninow = reshape(squeeze(varannow(ilon,lat<nlat&lat>slat,irho,oniln==1)),1,[]);
            enoninow = enoninow(~isnan(enoninow));
            lnoninow = lnoninow(~isnan(lnoninow));
            if length(enoninow)>0 & length(lnoninow)>0
                [varenlnxs_wrspvals(ilon,irho),varenlnxs_wrsh01(ilon,irho)] = ranksum(enoninow,lnoninow);
            end
        end
    end
    varenlnxs_wrspvalsnow = varenlnxs_wrspvals(plon<=elon&plon>=wlon,rho<=rhomax);
    varenlnxs_wrspvalsnow_sorted = sort(reshape(varenlnxs_wrspvalsnow(~isnan(varenlnxs_wrspvalsnow)),1,[]));
    N=numel(varenlnxs_wrspvalsnow_sorted);
    %figure; plot(1:N,alphafdr*(1:N)/N); hold on; plot(1:N, varenlnxs_wrspvalsnow_sorted);
    pfdr_varenlnxs_wrs = varenlnxs_wrspvalsnow_sorted( find( varenlnxs_wrspvalsnow_sorted>=(alphafdr*(1:N)/N) ,1) );
end

%--------------------------------------
% Plot
%--------------------------------------
f=figure;
set(f,'color','white','units','inches','position',[0 0 13.5 2.5]);

%--------Mean subplot
ax1=subplot(1,3,1);
colormap(ax1,ylgnbunow);

pcolor(plon,prho,varmeannow'); shading flat; hold on;

% - Contour TCD
plot(lon,tcdmeannow,'k','linewidth',linewidthc);
plot(lon,tcdenoninow,'k-.','linewidth',linewidthc);
plot(lon,tcdlnoninow,'k:','linewidth',linewidthc);

ylim([rhomin rhomax]);
xlim([wlon elon]);

if climsdefined==1; caxis(cminmax); end
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, ['[' varunits ']'],'Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

title(['Mean ' longname]);
ylabel('Isopycnal [kg m^{-3}]');
set(gca, 'YDir', 'reverse');
set(ax1,'YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top','fontsize',fsnow,'fontweight','bold','xticklabelrotation',xtlr);

%--------EN-mean subplot
ax5=subplot(1,3,2);
colormap(ax5,rdylbunow);

pcolor(plon,prho,varanenoninow'); shading flat; hold on;

% - Contour TCD
plot(lon,tcdmeannow,'k','linewidth',linewidthc);
plot(lon,tcdenoninow,'k-.','linewidth',linewidthc);
plot(lon,tcdlnoninow,'k:','linewidth',linewidthc);

if stipsignif==1
    for ilon = 1:length(plon)
        for irho = 1:length(prho)
            if varenlnxs_wrspvals(ilon,irho)<pfdr_varenlnxs_wrs
                scatter(lon(ilon),rho(irho),stipms,...
                    'MarkerEdgeColor','k','MarkerEdgeAlpha',stipea);
            end
        end
    end
end

ylim([rhomin rhomax]);
xlim([wlon elon]);

if climsdefined==0; cdiffmax = max(max(abs(var_enoni1now-varmeannow))); end
caxis([-cdiffmax cdiffmax]);
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, ['[' varunits ']'],'Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

title(['{\color{white}_0}Monthly Anomalies: El Nino{\color{white}_0}']);
ylabel('Isopycnal [kg m^{-3}]');
set(gca, 'YDir', 'reverse');
set(ax5,'YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top','fontsize',fsnow,'fontweight','bold','xticklabelrotation',xtlr);

%--------LN-mean subplot
ax6=subplot(1,3,3);
colormap(ax6,rdylbunow);

pcolor(plon,prho,varanlnoninow'); shading flat; hold on;

% - Contour TCD
plot(lon,tcdmeannow,'k','linewidth',linewidthc);
plot(lon,tcdenoninow,'k-.','linewidth',linewidthc);
plot(lon,tcdlnoninow,'k:','linewidth',linewidthc);

if stipsignif==1
    for ilon = 1:length(plon)
        for irho = 1:length(prho)
            if varenlnxs_wrspvals(ilon,irho)<pfdr_varenlnxs_wrs
                scatter(lon(ilon),rho(irho),stipms,...
                    'MarkerEdgeColor','k','MarkerEdgeAlpha',stipea);
            end
        end
    end
end

ylim([rhomin rhomax]);
xlim([wlon elon]);

if climsdefined==0; cdiffmax = max(max(abs(var_lnoni1now-varmeannow))); end
caxis([-cdiffmax cdiffmax]);
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, ['[' varunits ']'],'Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

title(['{\color{white}_0}Monthly Anomalies: La Nina{\color{white}_0}']);
ylabel('Isopycnal [kg m^{-3}]');
set(gca, 'YDir', 'reverse');
set(ax6,'YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top','fontsize',fsnow,'fontweight','bold','xticklabelrotation',xtlr);

%--------Save out figure
print('mainfig4','-dpng');

%--------ADDITIONAL FEATURES ADDED IN POWERPOINT
% AFTER GENERATING THE FIGURES WERE:
% 1.) Pointy ends of colorbars whenever the plotted data
% was out of range of the colorbar
% 2.) Legend
