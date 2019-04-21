%--------------------------------------
% Define plot variable and parameters
%--------------------------------------
% - Choose the figure you want to plot
fignamenow = 'mainfig1'; % choose btwn: 'mainfig1','suppfig1d','suppfig1e'

if strcmp(fignamenow,'mainfig1')

    % MAIN FIGURE 1:
    varname = 'po2';
    varunits = 'kPa';
    longname = 'pO_2';
    
    % - Define colorbar ranges
    climsdefined = 1; % use automatic range = 0, specify range = 1
    cminmax = [0 22]; % defines limits for subplot 1
    cdiffmax = 2.2; % defines limits for subplots 2-4

elseif strcmp(fignamenow,'suppfig1d') 

    % SUPP. FIGURE 1D:
    varname = 'temp';
    varunits = '°C';
    longname = 'In Situ Temperature';
    
    % - Define colorbar ranges
    climsdefined = 1; % use automatic range = 0, specify range = 1
    cminmax = [10 30]; % defines limits for subplot 1
    cdiffmax = 3; % defines limits for subplots 2-4

elseif strcmp(fignamenow,'suppfig1e') 

    % SUPP. FIGURE 1E:
    varname = 'sal';
    varunits = 'psu';
    longname = 'Salinity';
    
    % - Define colorbar ranges
    climsdefined = 1; % use automatic range = 0, specify range = 1
    cminmax = [33.5 35.5]; % defines limits for subplot 1
    cdiffmax = 1; % defines limits for subplots 2-4
end

% THE REST APPLIES TO MAIN FIG 1 AS WELL AS SUPP FIG1D-E:

% - Set plot appearances
ylgnbunow = cbrewer('seq','YlGnBu',11,'linear'); % colormap for subplots 1-2
rdylbunow = flipud(cbrewer('div','PuOr',11,'linear')); % colormap for subplots 3-4
rdylbunow(6,:) = [1.0000    1.0000    0.7490];
fsnow = 10; % font size
xtlr = 0; % x-tick label rotation
linewidthc = 2; % contour line thickness (i.e., TCD, THD, etc. contours)

% - Define statistical significance stippling
stipsignif = 1; % stippling on = 1, off = 0
alphafdr = 0.1; % desired false discovery rate
stipms = 6; % stippling marker size
stipea = 0.5; % stippling marker edge alpha

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
maxdepth = 300;

% - Define how many stdevs to plot
numstdevs = 1;

% - Set colorbar unit label positioning
unitlabelX = 1.045*interp1( [0 1], [wlon elon], 1 );
unitlabelY = interp1( [0 1], [0 maxdepth], 0.58 );

%--------------------------------------
% Calculate plot variables
%--------------------------------------
varannow = eval([varname 'anwod']);
varnow = eval(varname);
varmeannow = nan(length(lon),length(depth));
varanstdevnow = nan(length(lon),length(depth));
varanenoninow = nan(length(lon),length(depth));
varanlnoninow = nan(length(lon),length(depth));
for ilon = 1:length(lon)
    for idepth = 1:length(depth)
        varmeannow(ilon,idepth) = nanmean(reshape(squeeze(varnow(ilon,lat<nlat&lat>slat,idepth,:)),1,[])); 
        varanstdevnow(ilon,idepth) = nanstd(reshape(squeeze(varannow(ilon,lat<nlat&lat>slat,idepth,:)),1,[])); 
        varanenoninow(ilon,idepth) = nanmean(reshape(squeeze(varannow(ilon,lat<nlat&lat>slat,idepth,onien==1)),1,[])); 
        varanlnoninow(ilon,idepth) = nanmean(reshape(squeeze(varannow(ilon,lat<nlat&lat>slat,idepth,oniln==1)),1,[]));
    end
end

% - Compute (po2 values for) THD contours:
po2meannow = nan(length(lon),length(depth));
po2enoninow = nan(length(lon),length(depth));
po2lnoninow = nan(length(lon),length(depth));
for ilon = 1:length(lon)
    for idepth = 1:length(depth)
        po2meannow(ilon,idepth) = nanmean(reshape(squeeze(po2(ilon,lat<nlat&lat>slat,idepth,:)),1,[]));
        po2enoninow(ilon,idepth) = nanmean(reshape(squeeze(po2anwod(ilon,lat<nlat&lat>slat,idepth,onien==1)),1,[]))+po2meannow(ilon,idepth);
        po2lnoninow(ilon,idepth) = nanmean(reshape(squeeze(po2anwod(ilon,lat<nlat&lat>slat,idepth,oniln==1)),1,[]))+po2meannow(ilon,idepth);
    end
end

% - Compute TCD contours:
tcdmeannow = nan(length(lon),1);
tcdenoninow = nan(length(lon),1);
tcdlnoninow = nan(length(lon),1);
for ilon = 1:length(lon)
    tcdmeannow(ilon) = nanmean(reshape(squeeze(tcd(ilon,lat<nlat&lat>slat,:)),1,[]));
    tcdenoninow(ilon) = nanmean(reshape(squeeze(tcdanwod(ilon,lat<nlat&lat>slat,onien==1)),1,[]))+tcdmeannow(ilon);
    tcdlnoninow(ilon) = nanmean(reshape(squeeze(tcdanwod(ilon,lat<nlat&lat>slat,oniln==1)),1,[]))+tcdmeannow(ilon);
end

%--------------------------------------
% Calculate and plot significance
%--------------------------------------
if stipsignif==1
    varenlnxs_wrspvals = nan(length(lon),length(depth));
    for ilon = 1:length(lon)
        for idepth = 1:length(depth)
            enoninow = reshape(squeeze(varannow(ilon,lat<nlat&lat>slat,idepth,onien==1)),1,[]);
            enoninow = enoninow(~isnan(enoninow));
            lnoninow = reshape(squeeze(varannow(ilon,lat<nlat&lat>slat,idepth,oniln==1)),1,[]);
            lnoninow = lnoninow(~isnan(lnoninow));
            if length(enoninow)>0 & length(lnoninow)>0
                [varenlnxs_wrspvals(ilon,idepth),~] = ranksum(enoninow,lnoninow);
            end
        end
    end
    varenlnxs_wrspvalsnow = varenlnxs_wrspvals(plon<=elon&plon>=wlon,depth<=maxdepth);
    varenlnxs_wrspvalsnow_sorted = sort(reshape(varenlnxs_wrspvalsnow(~isnan(varenlnxs_wrspvalsnow)),1,[]));
    N=numel(varenlnxs_wrspvalsnow_sorted);
    pfdr_varenlnxs_wrs = varenlnxs_wrspvalsnow_sorted( find( varenlnxs_wrspvalsnow_sorted>=(alphafdr*(1:N)/N) ,1) );
    %figure; plot(1:N,alphafdr*(1:N)/N); hold on; plot(1:N, varenlnxs_wrspvalsnow_sorted);
end

%--------------------------------------
% Plot
%--------------------------------------
f=figure;
set(f,'color','white','units','inches','position',[0 0 10 3.5],'resize','off');

%--------Mean subplot
ax1=subplot(2,2,1);
colormap(ax1,ylgnbunow);

h1=pcolor(plon,pdepth,varmeannow'); shading flat; hold on;

% - Contour mean TCD
h2=plot(lon,tcdmeannow,'color',[0.5 0.5 0.5],'linewidth',linewidthc);

% - Contour mean THD
if strcmp(varname,'po2')
    [~,h3]=contour(lon,pdepth,po2meannow',[tunahypoxicpressure tunahypoxicpressure],'k','linewidth',linewidthc);
end

ylim([0 maxdepth]);
xlim([wlon elon]);

if climsdefined==1; caxis(cminmax); end
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, ['[' varunits ']'],'Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ylabel('Depth [m]');
title(['Mean ' longname]);
set(ax1,'YDir','reverse','YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top','fontsize',fsnow,'fontweight','bold','xticklabelrotation',xtlr);

%--------Stdev subplot
ax2 = subplot(2,2,2);
colormap(ax2,ylgnbunow);

pcolor(plon,pdepth,numstdevs*varanstdevnow'); shading flat;hold on;

% - Contour mean TCD
h2=plot(lon,tcdmeannow,'color',[0.5 0.5 0.5],'linewidth',linewidthc);

% - Contour mean THD
if strcmp(varname,'po2')
    [~,h3]=contour(lon,pdepth,po2meannow',[tunahypoxicpressure tunahypoxicpressure],'k','linewidth',linewidthc);
end

ylim([0 maxdepth]);
xlim([wlon elon]);

if climsdefined==0; cdiffmax = max(max(abs(numstdevs*varanstdevnow))); end
caxis([0 cdiffmax]);
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, ['[' varunits ']'],'Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ylabel('Depth [m]');
title(['Monthly Anomalies: ' num2str(numstdevs) '\sigma']);
set(ax2,'YDir','reverse','YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top','fontsize',fsnow,'fontweight','bold','xticklabelrotation',xtlr);

%--------EN-mean subplot
ax3=subplot(2,2,3);
colormap(ax3,rdylbunow);

h1=pcolor(plon,pdepth,varanenoninow'); shading flat; hold on;

if stipsignif==1
    for ilon = 1:length(plon)
        for idepth = 1:length(pdepth)
            if varenlnxs_wrspvals(ilon,idepth)<pfdr_varenlnxs_wrs
                scatter(lon(ilon),depth(idepth),stipms,...
                    'MarkerEdgeColor','k','MarkerEdgeAlpha',stipea);
            end
        end
    end
end

% - Contour mean TCD
plot(lon,tcdmeannow,'color',[0.5 0.5 0.5],'linestyle','-','linewidth',linewidthc);

% - Contour mean/ENSO composite THD
[~,h2]=contour(lon,pdepth,po2meannow',[tunahypoxicpressure tunahypoxicpressure],'k','linewidth',linewidthc);
[~,h3]=contour(lon,pdepth,po2enoninow',[tunahypoxicpressure tunahypoxicpressure],'k-.','linewidth',linewidthc);
[~,h4]=contour(lon,pdepth,po2lnoninow',[tunahypoxicpressure tunahypoxicpressure],'k:','linewidth',linewidthc);

ylim([0 maxdepth]);
xlim([wlon elon]);

if climsdefined==0; cdiffmax = max(max(abs(varanenoninow))); end
caxis([-cdiffmax cdiffmax]); c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, ['[' varunits ']'],'Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ylabel('Depth [m]');
title('Monthly Anomalies: El Nino');
set(ax3,'YDir','reverse','YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top','fontsize',fsnow,'fontweight','bold','xticklabelrotation',xtlr);

%--------LN-mean subplot
ax4=subplot(2,2,4);
colormap(ax4,rdylbunow);

pcolor(plon,pdepth,varanlnoninow'); shading flat; hold on;

if stipsignif==1
    for ilon = 1:length(plon)
        for idepth = 1:length(pdepth)
            if varenlnxs_wrspvals(ilon,idepth)<pfdr_varenlnxs_wrs
                scatter(lon(ilon),depth(idepth),stipms,...
                    'MarkerEdgeColor','k','MarkerEdgeAlpha',stipea); 
            end
        end
    end
end

% - Contour mean TCD
plot(lon,tcdmeannow,'color',[0.5 0.5 0.5],'linewidth',linewidthc);

% - Contour mean/ENSO composite THD
if strcmp(varname,'po2')
    contour(lon,pdepth,po2meannow',[tunahypoxicpressure tunahypoxicpressure],'k','linewidth',linewidthc);
    contour(lon,pdepth,po2enoninow',[tunahypoxicpressure tunahypoxicpressure],'k-.','linewidth',linewidthc);
    contour(lon,pdepth,po2lnoninow',[tunahypoxicpressure tunahypoxicpressure],'k:','linewidth',linewidthc);
end

ylim([0 maxdepth]);
xlim([wlon elon]);

if climsdefined==0; cdiffmax = max(max(abs(varanlnoninow))); end
caxis([-cdiffmax cdiffmax]); c=colorbar; set(c,'ticklength',0.05,'tickdirection','out');
text(unitlabelX, unitlabelY, ['[' varunits ']'],'Rotation',90,'fontsize',10,'fontangle','italic','fontsmoothing','on');

ylabel('Depth [m]');
title('Monthly Anomalies: La Nina');
set(ax4,'YDir','reverse','YMinorTick','on','XMinorTick','on','XTick',lonticks,'XTickLabel',lonticklabs,'TickLength',[0.05, 0.005],'layer','top','fontsize',fsnow,'fontweight','bold','xticklabelrotation',xtlr);

%--------Adjust figure size
posf = get(gcf,'position');
set(gcf,'position',[posf(1:2) posf(3) posf(4)*2])

%--------Save out figure
print(fignamenow,'-dpng');

%--------ADDITIONAL FEATURES ADDED IN POWERPOINT
% AFTER GENERATING THE FIGURES WERE:
% 1.) Pointy ends of colorbars whenever the plotted data
% was out of range of the colorbar
% 2.) Legend
% 3.) For Supp. Fig. 1d,e, only used subplot #1.
