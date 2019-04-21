%--------------------------------------
% Define plot variables and parameters
%--------------------------------------
% - Choose the figure you want to plot
fignamenow = 'mainfig2'; % choose btwn: 'mainfig2','suppfig4'

if strcmp(fignamenow,'mainfig2')

    % MAIN FIGURE 2:
    varname = 'thd';
    varunits = 'm';
    longname = 'Tuna Hypoxic Depth';
    
    % - Define colorbar ranges
    climsdefined = 1; % use automatic range = 0, specify range = 1
    cminmax = [0 400]; % defines limits for subplot 1
    cdiffmax = 25; % defines limits for subplots 2-3
    relchon = 1; % subplots 2-3 show absolute changes = 0, relative changes = 1 

elseif strcmp(fignamenow,'suppfig4')

    % SUPP. FIGURE 4:
    varname = 'tcd';
    varunits = 'm';
    longname = 'Thermocline Depth';
    
    % - Define colorbar ranges
    climsdefined = 1; % use automatic range = 0, specify range = 1
    cminmax = [0 200]; % defines limits for subplot 1
    cdiffmax = 20; % defines limits for subplots 2-3
    relchon = 0; % subplots 2-3 show absolute changes = 0, relative changes = 1 
end

% THE REST APPLIES TO BOTH MAIN FIG 2 AND SUPP FIG 4 (ALL OF THE ABOVE):

% - Set plot appearances
ylgnbunow = cbrewer('seq','YlGnBu',11,'linear'); % colormap for subplot 1
rdylbunow = cbrewer('div','PuOr',11,'linear'); % colormap for subplots 2-3
rdylbunow(6,:) = [1.0000    1.0000    0.7490];
eezltlinecolor = [0.6 0.6 0.6]; % eez light outline color
eezdklinecolor = [0.3 0.3 0.3]; % eez dark outline color
eezltlinewidth = 1.5; % eez light outline line width
eezdklinewidth = 1.5; % eez dark outline line width
mapproj = 'gall-peters'; % map projection
coastlinewidth = 1; % coastline line width
landcolor = [0.6 0.6 0.6]; % land color

% - Define statistical significance stippling
alphafdr = 0.1; % desired false discovery rate
stipms = 8; % stippling marker size
stipea = 0.5; % stippling marker edge alpha

% - Define lon/lat limits and ticks to plot
wlon = 100; elon = 285;
lonticks = [120 160 200 240 280];
slat = -22.5; nlat = 22.5;
latticks = [-20 -10 0 10 20];

%--------------------------------------
% Calculate plot variables
%--------------------------------------
varnow = eval(varname);
varmean = nanmean(varnow,3);
varannow = eval([varname 'anwod']);
varanenoni = nanmean(varannow(:,:,onien==1),3);
varanlnoni = nanmean(varannow(:,:,oniln==1),3);

%--------------------------------------
% Calculate significance
%--------------------------------------
varenlnmap_wrspvals = nan(length(lon),length(lat));
for ilon = 1:length(lon)
    for ilat = 1:length(lat)
        ennow = reshape(squeeze(varannow(ilon,ilat,onien==1)),1,[]);
        lnnow = reshape(squeeze(varannow(ilon,ilat,oniln==1)),1,[]);
        ennow = ennow(~isnan(ennow));
        lnnow = lnnow(~isnan(lnnow));
        if length(ennow)>0 & length(lnnow)>0
            [~,varenlnmap_ttest2pvals(ilon,ilat)] = ttest2(ennow,lnnow);
            [varenlnmap_wrspvals(ilon,ilat),~] = ranksum(ennow,lnnow);
        end
    end
end
varenlnmap_wrspvalsnow = varenlnmap_wrspvals(plon<=elon&plon>=wlon,plat<=nlat&plat>=slat);
varenlnmap_wrspvalsnow_sorted = sort(reshape(varenlnmap_wrspvalsnow(~isnan(varenlnmap_wrspvalsnow)),1,[]));
N=numel(varenlnmap_wrspvalsnow_sorted);
%figure; plot(1:N,alphafdr*(1:N)/N); hold on; plot(1:N, varenlnmap_wrspvalsnow_sorted);
pfdr_varenlnmap_wrs = varenlnmap_wrspvalsnow_sorted( find( varenlnmap_wrspvalsnow_sorted>=(alphafdr*(1:N)/N) ,1) );

%--------------------------------------
% Plot
%--------------------------------------
f=figure;
set(f,'color','white','units','inches','position',[0 0 6 8],'resize','off');

%--------Mean subplot
ax1sp=subplot(3,1,1);
colormap(ax1sp,ylgnbunow);
set(ax1sp,'fontweight','bold');

ax1=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
  'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;
m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);

m_pcolor(plon,plat,varmean');

m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',12);

if climsdefined==1; caxis(cminmax); end
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out'); shading flat;
c.Label.String = ['[' varunits ']'];
c.Label.FontSize = 9;

m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat

% - Contour WEP/EEP boxes
hold on; mcontourWEPEEP;
text(-0.32,0.2,'WEP','fontsize',13);    
text(0.63,0.2,'EEP','fontsize',13);    

tightmap;

title(['Mean ' longname]);

%--------(EN anomalies)/mean subplot
ax2sp=subplot(3,1,2);
colormap(ax2sp,rdylbunow);
set(ax2sp,'fontweight','bold');

ax2=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
  'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;
m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);

if relchon==1
    var_enmeanoninow = 100*varanenoni./varmean;
elseif relchon==0
    var_enmeanoninow = varanenoni;
end

m_pcolor(plon,plat,var_enmeanoninow');

% - Stipple significance
for ilon = 1:length(plon)
    for ilat = 1:length(plat)
        if varenlnmap_wrspvals(ilon,ilat)<pfdr_varenlnmap_wrs
            m_scatter(lon(ilon),lat(ilat),'sizedata',stipms,...
                'MarkerEdgeColor','k','MarkerEdgeAlpha',stipea);
        end
    end
end

m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',12);

if climsdefined==0; cdiffmax = max(max(abs(var_enmeanoninow))); end
caxis([-cdiffmax cdiffmax]);
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out','YTick',linspace(-cdiffmax,cdiffmax,5)); shading flat;
if relchon==0
    c.Label.String = ['[' varunits ']'];
elseif relchon==1
    c.Label.String = '[%]';
end
c.Label.FontSize = 9;

m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat

tightmap;

if relchon==1
    title('Relative Monthly Anomalies: El Nino');
elseif relchon==0
    title('Monthly Anomalies: El Nino');
end

%--------(LN anomalies)/mean or LN anomalies subplot
ax3sp=subplot(3,1,3);
colormap(ax3sp,rdylbunow);
set(ax3sp,'fontweight','bold');

ax3=axesm('gortho','MapLatLimit',[slat nlat],'MapLonLimit',[wlon elon],...
  'Frame','off','Grid','off','MeridianLabel','off','ParallelLabel','off'); axis off;

m_proj(mapproj,'lon',[wlon elon],'lat',[slat nlat]);

if relchon==1
    var_lnmeanoninow = 100*varanlnoni./varmean;
elseif relchon==0
    var_lnmeanoninow = varanlnoni;
end

m_pcolor(plon,plat,var_lnmeanoninow');

m_grid('xtick',lonticks,'ytick',latticks,'xlabeldir','middle','fontsize',12);

if climsdefined==0; cdiffmax = max(max(abs(var_lnmeanoninow))); end
caxis([-cdiffmax cdiffmax]);
c=colorbar; set(c,'ticklength',0.05,'tickdirection','out','YTick',linspace(-cdiffmax,cdiffmax,5)); shading flat;
if relchon==0
    c.Label.String = ['[' varunits ']'];
elseif relchon==1
    c.Label.String = '[%]';
end
c.Label.FontSize = 9;

% - Contour EEZs
for ireg = 1:length(allpid)
    RR = double(eezmap0pt25==allpid{ireg});
    h1 = m_contour(loneez0pt25,lateez0pt25,RR,[.5 .5],'linecolor',eezltlinecolor,'linewidth',eezltlinewidth);
end
nupidcell = [nupid{:,:}];
for ireg = 1:length(nupidcell)
    RR = double(eezmap0pt25==nupidcell{ireg});
    h2 = m_contour(loneez0pt25,lateez0pt25,RR,[.5 .5],'linecolor',eezdklinecolor,'linewidth',eezdklinewidth);
end

m_coast('patch',landcolor,'edgecolor','k','linewidth',coastlinewidth); % must go after shading flat

tightmap;

if relchon==1
    title('Relative Monthly Anomalies: La Nina');
elseif relchon==0
    title('Monthly Anomalies: La Nina');
end

%--------Save out figure
print(fignamenow,'-dpng');

%--------ADDITIONAL FEATURES ADDED IN POWERPOINT
% AFTER GENERATING THE FIGURES WERE:
% 1.) Pointy ends of colorbars whenever the plotted data
% was out of range of the colorbar
% 2.) Legend
% 3.) Deeper/shallower labels
