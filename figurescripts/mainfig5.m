% WARNING: Parts of this script are pretty hard-coded
% for 9 countries+epboxes and 3 category types (el nino, mean, la nina)
% --> hard-coded lines are labeled w/ '% hard-coded' at the end

%-------------------------------------
% Choose variable to plot
%-------------------------------------
varnamesbeg = 'thd';
varnamesend = 'thdrp';
varnameslong = 'Tuna Hypoxic Depth';

%-------------------------------------
% Choose plot appearance/parameters and data filters
%-------------------------------------
ylimdef = 1; % use automatic range = 0, specify range = 1
ymin = 78; ymax = 227;

labor='horizontal'; plotsty = 'compact'; vertlineson = 0;
whiskerval = 0; % choose 0 (off) or 1.5 (on)
ncattypes = 3; % 3 = el nino, mean, la nina

enufdatafilter = 'filterall'; % choose: 'filterall', 'keepall' 

testsignif = 1;
alphafdr = 0.05;

clear regnow reglabels;

% Ordering from west to east (ish):
% Palau, FSM, PNG, Solomon Islands, Nauru, Marshall Islands, Tuvalu, Kiribati
regnow = [5 1 6 7 4 3 8 2 17]; % see regnames to choose regnow numbers
reglabels = {'','PLW','', '','FSM','', '','PNG','', '','SLB','', ...
    '','NRU','', '','MHL','', '','TUV','', '','KIR','', '','WEP',''};

%-------------------------------------
% Compute plot variables  
%-------------------------------------
plotarraynow = []; grpnumnow = []; numvals = [];
meannow = nan(1,ncattypes*length(regnow));
meanrelchangenow = nan(1,ncattypes*length(regnow));
if testsignif==1
    pvalsnow = nan(1,length(regnow));
end

ireg = 1;
for iregenln = 1:ncattypes:(ncattypes*length(regnow))
    oninow = statids_regs{regnow(ireg)}(:,6);
    oniennow = statids_regs{regnow(ireg)}(:,7);
    onilnnow = statids_regs{regnow(ireg)}(:,8);

    varbegnow = eval([varnamesbeg 'rp_regs{regnow(ireg)}']);
    varnow = eval([varnamesbeg 'rp_regs{regnow(ireg)}.' varnamesend]);
    varanpmeanbegnow = eval([varnamesbeg 'rpanpmeanwod_regs{regnow(ireg)}']);
    varanpmeannow = eval([varnamesbeg 'rpanpmeanwod_regs{regnow(ireg)}.' varnamesend]);

    if (strcmp(varnamesbeg,'thd')) & strcmp(enufdatafilter,'filterall')
        enufdatavarnow = varbegnow.enufdata';
        varrpnow = varnow(isnan(enufdatavarnow));
        enufdatavaranpmeannow = varanpmeanbegnow.enufdata';
        varrpanpmeanenoni05now = varanpmeannow(oniennow==1 & isnan(enufdatavaranpmeannow));
        varrpanpmeanlnoni05now = varanpmeannow(onilnnow==1 & isnan(enufdatavaranpmeannow));
    else
        varrpnow = varnow;
        varrpanpmeanenoni05now = varanpmeannow(oniennow==1);
        varrpanpmeanlnoni05now = varanpmeannow(onilnnow==1);
    end

    if testsignif==1 % test if EN and LN are signif diff
        if (sum(~isnan(varrpanpmeanenoni05now))>1) & (sum(~isnan(varrpanpmeanlnoni05now))>1)
            pvalsnow(ireg) = ranksum(varrpanpmeanenoni05now,varrpanpmeanlnoni05now); 
        end
    end

    if length(varrpanpmeanenoni05now)==0; varrpanpmeanenoni05now = nan; end;
    if length(varrpnow)==0; varrpnow = nan; end;
    if length(varrpanpmeanlnoni05now)==0; varrpanpmeanlnoni05now = nan; end;

    plotarraynow = [plotarraynow varrpanpmeanenoni05now varrpnow varrpanpmeanlnoni05now];
    numvals(iregenln) = length(varrpanpmeanenoni05now);
    numvals(iregenln+1) = length(varrpnow);
    numvals(iregenln+2) = length(varrpanpmeanlnoni05now);

    meannow(iregenln:(iregenln+ncattypes-1)) = ...
        [nanmean(varrpanpmeanenoni05now) nanmean(varrpnow) nanmean(varrpanpmeanlnoni05now)]; 
    meanrelchangenow(iregenln) = 100*(nanmean(varrpanpmeanenoni05now)-nanmean(varrpnow))...
        /nanmean(varrpnow);
    meanrelchangenow(iregenln+ncattypes-1) = 100*(nanmean(varrpanpmeanlnoni05now)-nanmean(varrpnow))...
        /nanmean(varrpnow);

    grpnumnow = [grpnumnow iregenln*ones(1,numvals(iregenln)) (iregenln+1)*ones(1,numvals(iregenln+1)) (iregenln+2)*ones(1,numvals(iregenln+2))];
    ireg = ireg + 1;
end

%-------------------------------------
% Plot
%-------------------------------------
enpositions = 1:(max(grpnumnow)/ncattypes);
meanpositions = enpositions+0.11; % hard-coded
lnpositions = enpositions+0.22; % hard-coded
allpositions = nan(1,max(grpnumnow));
allpositions(1:ncattypes:end) = enpositions; % hard-coded
allpositions(2:ncattypes:end) = meanpositions; % hard-coded
allpositions(3:ncattypes:end) = lnpositions; % hard-coded

f=figure; set(f,'color','white','units','inches','position',[1 1 9 4.5]);
ax=subplot(1,1,1);

% - Plot boxplot
boxplot(plotarraynow,grpnumnow,'plotstyle',plotsty,'symbol','',...
    'colors','rkbrkbrkbrkbrkbrkbrkbrkbrkb','positions',allpositions,...
    'labels',reglabels,'whisker',whiskerval); box off;
set(findobj(gca,'Type','text'),'fontsize',12,'fontweight','bold');
hold on;

% - Plot mean markers
plot(allpositions,meannow,'.','markersize',19,'color',[0.8 0.8 0.8]);
plot(allpositions,meannow,'.','markersize',6,'color','k');

% - Print mean rel changes from mean
enpositionadjs = nan(1,length(enpositions));
ienpos = 1;
for inum = 1:ncattypes:length(meanrelchangenow)
    textnow=num2str(meanrelchangenow(inum),'%.1f%%');
    enpositionadjs(ienpos) = 0.34+0.06*length(textnow); % hard-coded 
    ienpos = ienpos+1;
end
lnpositionadjs = nan(1,length(lnpositions));
ilnpos = 1;
for inum = ncattypes:ncattypes:length(meanrelchangenow)
    textnow=num2str(meanrelchangenow(inum),'%.1f%%');
    lnpositionadjs(ilnpos) = -0.2+0.06*length(textnow); % hard-coded 
    ilnpos = ilnpos+1;
end
text(enpositions-enpositionadjs,meannow(1:ncattypes:end),... 
    num2str(meanrelchangenow(1:ncattypes:end)','%.1f%%'),...
    'fontsize',8,'color','r','fontweight','bold'); % fontsize hard-coded
text(lnpositions+lnpositionadjs,meannow(ncattypes:ncattypes:end),... 
    num2str(meanrelchangenow(ncattypes:ncattypes:end)','%.1f%%'),...
    'fontsize',8,'color','b','fontweight','bold'); % fontsize hard-coded

% - Star EEZ names w/ signif diff EN and LN vars
if testsignif==1
    sortedpvalsnow = sort(pvalsnow);
    N = numel(sortedpvalsnow);
    %figure; plot(1:N,alphafdr*(1:N)/N); hold on; plot(1:N, sortedpvalsnow);
    pfdrnow = sortedpvalsnow( find( sortedpvalsnow>=(alphafdr*(1:N)/N) ,1) );
    for ireg = 1:length(pvalsnow)  
        if pvalsnow(ireg)<pfdrnow
            plot(meanpositions(ireg),ymax-4,'k*'); % hard-coded
        end
    end
end

ax.XAxis.Visible = 'off'; % remove x-axis
xlim([0 max(grpnumnow)/ncattypes+1]);
if ylimdef==1
    ylim([ymin ymax]);
end
ylabel('Depth [m]','fontsize',11);
grid on;
set(gca,'YDir','reverse','fontsize',10,'fontweight','bold');

disp('Number of profiles:')
numvals
disp('p-vals, WRS EN vs. LN:')
pvalsnow
disp('Means:')
meannow

%--------Save out figure
print('mainfig5','-dpng');

%--------ADDITIONAL FEATURES ADDED
% AFTER GENERATING THE FIGURES WERE:
% 1.) Legend
% 2.) Number of profiles
% 3.) Shifting the mean relative change
% labels slightly to avoid overlap
