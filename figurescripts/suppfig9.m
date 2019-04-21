%--------------------------------------
% Define plot parameters
%--------------------------------------
% - Set plot appearance
ylgnbunow = cbrewer('seq','YlGnBu',15,'linear'); % colormap for subplots 1-6
rdylbunow = flipud(cbrewer('div','RdYlBu',15,'linear')); % colormap for subplots 7-8
mapproj = 'gall-peters'; % map projection
coastlinewidth = 1; % coastline line width
landcolor = [0.6 0.6 0.6]; % land color

% - Define lon/lat limits and ticks to plot
wlon = 100;elon = 285;
lonticks = [120 160 200 240 280];
slat = -22.5;nlat = 22.5;
latticks = [-20 -10 0 10 20];

%--------------------------------------
% Plot
%--------------------------------------
f=figure;
set(f,'color','white','units','inches','position',[0 0 9 8],'resize','off');

isp = 1;
for icol = 1:2 % 2 columns of subplots

    %--------------------------------------
    % Define plot variables
    %--------------------------------------
    if icol==1
        varname = 'thd';
        varunits = 'Number of months';
        % - Define colorbar ranges
        climsdefined = 1; % use automatic range = 0, specify range = 1 
        cmin = [0 0 0]; cmax = [110 30 30]; % defines limits for subplots 1-6 
        cdiffmax = 15; % defines limits for subplots 7-8
    elseif icol==2
        varname = 'tcd';
        varunits = 'Number of months';
        % - Define colorbar ranges
        climsdefined = 1; % use automatic range = 0, specify range = 1
        cmin = [0 0 0]; cmax = [650 185 185]; % defines limits for subplots 1-6 
        cdiffmax = 41; % defines limits for subplots 7-8
    end
    
    %--------------------------------------
    % Evaluate plot variables
    %--------------------------------------
    varnptot = eval([varname 'nptot']);
    varnp_enoni = eval([varname 'np_enoni']);
    varnp_lnoni = eval([varname 'np_lnoni']);
    
    %--------Mean subplot
    ax1=subplot(4,2,isp);
    colormap(ax1,ylgnbunow);
    
    ax1=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
      'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;
    m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);
    
    m_pcolor(plon,plat,varnptot');
    
    m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',10);
    if climsdefined==1; caxis([cmin(1) cmax(1)]); end
    c=colorbar; set(c,'ticklength',0.05,'tickdirection','out'); shading flat;
    c.Label.String = varunits;
    c.Label.FontSize = 9;
 
    m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat
    tightmap;
    title('Total');
 
    %--------EN subplot
    ax2=subplot(4,2,isp+2);
    colormap(ax2,ylgnbunow);
    
    ax2=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
      'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;
    m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);
    
    m_pcolor(plon,plat,varnp_enoni');
    
    m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',10);
    if climsdefined==1; caxis([cmin(2) cmax(2)]); end
    c=colorbar; set(c,'ticklength',0.05,'tickdirection','out'); shading flat;
    c.Label.String = varunits;
    c.Label.FontSize = 9;
    m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat
    tightmap;

    title('El Nino');
    
    %--------LN subplot
    ax3=subplot(4,2,isp+4);
    colormap(ax3,ylgnbunow);
    
    ax3=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
      'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;
    m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);
    
    m_pcolor(plon,plat,varnp_lnoni');
    
    m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',10);
    if climsdefined==1; caxis([cmin(3) cmax(3)]); end
    c=colorbar; set(c,'ticklength',0.05,'tickdirection','out'); shading flat;
    c.Label.String = varunits;
    c.Label.FontSize = 9;
    m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat
    tightmap;

    title('La Nina');

    %--------EN-LN subplot
    ax4=subplot(4,2,isp+6);
    colormap(ax4,rdylbunow);

    ax4=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
      'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;
    m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);

    m_pcolor(plon,plat,varnp_enoni'-varnp_lnoni');

    m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',10);
    if climsdefined==0; cdiffmax = max(max(abs(varnp_enoni-varnp_lnoni))); end
    caxis([-cdiffmax cdiffmax]);
    c=colorbar; set(c,'ticklength',0.05,'tickdirection','out'); shading flat;
    c.Label.String = varunits;
    c.Label.FontSize = 9;
    m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat
    tightmap;

    title('El Nino - La Nina');

    isp = isp+1;

end % end for loop over vars
    
%--------Save out figure
print('suppfig9','-dpng');

%--------ADDITIONAL FEATURES ADDED IN POWERPOINT
% AFTER GENERATING THE FIGURES WERE:
% 1.) Pointy ends of colorbars whenever the plotted data
% was out of range of the colorbar
% 2.) THD and TCD column titles
