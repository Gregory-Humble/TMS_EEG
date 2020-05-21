% 25/2/19
%This script plots TEPs for each subject at F3 (ch 8)
% & group (or individual) Topoplots
% & group TEP with either SEM or 95% CI
% now has GMFA

clear; close all; clc;
eeglabpath = ('C:\Users\grego\Desktop\Matlab_EEGlab_Files\eeglab2019_1');
addpath(eeglabpath);
clearvars;
eeglab;
DataDirCNT = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_CONTROL_clean_2\BL';
SaveDirCNT = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TEPoutput_CONTROL';
DataDirALZ = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_clean_2\BL\leftpfc';
SaveDirALZ = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TEPoutput_ALZ_ALL';
SaveDir =  'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TEPoutput_GROUP_COMPARISONS_ALZHEIMERS_ALL';
inPath = [];
time = {'BL'};
hemi = {'leftpfc'};
%% GROUP TEP
figure(3);
groupchandata = [];
groupdata = [];
data = [];
%% Controls
ch = 5; % 5 = F1 for CONTROLS
cd(SaveDirCNT);
for h = 1:length(hemi);
    for t = 1:size(time,1);
for c = ch; 
    results = ['TEPdata2plot_', time{t,1}, '_', hemi{h}, '_CONTROL.mat'];
    load (results);
    pre_groupchandata = groupdata(c,:,:);
    data = pre_groupchandata;
    linecolour = 'b'; 
    shadingalpha = 0.3;%1/50;
    M = mean(data,3);
    
    %have to load in dataset to get EEG.times vector
    EEG = pop_loadset('filename','102_TMSEEG_BL_leftpfc_ds_ica1_filt_ica2_clean_reref.set','filepath','E:\\Alz_Clinical_Trial\\Alz_Data_Analysis_10JAN20\\TMSEEG\\TMSEEG_CONTROL_clean_2\\BL\\');
    
    figure(3);
    leg1 = plot(EEG.times,M,linecolour);
    hold on
    % 95% CI
    %CI = 1.96*(std(data,0,3)./(sqrt(size(data,3))));
    % SEM
    CI =(std(data,0,3)./(sqrt(size(data,3)))); %% SEM in 3rd dimension; preceding '0' is necessary in std usage
    f = fill([EEG.times,fliplr(EEG.times)],[M-CI,fliplr(M+CI)],linecolour);
    set(f,'FaceAlpha',shadingalpha);
    set(f,'EdgeColor', 'none');
    drawnow;
end
    end
end

clear ALLCOM;
clear ALLEEG;
clear EEG;
clear globalvars;
clear LASTCOM;
hemi = [];
time = [];
h = [];
t = [];
j = [];
clear pre_groupchandata;
clear results;
clear data;
clear groupdata;

%% Alzheiemers
time = {'BL'};
hemi = {'leftpfc'};
ch = 6; % 6 = F1 for ALZHEIEMRS
cd(SaveDirALZ);
for h = 1:length(hemi);
    for t = 1:size(time,1);
for c = ch; 
    results = ['TEPdata2plot_', time{t,1}, '_', hemi{h}, '_ALZHEIMERS_ALL.mat'];
    load (results);
    pre_groupchandata = groupdata(c,:,:);
    data = pre_groupchandata;
    linecolour = 'r'; shadingalpha = 0.3; %1/50;
    M = mean(data,3);
    
    %have to load in dataset to get EEG.times vector
    EEG = pop_loadset('filename','301_TMSEEG_BL_leftpfc_ds_ica1_filt_ica2_clean_reref.set','filepath','E:\\Alz_Clinical_Trial\\Alz_Data_Analysis_10JAN20\\TMSEEG\\TMSEEG_ALZ_clean_2\\BL\\leftpfc\\');
    
    figure(3);
    leg1 = plot(EEG.times,M,linecolour);
    hold on
    % 95% CI
    %CI = 1.96*(std(data,0,3)./(sqrt(size(data,3))));%% 95%CI
    % SEM
    CI =(std(data,0,3)./(sqrt(size(data,3)))); %% SEM in 3rd dimension; preceding '0' is necessary in std usage
    f = fill([EEG.times,fliplr(EEG.times)],[M-CI,fliplr(M+CI)],linecolour);
    set(f,'FaceAlpha',shadingalpha);
    set(f,'EdgeColor', 'none');
    drawnow;
    legend('Controls',['SEM'],'Alzheimers',['SEM'],'Location','bestoutside');   

    toi = [0];
    xlim([-100 500]);
    ylim([-5 5]);
    for j = 1:numel(toi)
        plot([toi(j) toi(j)], get(gca,'ylim'),'k--');
    end
    xlim([-100 500]);
    ylim([-5 5]);
    grid on
    xticks([-100 -50 0 45 60 100 150 200 250 300 350 400 450 500]);
    
end
    end
end
%%

%add opaque rectangles
rectangle('Position', [25, -5, 50, 10], ...
    'FaceColor', [0, 0, 0, 0.05], ...
    'EdgeColor', [0, 0, 0, 0.0]);
rectangle('Position', [85, -5, 60, 10], ...
    'FaceColor', [0, 0, 0, 0.05], ...
    'EdgeColor', [0, 0, 0, 0.0]);
rectangle('Position', [190, -5, 60, 10], ...
    'FaceColor', [0, 0, 0, 0.05], ...
    'EdgeColor', [0, 0, 0, 0.0]);
title('Grand Average TEP plots at baseline taken from the ROI electrode F1');
ylabel( 'Amplitude (\muV)');
xlabel( 'Time (ms)');
%N40
xlineval = [25, 55];
ylineval = [-2.2 -2.2];
plot(xlineval, ylineval, 'k--', 'LineWidth', 1);
txt = 'N40';
thistext = text(40,-2.4,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%P60
xlineval = [45, 75];
ylineval = [1.5 1.5];
plot(xlineval, ylineval, 'k--', 'LineWidth', 1);
txt = 'P60';
thistext = text(60,1.7,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%N100
txt = 'N100';
thistext = text(115,-3.0,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%P200
txt = 'P200';
thistext = text(220,4.5,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%Fixes legend properties to exclude random data legend entries
legend('Controls',['SEM'],'Alzheimers',['SEM'],'Location','bestoutside');  

cd (SaveDir);
set(gcf, 'Position',  [5, 5, 1500, 900]);
saveas(gcf, 'TEP_F1_BL_leftpfc_CONTROL_V_ALZHEIEMERS_ALL.png');
saveas(gcf, 'TEP_F1_BL_leftpfc_CONTROL_V_ALZHEIEMERS_ALL.fig');