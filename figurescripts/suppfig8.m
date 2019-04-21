%--------------------------------------
% Define plot variable and parameters
%--------------------------------------
varname = 'po2';
varunits = '#months';

% - Define colorbar ranges
climsdefined = 1; % use automatic range = 0, specify range = 1
cminmaxtotal = [14 275]; % defines limits for subplot 1 
cdiffmaxenln = 41; % defines limits for subplot 2
cminmaxen = [2 80]; % defines limits for subplot 3
cminmaxln = [2 80]; % defines limits for subplot 4

% - Set plot appearances
ylgnbunow = cbrewer('seq','YlGnBu',11,'linear'); % colormap for subplots 1,3-4
rdylbunow = flipud(cbrewer('div','RdYlBu',11,'linear')); % colormap for subplot 2

% - Define lon/lat limits and ticks to plot
nlat = 10; slat = nlat-20;
wlon = 120; elon = 280;
lonticks = [120 160 200 240 280];
if any(lonticks<180)
    lonticklabs = [strcat(cellstr(num2str(lonticks(lonticks<=180)')),char(0176),'E')' ...
    strcat(cellstr(num2str(360-lonticks(lonticks>180)')),char(0176),'W')'];
else
    lonticklabs = strcat(cellstr(num2str(360-lonticks(lonticks>180)')),char(0176),'W')';
end
latnow = lat(lat<nlat&lat>slat);

% - Define max depth to plot
maxdepth = 300; % max depth to plot 

% - Set colorbar unit label positioning
unitlabelX = 1.06*interp1( [0 1], [wlon elon], 1 );
unitlabelY = interp1( [0 1], [0 maxdepth], 0.85 );

%--------------------------------------
% Calculate plot variables
%--------------------------------------
varnptot = eval([varname 'nptot']);
varnp_enoni = eval([varname 'np_enoni']);
varnp_lnoni = eval([varname 'np_lnoni']);

varnptotnow = squeeze(nansum(varnptot(:,lat<nlat&lat>slat,:),2));
varnp_enoninow = squeeze(nansum(varnp_enoni(:,lat<nlat&lat>slat,:),2));
varnp_lnoninow = squeeze(nansum(varnp_lnoni(:,lat<nlat&lat>slat,:),2));

clear varnptot varnp_enoni varnp_lnoni;

%--------------------------------------
% Plot
%--------------------------------------
f=figure;
set(f,'color','white','units','inches','position',[0 0 10 5.25],'resize','off');

%--------Mean (total # of pts) subplot
ax1=subplot(2,2,1);
colormap(ax1,ylgnbunow);

pcolor(plon,pdepth,varnptotnow'); shading flat;
ylim([0 maxdepth]);
xlim([wlon elon]);

if climsdefined==1; caxis(cminmaxtotal); end
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, 'Number of months','Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ylabel('Depth [m]');
title('Total');
set(ax1,'YDir','reverse','YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top');

%--------EN subplot
ax2=subplot(2,2,3);
colormap(ax2,ylgnbunow);

pcolor(plon,pdepth,varnp_enoninow'); shading flat;
ylim([0 maxdepth]);
xlim([wlon elon]);

if climsdefined==1; caxis(cminmaxen); end
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, 'Number of months','Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ylabel('Depth [m]');
title('El Nino');
set(ax2,'YDir','reverse','YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top');

%--------LN subplot
ax3=subplot(2,2,4);
colormap(ax3,ylgnbunow);

pcolor(plon,pdepth,varnp_lnoninow'); shading flat;
ylim([0 maxdepth]);
xlim([wlon elon]);

if climsdefined==1; caxis(cminmaxln); end
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, 'Number of months','Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ylabel('Depth [m]');
title('La Nina');
set(ax3,'YDir','reverse','YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top');

%--------EN-LN subplot
ax4=subplot(2,2,2);
colormap(ax4,rdylbunow);

pcolor(plon,pdepth,varnp_enoninow'-varnp_lnoninow'); shading flat;
ylim([0 maxdepth]);
xlim([wlon elon]);

if climsdefined==0; cdiffmaxenln = max(max(abs(varnp_enoninow-varnp_lnoninow))); end
caxis([-cdiffmaxenln cdiffmaxenln]);
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, 'Number of months','Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ylabel('Depth [m]');
title('El Nino - La Nina');
set(ax4,'YDir','reverse','YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top');

%--------Save out figure
print('suppfig8','-dpng');

%--------ADDITIONAL FEATURES ADDED IN POWERPOINT
% AFTER GENERATING THE FIGURES WERE:
% 1.) Pointy ends of colorbars whenever the plotted data
% was out of range of the colorbar
