%--------------------------------------
% Define plot variables and parameters
%--------------------------------------
varname = 'po2';
varunits = 'kPa';
longname = 'pO_2';

% - Define colorbar ranges
climsdefined = 1; % use automatic range = 0, specify range = 1
cminmax = [0 23]; % defines limits for subplots 1-2 
cdiffmax = 3.5; % defines limits for subplots 3-8

% - Set plot appearances
ylgnbunow = cbrewer('seq','YlGnBu',15,'linear'); % colormap for subplots 1-2
rdylbunow = flipud(cbrewer('div','PuOr',15,'linear')); % colormap for subplots 3-8
rdylbunow(8,:) = [1.0000    1.0000    0.7490];
eezlinecolor = [0.4 0.4 0.4]; % eez outline color
eezlinewidth = 1.5; % eez outline line width
mapproj = 'gall-peters'; % map projection
coastlinewidth = 1; % coastline line width
landcolor = [0.6 0.6 0.6]; % land color

% - Define statistical significance stippling
stipsignif = 1;
alphafdr = 0.1; % desired false discovery rate
stipms = 8; % stippling marker size
stipea = 0.5; % stippling marker edge alpha

% - Define lon/lat limits and ticks to plot
wlon = 100; elon = 285;
lonticks = [120 160 200 240 280];
slat = -22.5;nlat = 22.5;
latticks = [-20 -10 0 10 20];

% - Define how many stdevs to plot
numstdevs = 1;

% - Define plot depth levels

% -->If ndims(varnow)==3
% (N.B.: 2dvar(:,:,1) is same as 2dvar) 
%plotdepths = 1;

% --> If ndims(varnow)==4
% (N.B.: depth([11 21 23]) = 50 100 150, units of m) 
plotdepths = [11 21];

%--------------------------------------
% Plot
%--------------------------------------
f=figure;
set(f,'color','white','units','inches','position',[0 0 9 8],'resize','off'); % use this

isp = 1;
for idepth = plotdepths

    %--------------------------------------
    % Calculate plot variables
    %--------------------------------------
    varnow = eval(varname);
    varannow = eval([varname 'anwod']);
 
    if ndims(varnow)==4
        % lon,lat,depth,time --> lon,lat,time
        varnow = squeeze(eval([varname '(:,:,idepth,:)']));
        varannow = squeeze(varannow(:,:,idepth,:));
    end

    varmean = nanmean(varnow,3);
    varanstdev = nanstd(varannow,[],3);
    varanenoni = nanmean(varannow(:,:,onien==1),3);
    varanlnoni = nanmean(varannow(:,:,oniln==1),3);

    %--------------------------------------
    % Calculate and plot significance
    %--------------------------------------
    if stipsignif==1

        varenlnmap_wrspvals = nan(length(lon),length(lat));
        varenlnmap_wrsh01 = nan(length(lon),length(lat));
        for ilon = 1:length(lon)
            for ilat = 1:length(lat)
                ennow = reshape(squeeze(varannow(ilon,ilat,onien==1)),1,[]);
                ennow = ennow(~isnan(ennow));
                lnnow = reshape(squeeze(varannow(ilon,ilat,oniln==1)),1,[]);
                lnnow = lnnow(~isnan(lnnow));
                if length(ennow)>0 & length(lnnow)>0
                    [varenlnmap_wrspvals(ilon,ilat),varenlnmap_wrsh01(ilon,ilat)] = ranksum(ennow,lnnow);
                end
            end
        end

        varenlnmap_wrspvalsnow = varenlnmap_wrspvals(plon<=elon&plon>=wlon,plat<=nlat&plat>=slat);
        varenlnmap_wrspvalsnow_sorted = sort(reshape(varenlnmap_wrspvalsnow(~isnan(varenlnmap_wrspvalsnow)),1,[]));
        N=numel(varenlnmap_wrspvalsnow_sorted);
        %figure; plot(1:N,alphafdr*(1:N)/N); hold on; plot(1:N, varenlnmap_wrspvalsnow_sorted);
        pfdr_varenlnmap_wrs = varenlnmap_wrspvalsnow_sorted( find( varenlnmap_wrspvalsnow_sorted>=(alphafdr*(1:N)/N) ,1) );

    end % end if stipsignif

    %--------------------------------------
    % Main plot
    %--------------------------------------

    %--------Mean subplot
    ax1sp=subplot(4,2,isp);
    colormap(ax1sp,ylgnbunow);
    set(ax1sp,'fontweight','bold');

    ax1=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
        'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;
    m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);

    m_pcolor(plon,plat,varmean');

    m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',10);
    if climsdefined==1; caxis(cminmax); end
    c=colorbar; set(c,'ticklength',0.05,'tickdirection','out'); shading flat;
    c.Label.String = ['[' varunits ']'];
    c.Label.FontSize = 9;
    m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat
    tightmap;

    title(['Mean ' longname ' (' num2str(depth(idepth)) ' m)']);

    %--------Stdev subplot
    ax2sp=subplot(4,2,isp+2);
    colormap(ax2sp,ylgnbunow);
    set(ax2sp,'fontweight','bold');

    ax2=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
      'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;
    m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);

    m_pcolor(plon,plat,varanstdev');

    m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',10);
    if climsdefined==0; cdiffmax = max(max(abs(numstdevs*varanstdev))); end
    caxis([0 cdiffmax]);
    c=colorbar; set(c,'ticklength',0.05,'tickdirection','out'); shading flat;
    c.Label.String = ['[' varunits ']'];
    c.Label.FontSize = 9;
    m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat
    tightmap;

    title(['Monthly Anomalies: ' num2str(numstdevs) '\sigma']);

    %--------EN-mean subplot
    ax3sp=subplot(4,2,isp+4);
    colormap(ax3sp,rdylbunow);
    set(ax3sp,'fontweight','bold');

    ax3=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
      'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;
    m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);

    m_pcolor(plon,plat,varanenoni'); hold on;

    if stipsignif==1
        for ilon = 1:length(plon)
            for ilat = 1:length(plat)
                if varenlnmap_wrspvals(ilon,ilat)<pfdr_varenlnmap_wrs
                    m_scatter(lon(ilon),lat(ilat),'sizedata',stipms,...
                        'MarkerEdgeColor','k','MarkerEdgeAlpha',stipea);
                end
            end
        end
    end

    m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',10);
    if climsdefined==0; cdiffmax = max(max(abs(varanenoni))); end
    caxis([-cdiffmax cdiffmax]); c=colorbar; set(c,'ticklength',0.05,'tickdirection','out'); shading flat;
    c.Label.String = ['[' varunits ']'];
    c.Label.FontSize = 9;
    m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat
    tightmap;

    title('Monthly Anomalies: El Nino');

    %--------LN-mean subplot
    ax4sp=subplot(4,2,isp+6);
    colormap(ax4sp,rdylbunow);
    set(ax4sp,'fontweight','bold');

    ax4=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
      'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;
    m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);

    m_pcolor(plon,plat,varanlnoni'); hold on;

    if stipsignif==1
        for ilon = 1:length(plon)
            for ilat = 1:length(plat)
                if varenlnmap_wrspvals(ilon,ilat)<pfdr_varenlnmap_wrs
                    m_scatter(lon(ilon),lat(ilat),'sizedata',stipms,...
                        'MarkerEdgeColor','k','MarkerEdgeAlpha',stipea);
                end
            end
        end
    end

    m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',10);
    if climsdefined==0; cdiffmax = max(max(abs(varanlnoni))); end
    caxis([-cdiffmax cdiffmax]); c=colorbar; set(c,'ticklength',0.05,'tickdirection','out'); shading flat;
    c.Label.String = ['[' varunits ']'];
    c.Label.FontSize = 9;
    m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat
    tightmap;

    title('Monthly Anomalies: La Nina');

    isp = isp+1; 

end % end plotdepths for loop

%--------Save out figure
print('suppfig3','-dpng');

%--------ADDITIONAL FEATURES ADDED IN POWERPOINT
% AFTER GENERATING THE FIGURES WERE:
% 1.) Pointy ends of colorbars whenever the plotted data
% was out of range of the colorbar
