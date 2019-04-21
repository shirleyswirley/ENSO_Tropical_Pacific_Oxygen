% This runall_rawprofs.m MATLAB script
% loads and computes variables for re-creating
% figures and tables in Leung et al. (2019).
% It runs the following figure creation scripts...

% maintable1.m
% mainfig5.m
% suppfig7.m

% ...Thus, creating main table 1, main figure
% 5, and suppplementary figure 7.

clear all;
addpath(genpath('.'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1.) Define filename and grid variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numregs = 16+2; % 16 tropical pacific EEZs and 2 equatorial pacific boxes
reggroupname = 'eastwest16eezsand2epboxes'; % to name data files
eezmapresstr = '0pt25degeezmap'; % to name data files
depth = [0:5:100,125:25:500,550:50:2000,2100:100:5500]';
maxdepth = 5500;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2.) Load and/or compute raw profiles from WOD data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--------------------------
% Load and setup the following variables:
% rawprofs_regs, statids_regs, regnames
%--------------------------
load(['data/WODrawprofs/WOD_rawprofstempsalpo2_195501-201705_' eezmapresstr '_' reggroupname '.mat'],'rawprofs_regs','statids_regs','regnames');
% - rawprofs_regs content:
% col1 = temp, col2 = sal, col3 = po2
% - statids_regs content:
% col1 = lon,  col2 = lat, col3 = year, col4 = month,
% col5 = day, col6 = ONI, col7 = 1 to denote El Nino ONI,
% col8 = 1 to denote La Nina ONI 

numvars = 3; % temp, sal, po2

for ireg = 1:numregs
    rawprofs_regs{ireg} = rawprofs_regs{ireg}(1:find(depth==maxdepth),:,:);
end

%--------------------------
% Compute monthly anomalies. 
% Get the following variables:
% wodanprofs_regs{regnum}
% (dims: depth x variable x profile in region)
% (contents: col1 = temp, col2 = sal, col3 = po2)
%--------------------------
for ireg = 1:numregs
    wodclimprofs_regs{ireg} = nan(size(rawprofs_regs{ireg},1),size(rawprofs_regs{ireg},2),12);
    wodanprofs_regs{ireg} = nan(size(rawprofs_regs{ireg}));
    for imonth = 1:12
        monowidx=find(statids_regs{ireg}(:,4)==imonth);
        for ivar = 1:numvars
            wodclimprofs_regs{ireg}(:,ivar,imonth)=nanmean(rawprofs_regs{ireg}(:,ivar,monowidx),3);
            wodanprofs_regs{ireg}(:,ivar,monowidx) = rawprofs_regs{ireg}(:,ivar,monowidx) - repmat(wodclimprofs_regs{ireg}(:,ivar,imonth),1,1,length(monowidx));
        end
    end
end

%--------------------------
% Compute tuna hypoxic depth.
% Get the following variables:
% tunahypoxicpressure (kPa),
% thdrp_regs{regnum}.thdrp (tuna hypoxic depth, m),
% thdrp_regs{regnum}.proftype (see helperfunctions/rawprofs/calcthd_rawprofs.m for details),
% thdrp_regs{regnum}.enufdata (see helperfunctions/rawprofs/calcthd_rawprofs.m for details),
% thdrpmean_fromwodmeanprof_regs (m),
% thdrpanpmeanwod_regs (m) 
%--------------------------
load(['data/WODrawprofs/WOD_tunahypoxicdepth_195501-201705_rawprofs_' reggroupname '.mat'],'tunahypoxicpressure','thdrp_regs');
% --> Code to calculate variables in the matfile above: 
%tunahypoxicpressure = 15; % kPa
%thdrp_regs = cell(numregs,1);
%for ireg = 1:numregs
%    po2rp = squeeze(rawprofs_regs{ireg}(:,3,:));
%    [thdrp_regs{ireg}.thdrp,thdrp_regs{ireg}.proftype,thdrp_regs{ireg}.enufdata] ...
%        = calcthd_rawprofs(tunahypoxicpressure,po2rp,depth);
%end
%save(['data/WODrawprofs/WOD_tunahypoxicdepth_195501-201705_rawprofs_' reggroupname '.mat'],'tunahypoxicpressure','thdrp_regs','statids_regs','regnames','-v7.3');

load(['data/WODrawprofs/WOD_thdanoms_195501-201705_rawprofs_' reggroupname '.mat'],...
    'po2meanwod_regs','thdrpmean_fromwodmeanprof_regs','thdrpanpmeanwod_regs');
% --> Code to calculate variables in the matfile above: 
%po2meanwod_regs = nan(length(depth),numregs);
%thdrpmean_fromwodmeanprof_regs = nan(1,numregs);
%thdrpanpmeanwod_regs = cell(numregs,1);
%for ireg = 1:numregs
%    po2meanwod_regs(:,ireg)=nanmean(squeeze(rawprofs_regs{ireg}(:,3,:)),2);
%    [thdrpmean_fromwodmeanprof_regs(ireg),~,~] ...
%        = calcthd_rawprofs(tunahypoxicpressure,po2meanwod_regs(:,ireg),depth);
%    po2rp = repmat(po2meanwod_regs(:,ireg),1,...
%        size(squeeze(rawprofs_regs{ireg}(:,3,:)),2))...
%        +squeeze(wodanprofs_regs{ireg}(:,3,:));
%    [thdrpanpmeanwod_regs{ireg}.thdrp,thdrpanpmeanwod_regs{ireg}.proftype,thdrpanpmeanwod_regs{ireg}.enufdata] ...
%        = calcthd_rawprofs(tunahypoxicpressure,po2rp,depth);
%end
%save(['data/WODrawprofs/WOD_thdanoms_195501-201705_rawprofs_' reggroupname '.mat'],...
%    'tunahypoxicpressure','po2meanwod_regs','thdrpmean_fromwodmeanprof_regs','thdrpanpmeanwod_regs','statids_regs','regnames','-v7.3');

%--------------------------
% Compute thermocline depth.
% Get the following variables:
% tcdtype (thermocline depth calculation method),
% tcdrp_regs{regnum}.tcdrp (thermocline depth, m),
% tcdrp_regs{regnum}.proftype (see helperfunctions/rawprofs/calctcd_rawprofs.m for details),
% tcdrpmean_fromwodmeanprof_regs (m),
% tcdrpanpmeanwod_regs (m)
%--------------------------
load(['data/WODrawprofs/WOD_thermoclinedepth_195501-201705_rawprofs_' reggroupname '.mat'],'tcdtype','tcdrp_regs');
% --> Code to calculate variables in the matfile above: 
%tcdtype='varit';
%tcdrp_regs = cell(numregs,1);
%for ireg = 1:numregs
%    temprp = squeeze(rawprofs_regs{ireg}(:,1,:));
%    [tcdrp_regs{ireg}.tcdrp,tcdrp_regs{ireg}.proftype] = calctcd_rawprofs(tcdtype,temprp,depth);
%end
%save(['data/WODrawprofs/WOD_thermoclinedepth_195501-201705_rawprofs_' reggroupname '.mat'],'tcdtype','tcdrp_regs','statids_regs','regnames','-v7.3');

load(['data/WODrawprofs/WOD_tcdanoms_195501-201705_rawprofs_' reggroupname '.mat'],...
    'tempmeanwod_regs','tcdrpmean_fromwodmeanprof_regs','tcdrpanpmeanwod_regs');
% --> Code to calculate variables in the matfile above: 
%tempmeanwod_regs = nan(length(depth),numregs);
%tcdrpmean_fromwodmeanprof_regs = nan(1,numregs);
%tcdrpanpmeanwod_regs = cell(numregs,1);
%for ireg = 1:numregs
%    tempmeanwod_regs(:,ireg)=nanmean(squeeze(rawprofs_regs{ireg}(:,1,:)),2);
%    [tcdrpmean_fromwodmeanprof_regs(ireg),~] = calctcd_rawprofs...
%        (tcdtype,tempmeanwod_regs(:,ireg),depth);
%    temprp = repmat(tempmeanwod_regs(:,ireg),1,...
%        size(squeeze(rawprofs_regs{ireg}(:,1,:)),2))...
%        +squeeze(wodanprofs_regs{ireg}(:,1,:));
%    [tcdrpanpmeanwod_regs{ireg}.tcdrp,tcdrpanpmeanwod_regs{ireg}.proftype] ...
%        = calctcd_rawprofs(tcdtype,temprp,depth);
%end
%save(['data/WODrawprofs/WOD_tcdanoms_195501-201705_rawprofs_' reggroupname '.mat'],...
%    'tcdtype','tempmeanwod_regs','tcdrpmean_fromwodmeanprof_regs','tcdrpanpmeanwod_regs','statids_regs','regnames','-v7.3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3.) Create and save figures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maintable1;
mainfig5;
suppfig7;
