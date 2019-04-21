%-------------------------------------
% Choose regions and variables to analyze
%-------------------------------------
clear regnow;
regnow = [17 18]; % see regnames to choose regions

yvarnamesbeg = 'thd';
yvarnamesend = 'thdrp';
yvarunits = 'm';
yvarnameslong = 'Tuna Hypoxic Depth';

xvarnamebeg = 'tcd';
xvarnameend = 'tcdrp';
xvarunits = 'm';
xvarnamelong = 'Thermocline Depth';

%-------------------------------------
% Choose data filters
%-------------------------------------
enufdataonly = 1; % 1 = use profs w/ enuf data only, applies to thd only

%--------------------------------------
% Analyze and print output
%--------------------------------------
disp('---------MAIN TABLE 1---------');
disp('(EN = El Nino mean composite, LN = La Nina mean composite');
for ireg = regnow 

    yvaranpmeannow = eval([yvarnamesbeg 'rpanpmeanwod_regs{ireg}.' yvarnamesend]);
    yvarrawnow = eval([yvarnamesbeg 'rp_regs{ireg}.' yvarnamesend]);
    ydepthvarfrommeanprofnow = eval([yvarnamesbeg 'rpmean_fromwodmeanprof_regs(ireg)']);

    xvaranpmeannow = eval([xvarnamebeg 'rpanpmeanwod_regs{ireg}.' xvarnameend]);
    xvarrawnow = eval([xvarnamebeg 'rp_regs{ireg}.' xvarnameend]);
    xdepthvarfrommeanprofnow = eval([xvarnamebeg 'rpmean_fromwodmeanprof_regs(ireg)']);

    % only take thd calculated from po2 profiles w/ enough data points
    if strcmp(yvarnamesbeg,'thd') & (enufdataonly==1)
        yvaranpmeannow_enufdata = eval([yvarnamesbeg 'rpanpmeanwod_regs{ireg}.enufdata']);
        yvaranpmeannow(~isnan(yvaranpmeannow_enufdata)) = nan;
        yvarrawnow_enufdata = eval([yvarnamesbeg 'rp_regs{ireg}.enufdata']);
        yvarrawnow(~isnan(yvarrawnow_enufdata)) = nan;
        % see thdrp_enufdatanames for enufdata #s (anything nan is good)
    end

    oninow = statids_regs{ireg}(:,6);
    oniennow = statids_regs{ireg}(:,7);
    onilnnow = statids_regs{ireg}(:,8);
    onimodennow = logical(oniennow); 
    onimodlnnow = logical(onilnnow); 

    xvarmeannow = nanmean(xvarrawnow); 
    yvarmeannow = nanmean(yvarrawnow); 
    
    xvarnow = xvaranpmeannow; 
    yvarnow = yvaranpmeannow; 

    % - Test for signif diffs btwn EN and LN
    xvarenlnwrspvalnow = ranksum(xvarnow(onimodennow), xvarnow(onimodlnnow));
    yvarenlnwrspvalnow = ranksum(yvarnow(onimodennow), yvarnow(onimodlnnow));

    % - Display mean, comp, alpha values
    disp(regnames{ireg});

    disp([xvarnamebeg ' Mean (' xvarunits '): ' num2str(xvarmeannow)]);
    disp([yvarnamesbeg ' Mean (' yvarunits '): ' num2str(yvarmeannow)]);
    
    disp([xvarnamebeg ' EN (' xvarunits '): ' num2str(nanmean(xvarnow(onimodennow)))]);
    disp([xvarnamebeg ' EN-mean (%): ' num2str(100*(nanmean(xvarnow(onimodennow))-xvarmeannow)/xvarmeannow)]);
    disp([xvarnamebeg ' LN (' xvarunits '): ' num2str(nanmean(xvarnow(onimodlnnow)))]);
    disp([xvarnamebeg ' LN-mean (%): ' num2str(100*(nanmean(xvarnow(onimodlnnow))-xvarmeannow)/xvarmeannow)]);

    disp([yvarnamesbeg ' EN (' yvarunits '): ' num2str(nanmean(yvarnow(onimodennow)))]);
    disp([yvarnamesbeg ' EN-mean (%): ' num2str(100*(nanmean(yvarnow(onimodennow))-yvarmeannow)/yvarmeannow)]);
    disp([yvarnamesbeg ' LN (' yvarunits '): ' num2str(nanmean(yvarnow(onimodlnnow)))]);
    disp([yvarnamesbeg ' LN-mean (%): ' num2str(100*(nanmean(yvarnow(onimodlnnow))-yvarmeannow)/yvarmeannow)]);

    disp([xvarnamebeg ' EN/LN wrs pval:' num2str(xvarenlnwrspvalnow)]);
    disp([yvarnamesbeg ' EN/LN wrs pval:' num2str(yvarenlnwrspvalnow)]);

    B = [nanmean(yvarnow(onimodennow)) nanmean(yvarnow(onimodlnnow))];
    A = [nanmean(xvarnow(onimodennow)) nanmean(xvarnow(onimodlnnow))];
    m = (B(2)-B(1))/(A(2)-A(1)); n = B(2) - A(2)*m;
    disp(['ENSO-driven rc: ' num2str(m)]);

    % - Robust least squares
    xymat=zeros(length(xvarnow),2);
    xymat(:,1)=xvarnow'; xymat(:,2)=yvarnow';
    xymat = xymat(~any(isnan(xymat),2),:); % remove any rows with NaNs
    [rf,stats] = robustfit(xymat(:,1),xymat(:,2));
    % To calculate R^2, see:
    % https://stats.stackexchange.com/questions/83826/is-a-weighted-r2-in-robust-linear-model-meaningful-for-goodness-of-fit-analys
    % AND Willett and Singer (1988) "Another Cautionary Note about R-squared:
    % It's use in weighted least squates regression analysis."
    % The American Statistician. 42(3). pp236-238. 
    SSe = sum(stats.resid.^2);
    SSt = sum((xymat(:,2)-mean(xymat(:,2))).^2);
    R2pwls = 1-SSe/SSt; % pseudo weighted least sq R^2
    disp(['Raw rc, robust regression: ' num2str(rf(2))]);
    disp(['R2, psuedo wls: ' num2str(R2pwls)]);
end
disp('------------------------------');
