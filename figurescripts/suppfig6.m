%--------------------------------------
% Define plot parameters
%--------------------------------------
% - Set plot appearances
ylgnbunow = cbrewer('seq','YlGnBu',11,'linear');

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

% - Set colorbar unit label positioning
unitlabelX = 1.045*interp1( [0 1], [wlon elon], 1 ); % x-position of unit label
unitlabelY = interp1( [0 1], [min(timeyrWOD) max(timeyrWOD)], 0.25 ); % y-position of unit label

%--------------------------------------
% Calculate plot variables
%--------------------------------------
varnow = po250(:,lat<nlat&lat>slat,:);
varnp_yrlon = nan(length(timeyrWOD),length(lon));
for iyr = 1:length(timeyrWOD)
    tidxnow = find(year(timemoWOD)==timeyrWOD(iyr));
    for ilon = 1:length(lon)
        varnp_yrlon(iyr,ilon) = sum(sum(~isnan(varnow(ilon,:,tidxnow))));
    end
end
po250np_yrlon = varnp_yrlon;

varnow = po2100(:,lat<nlat&lat>slat,:);
varnp_yrlon = nan(length(timeyrWOD),length(lon));
for iyr = 1:length(timeyrWOD)
    tidxnow = find(year(timemoWOD)==timeyrWOD(iyr));
    for ilon = 1:length(lon)
        varnp_yrlon(iyr,ilon) = sum(sum(~isnan(varnow(ilon,:,tidxnow))));
    end
end
po2100np_yrlon = varnp_yrlon;

varnow = thd(:,lat<nlat&lat>slat,:);
varnp_yrlon = nan(length(timeyrWOD),length(lon));
for iyr = 1:length(timeyrWOD)
    tidxnow = find(year(timemoWOD)==timeyrWOD(iyr));
    for ilon = 1:length(lon)
        varnp_yrlon(iyr,ilon) = sum(sum(~isnan(varnow(ilon,:,tidxnow))));
    end
end
thdnp_yrlon = varnp_yrlon;

varnow = tcd(:,lat<nlat&lat>slat,:);
varnp_yrlon = nan(length(timeyrWOD),length(lon));
for iyr = 1:length(timeyrWOD)
    tidxnow = find(year(timemoWOD)==timeyrWOD(iyr));
    for ilon = 1:length(lon)
        varnp_yrlon(iyr,ilon) = sum(sum(~isnan(varnow(ilon,:,tidxnow))));
    end
end
tcdnp_yrlon = varnp_yrlon;

%--------------------------------------
% Plot
%--------------------------------------
f=figure;
set(f,'color','white','units','inches','position',[0 0 10 4.5],'resize','off');
colormap(ylgnbunow);

ax1=subplot(2,2,1);
pcolor(plon,timeyrWOD',po250np_yrlon); shading flat;
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
title('[pO_2] at 50 m');
xlim([wlon elon]);
set(ax1,'YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top');
ylabel('Year');
text(unitlabelX, unitlabelY, 'Number of months','Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ax2=subplot(2,2,2);
pcolor(plon,timeyrWOD',po2100np_yrlon); shading flat;
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
title('[pO_2] at 100 m');
xlim([wlon elon]);
set(ax2,'YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top');
ylabel('Year');
text(unitlabelX, unitlabelY, 'Number of months','Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ax3=subplot(2,2,3);
pcolor(plon,timeyrWOD',thdnp_yrlon); shading flat;
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
title('Tuna Hypoxic Depth');
xlim([wlon elon]);
set(ax3,'YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top');
ylabel('Year');
text(unitlabelX, unitlabelY, 'Number of months','Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ax4=subplot(2,2,4);
pcolor(plon,timeyrWOD',tcdnp_yrlon); shading flat;
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
title('Thermocline Depth');
xlim([wlon elon]);
set(ax4,'YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top');
ylabel('Year');
text(unitlabelX, unitlabelY, 'Number of months','Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

%--------Adjust figure size
posf = get(gcf,'position');
set(gcf,'position',[posf(1:2) posf(3) posf(4)*1.5])

%--------Save out figure
print('suppfig6','-dpng');
