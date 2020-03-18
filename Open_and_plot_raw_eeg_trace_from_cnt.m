clear all; close all; clc;
eeglab;
%% parameters to change to open raw eeg trace
%ID = {'301', '302', '305', '306', '307', '308', '309', '310', '311', '312', '313', '314', '315', '316', '317', '318', '319', '320', '322', '324', '325', '326', '327', '328', '329', '330', '331', '333', '335', '336', '338', '341', '343', '345', '346', '347', '348', '349', '351'};

ID = '305';
% Condition = {'leftpfc'; 'rightpfc'};
Condition = 'rightpfc';
% Timepoint = {'BL'; 'END'};
Timepoint = 'END';

%%
EEG = pop_loadcnt(['E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_data\', Condition '_' Timepoint filesep ID '_' Condition '_' Timepoint '.cnt'], 'dataformat', 'auto', 'memmapfile', '');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
