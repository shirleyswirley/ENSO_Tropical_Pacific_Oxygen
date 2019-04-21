% - Set the pO2 value you want to
% see in other oxygen units 
po2now = 15; % kPa

% - Set the depths, temperatures, salinities
% ranges you want to convert pO2 over
depthsnow = [0,150,300]; % m
tempsnow = 10:30; % deg C 
salsnow = 33.5:0.25:35.5; % psu 

% - Convert kPa to ml/l
o2inmllfrompo2 = nan(length(tempsnow),length(salsnow),length(depthsnow));
pottempnow = nan(length(tempsnow),length(salsnow),length(depthsnow));
for idepth = 1:length(depthsnow)
    for isal = 1:length(salsnow)
        for itemp = 1:length(tempsnow)
            pottempnow(itemp,isal,idepth) = ...
                sw_ptmp(salsnow(isal),tempsnow(itemp),depthsnow(idepth),0);
            o2inmllfrompo2(itemp,isal,idepth) = ...
                calco2frompo2(po2now,salsnow(isal),...
                pottempnow(itemp,isal,idepth),depthsnow(idepth));
        end
    end
end

% - Convert ml/l to umol/kg
% (molar volume of O2 = 22.3916 uL/umol)
potdensnow = nan(size(o2inmllfrompo2));
o2inumolkgfrommll = nan(size(o2inmllfrompo2));
for idepth = 1:length(depthsnow)
    for isal = 1:length(salsnow)
        for itemp = 1:length(tempsnow)
            potdensnow(itemp,isal,idepth) = ...
                sw_dens(salsnow(isal),pottempnow(itemp,isal,idepth),0); 
            o2inumolkgfrommll(itemp,isal,idepth) = ...
                o2inmllfrompo2(itemp,isal,idepth)*10^3/22.3916/potdensnow(itemp,isal,idepth)*1000;
        end
    end
end

% - Convert ml/l to mg/l
% (molar mass of O2 = 31.9988 g/mol)
o2inmglfrommll = nan(size(o2inmllfrompo2));
for idepth = 1:length(depthsnow)
    for isal = 1:length(salsnow)
        for itemp = 1:length(tempsnow)
            o2inmglfrommll(itemp,isal,idepth) = ...
                o2inmllfrompo2(itemp,isal,idepth)/22.3916*31.9988;
        end
    end
end

% - Create plots
ylgnbunow = cbrewer('seq','YlGnBu',11,'linear');
f=figure;
set(f,'color','white','units','inches','position',[0 0 12 5],...
    'resize','off');
colormap(ylgnbunow);
cminmax = [3 4.7];
for idepth = 1:length(depthsnow)
    ax1=subplot(1,length(depthsnow),idepth);
    [c,h]=contourf(salsnow,tempsnow,o2inmllfrompo2(:,:,idepth));
    set(h,'LineColor','none')
    caxis(cminmax);
    c=colorbar; set(c,'ticklength',0.02,'tickdirection','out');
    hold on;
    [c,h]=contour(salsnow,tempsnow,o2inumolkgfrommll(:,:,idepth),'color','k');
    clabel(c,h);
    title(['pO_2 = ' num2str(po2now) ' kPa, depth = ' num2str(depthsnow(idepth)) ' m']);
    set(ax1,'YMinorTick','on','XMinorTick','on','TickLength',[0.05, 0.005],'fontsize',10,'fontweight','bold');
end

%--------Save out figure
print('suppfig1abc','-dpng');

%--------ADDITIONAL FEATURES ADDED IN POWERPOINT
% AFTER GENERATING THE FIGURE WERE:
% 1.) Temperature and salinity axis labels
% 2.) Colorbar oxygen unit labels (ml/l)
% 3.) Contour lines oxygen unit labels (umol/kg)
% 4.) Stitching together with Supp. Fig. 1d,e
