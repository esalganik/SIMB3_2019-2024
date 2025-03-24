%% Dataset import (CRREL IMBs 1997-2024)
close all; clear; clc; 
ncvars =  {'time','lat','lon','z','hi','hs','sur','int','bot','T','hi_0','hs_0'}; % Parameters for import
projectdir = 'C:\Users\Evgenii\Documents\MATLAB\SIMB3\Buoy dataset'; % Change the directory to the dataset location
dinfo = dir( fullfile(projectdir, '*.nc') );
num_files = length(dinfo);
filenames = fullfile( projectdir, {dinfo.name} );
label = {dinfo.name};
time = cell(num_files,1); hi = time; hs = time; hi_0 = time; hs_0 = time; T = time; sur = time; int = time;
for K = 1 : num_files
  this_file = filenames{K};
  label{K} = label{K}(1:end-3);
  time{K} = ncread(this_file, ncvars{1}); % days since 1978-09-01
  t_0 = (datetime('01-Sep-1978 00:00')); t{K} = t_0 + days(time{K});
  z{K} = ncread(this_file, ncvars{4});
  hi{K} = ncread(this_file, ncvars{5});
  hs{K} = ncread(this_file, ncvars{6});
  sur{K} = ncread(this_file, ncvars{7});
  int{K} = ncread(this_file, ncvars{8});
  T{K} = ncread(this_file, ncvars{10});
  hi_0{K} = ncread(this_file, ncvars{11});
  hs_0{K} = ncread(this_file, ncvars{12});
end
clearvars ncvars projectdir dinfo filenames num_files this_file K time t_0

%% Figure 1: Validation of initial conditions
figure
for i = 1:length(t)
    name{i} = label{i};
end
tile = tiledlayout(2,1); tile.TileSpacing = 'compact'; tile.Padding = 'none';
load('batlow100.mat');
nexttile
for i = 1:length(t)
    p = plot(hs{i}(1),hs_0{i}(1),'ko','MarkerSize',4,'color',batlow100(i*3,:)); set(p,'markerfacecolor',get(p,'color')); hold on
end
plot([0 0.7],[0 0.7],'k--');
leg = legend(name,'box','off'); set(leg,'FontSize',6,'Location','bestoutside'); leg.ItemTokenSize = [30*0.1,18*0.1];
hXLabel = xlabel('Snow depth, initial, processed (m)'); hYLabel = ylabel('Snow depth, initial, metadata (m)'); set([hXLabel hYLabel gca],'FontSize',7,'FontWeight','normal');
xlim([0 0.7]); ylim([0 0.7]);

nexttile
for i = 1:length(t)
    p = plot(hi{i}(1),hi_0{i}(1),'ko','MarkerSize',4,'color',batlow100(i*3,:)); set(p,'markerfacecolor',get(p,'color')); hold on
end
plot([0 2.5],[0 2.5],'k--');
hXLabel = xlabel('Ice thickness, initial, processed (m)'); hYLabel = ylabel('Ice thickness, initial, metadata (m)'); set([hXLabel hYLabel gca],'FontSize',7,'FontWeight','normal');
xlim([0 2.5]); ylim([0 2.5]);

%% Figure 2: Quicklook
figure
tile = tiledlayout(2,1); tile.TileSpacing = 'compact'; tile.Padding = 'none';
nexttile
load('batlow100.mat'); 
for i = 1:length(t)
    plot(t{i},hs{i},'color',batlow100(i*3,:)); hold on
end
hYLabel = ylabel('Snow depth (m)'); set([ hYLabel gca],'FontSize',8,'FontWeight','normal');
leg = legend(label,'box','off','NumColumns',1); set(leg,'FontSize',6,'Location','bestoutside','orientation','horizontal'); leg.ItemTokenSize = [30*0.33,18*0.33];
nexttile
for i = 1:length(t)
    plot(t{i},hi{i},'color',batlow100(i*3,:)); hold on
end
hYLabel = ylabel('Ice thickness (m)'); set([ hYLabel gca],'FontSize',8,'FontWeight','normal');

%% Figure 3: Example of temperature measuments
figure
i = 2; % selected buoy
dTdz = diff(T{i},1,2);
range = -100:10:100;
contourf(datenum(t{i}),z{i}(1:end-1),dTdz'*50,range,'-','ShowText','off','LabelSpacing',400,'edgecolor','none'); hold on
plot(datenum(t{i}),sur{i},'b:','LineWidth',3); plot(datenum(t{i}),int{i},'r:','LineWidth',3); % Processed interfaces
plot(datenum(t{i}(1)),hs_0{i},'bo','MarkerSize',5); % Initial snow thicknes from metadata
load('batlow.mat'); colormap(batlow); % colormap(parula);
hYLabel = ylabel('Depth (m)'); set([hYLabel gca],'FontSize',8,'FontWeight','normal');
hBar1 = colorbar; ylabel(hBar1,'Vertical temp. grad. (°C/m)','FontSize',7);
name=convertStringsToChars(label{i}); title(sprintf('Vert. temp. gradient (°C/m), %s',name),'FontSize',8,'FontWeight','normal');
leg = legend('','Air-snow','Snow-ice','Initial snow thickness','box','on','NumColumns',1); set(leg,'FontSize',6,'Location','southwest','orientation','horizontal'); leg.ItemTokenSize = [30*0.5,18*0.5];
ylim([round(min(int{i}),1)-0.2 round(max(sur{i}),1)+0.1]);
datetick('x','mmm','keepticks','keeplimits'); xtickangle(0);
