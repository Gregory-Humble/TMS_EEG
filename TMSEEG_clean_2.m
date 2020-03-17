clear; close all; clc;
addpath 'C:\Users\grego\Desktop\Honours\eeglab_current\eeglab2019_1';
eeglabpath = 'C:\Users\grego\Desktop\Honours\eeglab_current\eeglab2019_1';
eeglab;
 %SETTINGS and PATHS

caploc = [eeglabpath,'\plugins\dipfit3.3\standard_BESA\standard-10-5-cap385.elp']; %path containing electrode positions
%caploc='C:\Users\grego\Desktop\Honours\DataAnalysis2019\Scripts2019\standard-10-5-cap385.elp'; %path containing electrode positions

inPath = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_clean_1'; %where the data is
outPath = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_clean_2'; %'H:\TMSEEG_data\output\'; %where you want to save the data

% ID = {'301', '302'};
ID = '301';

% Sesh = {'BL','END'};
Sesh = 'BL';

% Regions = {'leftpfc','rightpfc'};
Regions = 'leftpfc';

%electrode/regions of interest 
elec = 'F3';
roielec = 'FCZ';

%change directory to in path
cd(inPath);
%%
EEG = pop_loadset('filename', [ID '_TMSEEG_' Sesh '_' Regions '_ds.set'], 'filepath', [inPath filesep Sesh filesep]);
% 301_TMSEEG_END_RDLPFC_
%% Baseline correction to itself
    EEG = pop_rmbase( EEG, [-500 -50]); % Before the TMS pulse
    EEG = eeg_checkset( EEG );
    EEG.allchan=EEG.chanlocs; % copy of all the channels you have (saved as EEG.allchan)

%%    
%Check for bad channel
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 0);
R1=input('Highlight any bad trials, take note of any bad channels and press "update marks". Press enter when ready to continue.');

%Remove bad trials
EEG.badtrial1=find(EEG.reject.rejmanual==1); % saved as EEG.badtrial1
EEG=pop_rejepoch(EEG,find(EEG.reject.rejmanual==1),0);

%Remove bad channels
bad=inputdlg('Enter bad channels separated by a space (i.e. FZ CZ P3 etc)', 'Bad channel removal', [1 50]); % enter bad channels to remove
str=bad{1};
EEG.badchan=strsplit(str);
if isempty(EEG.badchan)==0;
    EEG = pop_select( EEG,'nochannel',EEG.badchan);
end

%%
    EEG = pop_tesa_fastica(EEG,'approach', 'symm', 'g', 'tanh', 'stabilization', 'on'); 
%     EEG = pop_runica(EEG,'icatype','fastica', 'approach', 'symm', 'g', 'tanh'); 
    EEG = eeg_checkset( EEG );  
    
    
    %%
mkdir([outPath filesep Sesh filesep]);

EEG = pop_saveset(EEG, 'filename', [ID '_TMSEEG_' Sesh '_' Regions '_ds_ica1.set'], 'filepath', [outPath filesep Sesh filesep]);
% EEG = pop_loadset('filename', [ID '_TMSEEG_' Sesh '_' Regions '_ds_ica1.set'], 'filepath', [outPath filesep Sesh filesep]);


%     pop_plotdata(EEG, 0, [1:size(EEG.icawinv,2)],[1:EEG.trials],'Merged datasets ERP', 0, 1, [0 0]);
%     EEG = pop_selectcomps(EEG,1:size(EEG.icawinv,2));
% 
%     R1=input('Press enter when ready to continue');
%     EEG = pop_subcomp(EEG, [], 0);

% EEG = pop_tesa_compselect( EEG, 'figSize', 'large','blink', 'off', 'move', 'off', 'muscle', 'off', 'elecNoise', 'off');

% EEG = pop_tesa_compselect( EEG, 'figSize', 'large','blink', 'off', 'move', 'off', 'muscle', 'off', 'elecNoise', 'off');
% make sure to press 'd' when done to end the component selection gui
EEG = tesa_compselect( EEG,'compCheck','on','comps',[],'figSize','large','plotTimeX',[-200 500],'plotFreqX',[1 50],'tmsMuscle','on','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off','blink','off','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off','move','off','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off','muscle','off','muscleThresh',0.6,'muscleFreqWin',[30 100],'muscleFeedback','off','elecNoise','off','elecNoiseThresh',4,'elecNoiseFeedback','off' );

%EEG = pop_tesa_compselect( EEG,'compCheck','on','comps',[],'figSize','large','plotTimeX',[-200 500],'plotFreqX',[1 50],'tmsMuscle','on','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off','blink','off','blinkThresh',2.5,'blinkElecs',{'Fp1','Fp2'},'blinkFeedback','off','move','off','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off','muscle','off','muscleThresh',0.6,'muscleFreqWin',[30 100],'muscleFeedback','off','elecNoise','off','elecNoiseThresh',4,'elecNoiseFeedback','off' );
%     pop_plotdata(EEG, 0, [1:size(EEG.icawinv,2)],[1:EEG.trials],'Merged datasets ERP', 0, 1, [0 0]);
%     EEG = pop_selectcomps(EEG,1:size(EEG.icawinv,2));
% 	EEG = pop_subcomp(EEG);  
%     
    

%%
% loc=pwd;
% cd(filterfolder)

EEG = tesa_filtbutter( EEG, 1, 100, 4, 'bandpass' );
EEG = tesa_filtbutter( EEG, 48, 52, 4, 'bandstop' );

% cd(loc);


%%
%CLEAN 2

%Check for bad trials
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 0);
R1=input('Highlight any bad trials and press "update marks". Press enter when ready to continue.');

%Remove bad trials
EEG.badtrial2=find(EEG.reject.rejmanual==1);
EEG=pop_rejepoch(EEG,find(EEG.reject.rejmanual==1),0);

bad=inputdlg('Enter bad channels separated by a space (i.e. FZ CZ P3 etc)', 'Bad channel removal', [1 50]); % enter bad channels to remove
str=bad{1};
EEG.badchan=strsplit(str);
if isempty(EEG.badchan)==0;
    EEG = pop_select( EEG,'nochannel',EEG.badchan);
end

%%
2
    EEG = pop_tesa_fastica(EEG,'approach', 'symm', 'g', 'tanh', 'stabilization', 'on' ); 
%     EEG = pop_runica(EEG,'icatype','fastica', 'approach', 'symm', 'g', 'tanh'); 
    EEG = eeg_checkset( EEG );  
        

%%

%Save point
EEG = pop_saveset(EEG, 'filename', [ID '_TMSEEG_' Sesh '_' Regions '_ds_ica1_filt_ica2.set'], 'filepath', [outPath filesep Sesh]);
% EEG = pop_loadset('filename', [ID '_TMSEEG_' Sesh '_ds_ica1_filt_ica2.set'], 'filepath', [outPath ID filesep]);
    
% % TESA
figure; topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
belecs=inputdlg('Enter blink channels (two) separated by a space (i.e. AF3 AF4)', 'Blinks!!', [1 50]); % enter blink elecs to use
str=belecs{1};
belecs=strsplit(str);

melecs=inputdlg('Enter horizontal eye channels (two) separated by a space (i.e. F7, F8)', 'Lateral eye!!', [1 50]); % enter blink elecs to use
str2=melecs{1};
melecs=strsplit(str2);

close all;

% belecs = {'AF3','AF4'};
% melecs = {'F7','F8'};

EEG = tesa_compselect(EEG, 'blinkElecs', belecs , 'moveElecs', melecs, 'figSize', 'large','plotTimeX',[-200,700] ,'plotFreqX', [2,80]);

%%

%Save point
EEG = pop_saveset(EEG, 'filename', [ID '_TMSEEG_' Sesh '_' Regions '_ds_ica1_filt_ica2_clean.set'], 'filepath', [outPath filesep Sesh]);
% EEG = pop_loadset('filename', [ID '_TMSEEG_' Sesh '_ds_ica1_filt_ica2_clean.set'], 'filepath', [outPath]);




%%
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 0);
R1=input('Highlight any bad trials, take note of any bad channels and press "update marks". Press enter when ready to continue.');

%Remove bad trials
EEG.badtrial1=find(EEG.reject.rejmanual==1); % saved as EEG.badtrial1
EEG=pop_rejepoch(EEG,find(EEG.reject.rejmanual==1),0);

%Remove bad channels
bad=inputdlg('Enter bad channels separated by a space (i.e. FZ CZ P3 etc)', 'Bad channel removal', [1 50]); % enter bad channels to remove
str=bad{1};
EEG.badchan=strsplit(str);
if isempty(EEG.badchan)==0;
    EEG = pop_select( EEG,'nochannel',EEG.badchan);
end
%%
%INTERPOLATE MISSING CHANNELS
EEG = pop_interp(EEG, EEG.allchan, 'spherical');

% %AVERAGE RE-REFERENCE - Run eeglab and use EEG.history to figure it out.
EEG = pop_reref( EEG, []);

%% Baseline correction to prestimulus
    EEG = pop_rmbase( EEG, [-500   -50]); % Before the TMS pulse
    EEG = eeg_checkset( EEG );

EEG = pop_saveset(EEG, 'filename', [ID '_TMSEEG_' Sesh '_' Regions '_ds_ica1_filt_ica2_clean_reref.set'], 'filepath', [outPath filesep Sesh]);

% EEG = pop_loadset('filename', [ID '_TMSEEG_' Sesh '_ds_ica1_filt_ica2_clean_reref.set'], 'filepath', [outPath]);
EEG = eeg_checkset( EEG );

%%
EEG = pop_loadset('filename', [ID '_TMSEEG_' Sesh '_' Regions '_ds_ica1_filt_ica2_clean_reref.set'], 'filepath', [outPath filesep Sesh]);

% EEG_L = pop_loadset('filename', [ID '_TMSEEG_' Sesh '_LDLPFC_ds_ica1_filt_ica2_clean_reref.set'], 'filepath', [outPath]);
% EEG_R = pop_loadset('filename', [ID '_TMSEEG_' Sesh '_RDLPFC_ds_ica1_filt_ica2_clean_reref.set'], 'filepath', [outPath filesep Sesh]);

% %%  Graph of grand averages at each time point (specified channel)
    t1 = -300;
    t2 = 600;
    tp1 = find(EEG.times == t1);
    tp2 = find(EEG.times == t2);
    
%     
%         % Indexing channel
    COI = {EEG.chanlocs.labels};  % channel of interest
    IND = find(cellfun(@(x) strcmp(x, region), COI)); % giving it the number so you can just change setting to get whichever value
    
    if strcmp(IND,[]);
    noregion = menu('Oops, the channel must''ve been removed! Please choose among these',COI);    
    IND = noregion;
     end

% plotting all (butterfly) - left DLPFC
    figure;
    plot(EEG.times(:,tp1:tp2), mean(EEG.data(:,tp1:tp2,:),3), 'b'); hold on;
    plot(EEG.times(:,tp1:tp2,:),mean(EEG.data(IND,tp1:tp2,:),3),'r', 'Linewidth',2);
    
    
%     figure;
%     plot(EEG_R.times(:,tp1:tp2), mean(EEG_R.data(:,tp1:tp2,:),3), 'b'); hold on;
%     plot(EEG_R.times(:,tp1:tp2,:),mean(EEG_R.data(IND,tp1:tp2,:),3),'r', 'Linewidth',2);

