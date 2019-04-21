%--------------------------------------
% Define plot appearance
%--------------------------------------
markersize = 6;
linewidth = 1.5;
dashedlw = 1;

%--------------------------------------
% Separate El Nino/La Nina times 
%--------------------------------------
oniennow = nan(size(onien)); oniennow(logical(onien)) = oni(logical(onien));
onitimeen = nan(size(onitime)); onitimeen(logical(onien)) = onitime(logical(onien));
endotidx = strfind(onien',[0 1 0])+1;
if strfind(onien(end-1:end)',[0 1])==1
    endotidx = [endotidx length(onien)];
end
if strfind(onien(1:2)',[1 0])==1
    endotidx = [1 endotidx];
end

onilnnow = nan(size(oniln)); onilnnow(logical(oniln)) = oni(logical(oniln));
onitimeln = nan(size(onitime)); onitimeln(logical(oniln)) = onitime(logical(oniln));
lndotidx = strfind(oniln',[0 1 0])+1;
if strfind(oniln(end-1:end)',[0 1])==1
    lndotidx = [lndotidx length(oniln)];
end
if strfind(oniln(1:2)',[1 0])==1
    lndotidx = [1 lndotidx];
end

%--------------------------------------
% Plot
%--------------------------------------
f=figure;
set(f,'color','white','units','inches','position',[0.5 0.5 8.5 4.5],'resize','off');

h1=plot(onitime,oni,'linewidth',linewidth,'color','k'); hold on;

plot(onitime(endotidx),oniennow(endotidx),'.','markersize',markersize,'color','r');
h2=plot(onitimeen,oniennow,'linewidth',linewidth,'color','r');
plot(onitime(lndotidx),onilnnow(lndotidx),'.','markersize',markersize,'color','b');
h3=plot(onitimeln,onilnnow,'linewidth',linewidth,'color','b');

plot([onitime(1) onitime(end)],[0.5 0.5],'k--','linewidth',dashedlw);
plot([onitime(1) onitime(end)],[-0.5 -0.5],'k--','linewidth',dashedlw);

set(gca,'XTick',timeyrWOD(1:2:end),'XTickLabelRotation',90,'YMinorTick','on','xgrid','on');
xlim([onitime(1) onitime(end)]);
ylim([-2.75 2.75]);
title('Monthly Oceanic Nino Index (ONI)');
xlabel('Year');
ylabel('ONI [°C]');
[~,lh]=legend([h2 h3],{'El Nino Months','La Nina Months'},'Location','South','Orientation','Horizontal','edgecolor','w');
set(findobj(lh,'-property','MarkerSize'),'MarkerSize',25);

%--------Save out figure
print('suppfig2','-dpng');
