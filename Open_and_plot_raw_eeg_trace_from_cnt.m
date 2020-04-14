clear all; close all; clc;
eeglab;
%% parameters to change to open raw eeg trace
%ID = {'301', '302', '305', '306', '307', '308', '309', '310', '311', '312', '313', '314', '315', '316', '317', '318', '319', '320', '322', '324', '325', '326', '327', '328', '329', '330', '331', '333', '335', '336', '338', '341', '343', '345', '346', '347', '348', '349', '351'};

ID = '351';
% Condition = {'leftpfc'; 'rightpfc'};
Condition = 'rightpfc';
% Timepoint = {'BL'; 'END'};
Timepoint = 'BL';

%%
EEG = pop_loadcnt(['E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_data\', Condition '_' Timepoint filesep ID '_' Condition '_' Timepoint '.cnt'], 'dataformat', 'auto', 'memmapfile', '');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);

%% to remove unused channels before visualisation
%EEG.NoCh = {'FP1'; 'FPZ'; 'FP2'; 'FT7'; 'FT8'; 'T7'; 'T8'; 'TP7'; 'CP5'; 'CP3'; 'CP1'; 'CPZ'; 'CP2'; 'CP4'; 'CP6'; 'TP8'; 'PO7'; 'PO5'; 'PO6'; 'PO8'; 'CB1'; 'CB2'; 'E1'; 'E3'; 'HEOG'}; 
%EEG = pop_select(EEG,'nochannel',EEG.NoCh); 
%EEG.allchan=EEG.chanlocs; % copy of all the channels you have (saved as EEG.allchan)

%% rejecting EEG base on sampling points
%EEG = eeg_eegrej( EEG, [3420000 4959200] );

%% saving as set
%pop_saveset(EEG, 'filename', [ID '_' Condition '_' Timepoint '_CUT.set', 'filepath', ['E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_data' filesep Condition '_' Timepoint filesep])

