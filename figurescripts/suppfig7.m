% Plot data availability of two variables
% over mutiple regions at one time

%--------------------------------------
% Define plot variables and regions
%--------------------------------------
varnums=[1 3]; % Var nums: 1=temp, 2=sal, 3=po2
varshortnames = {'Temp{\color{white}_0}','pO_2'};
varlongnames = {'Temperature','Oxygen Partial Pressure'};
varunits = 'Number of Measurements';

regnow = [17 18]; % see regnames to choose regnow numbers 

%--------------------------------------
% Define plotting parameters and appearance
%--------------------------------------
definemaxxlims = 0; % use automatic range = 0, specify range = 1
xmin = []; xmax = [];

plotdepthidxs = find(depth<=300); % define depth range to plot

%--------------------------------------
% Mean, EN, LN
%--------------------------------------
f=figure;
set(f,'color','white','units','inches','position',[0.5 0.5 10 7],'resize','off');

% - EN/LN data pts subplots
ispx = 1;
for ireg = regnow 

    oninow = statids_regs{ireg}(:,6)';
    oniennow = statids_regs{ireg}(:,7)';
    onilnnow = statids_regs{ireg}(:,8)';

    var1rpregnow = squeeze(rawprofs_regs{ireg}(:,varnums(1),:));
    var1npreg_enoninow=sum(~isnan(var1rpregnow(:,oniennow==1)),2);
    var1npreg_lnoninow=sum(~isnan(var1rpregnow(:,onilnnow==1)),2);

    var2rpregnow = squeeze(rawprofs_regs{ireg}(:,varnums(2),:));
    var2npreg_enoninow=sum(~isnan(var2rpregnow(:,oniennow==1)),2);
    var2npreg_lnoninow=sum(~isnan(var2rpregnow(:,onilnnow==1)),2);
    
    ax=subplot(2,length(regnow),ispx);

    h5=plot(var1npreg_enoninow(plotdepthidxs),depth(plotdepthidxs),'r','linewidth',2);
    hold on;
    h6=plot(var1npreg_lnoninow(plotdepthidxs),depth(plotdepthidxs),'b','linewidth',2); 
    h7=plot(var2npreg_enoninow(plotdepthidxs),depth(plotdepthidxs),'r:','linewidth',2);
    h8=plot(var2npreg_lnoninow(plotdepthidxs),depth(plotdepthidxs),'b:','linewidth',2); 
    axis tight;
    title(regnames{ireg});
    if definemaxxlims==1; xlim([xmin(ireg) xmax(ireg)]); end;
    grid on;
    set(ax,'YDir','reverse','YMinorTick','on','XMinorTick','on','TickLength',[0.03, 0.005]); 
    ylabel('Depth [m]'); xlabel('# of Measurements during El Nino/La Nina');

    if ispx==length(regnow)
        lh1=legend([h5 h6 h7 h8],['EN ' varshortnames{1}],['LN ' varshortnames{1}],['EN ' varshortnames{2}],['LN ' varshortnames{2}],'location','southeast');
        set(lh1,'edgecolor','white');
    end

    ispx = ispx+1;
end

% - Total data pts subplots
ispx = 1;
for ireg = regnow
    var1rpregnow = squeeze(rawprofs_regs{ireg}(:,varnums(1),:));
    var2rpregnow = squeeze(rawprofs_regs{ireg}(:,varnums(2),:));
    var1npreg_totnow = sum(~isnan(var1rpregnow),2);
    var2npreg_totnow = sum(~isnan(var2rpregnow),2);

    ax=subplot(2,length(regnow),ispx+length(regnow));

    h4=plot(var1npreg_totnow(plotdepthidxs),depth(plotdepthidxs),'k','linewidth',2); hold on;
    h5=plot(var2npreg_totnow(plotdepthidxs),depth(plotdepthidxs),'k:','linewidth',2); hold on;
    axis tight;
    title(regnames{ireg});
    if definemaxxlims==1; xlim([xmin(ireg) xmax(ireg)]); end;
    grid on; 
    set(ax,'YDir','reverse','YMinorTick','on','XMinorTick','on','TickLength',[0.03, 0.005]);
    ylabel('Depth [m]'); xlabel('Total # of Measurements');

    if ispx==length(regnow)
        lh1=legend([h4 h5],[varshortnames{1}],[varshortnames{2}],'location','southeast');
        set(lh1,'edgecolor','white');
    end

    ispx = ispx+1;
end

%--------Save out figure
print('suppfig7','-dpng');
