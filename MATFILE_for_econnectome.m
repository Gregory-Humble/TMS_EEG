clear; close all; clc;

%add the relevant paths for the script to run properly 
addpath('E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG');
addpath('C:\Users\grego\Desktop\Data_Analysis_Scripts_and_Repositories\TMSEEG');
eeglabpath = 'C:\Users\grego\Desktop\Matlab_EEGlab_Files\eeglab2019_1';
cd(eeglabpath)
%SETTINGS and PATHS
eeglab;
ft_defaults;

%path containing electrode positions
caploc = [eeglabpath,'\plugins\dipfit3.3\standard_BESA\standard-10-5-cap385.elp'];

%location of data and where to save
inPath = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_clean_2\'; %where the data is
outPath = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\MATFILES\'; %'H:\TMSEEG_data\output\'; %where you want to save the data

% List of ID's - ID = {'301', '302', '305', '306', '307', '308', '309', '310', '311', '312', '313', '314', '315', '316', '317', '318', '319', '320', '322', '324', '325', '326', '327', '328', '329', '330', '331', '333', '335', '336', '338', '341', '343', '345', '346', '347', '348', '349', '351'};
IDlist = {'301'};

% Sesh = {'BL','END'};
Sesh = {'BL'};

% Regions = {'leftpfc','rightpfc'};
Regions = {'leftpfc','rightpfc'};

% electrode of interest for plotting butterfly plots
% Elecofint = {'F3', 'F4'};

%change directory to in path
cd(outPath);
for thisID = 1:numel(IDlist)
for Reg = 1:length(Regions)
    EEG = pop_loadset('filename', [IDlist{thisID} '_TMSEEG_BL_' Regions{Reg} '_ds_ica1_filt_ica2_clean_reref.set'], 'filepath', [inPath Sesh{1} filesep]);
    EEG.points = EEG.pnts
    clear EEG.pnts
    EEG.labels = {EEG.allchan.labels}
    EEG.labels = cellstr(EEG.labels)
    EEG.labeltype = ['standard']
    save([IDlist{thisID} '_TMSEEG_' Sesh{1} '_' Regions{Reg} '_ds_ica1_filt_ica2_clean_reref_econnectome.mat'], 'EEG');
end
end
