%% TMS EEG peak detection, peak deletion, remove unused channels and first clean of data

%clears everything to start fresh and new   
clear; close all; clc;

%add the relevant paths for the script to run properly 
addpath('E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG');
addpath('C:\Users\grego\Desktop\Data_Analysis_Scripts_and_Repositories\TMSEEG');
eeglabpath= 'C:\Users\grego\Desktop\Matlab_EEGlab_Files\eeglab2019_1';
cd(eeglabpath)

%working directories of where the data are stored and will be kept
workDir='E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\'
inPath = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_data'; %where the data is
outPath = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_clean_1'; %'H:\TMSEEG_data\output\'; %where you want to save the data

%SETTINGS and PATHS
eeglab;
ft_defaults;

%path containing electrode positions
caploc = [eeglabpath,'\plugins\dipfit3.3\standard_BESA\standard-10-5-cap385.elp'];

% List of ID's - ID = {'301', '302'};
ID = {'301', '302'};

% Sesh = {'BL','END'};
Sesh = {'BL', 'END'};

% Regions = {'leftpfc','rightpfc'};
Regions = {'leftpfc', 'rightpfc'};
elec = {'F3', 'F4'};

% region of interest
roielec = 'FCZ';

%% 

for aaa = 1:size(ID);
    
    for aa = 1:size(Sesh);
    
        for a = 1:size(Regions); 
    
    % Load data
    EEG = pop_loadcnt([inPath, filesep, Regions{a} '_' Sesh{aa}, filesep ID{aaa} '_' Regions{a}, '_' Sesh{aa},  '.cnt'], 'dataformat', 'auto', 'memmapfile', '');

    EEG.event =[];
    EEG = eeg_checkset( EEG );
    
    %Channel locations
    EEG = pop_chanedit(EEG, 'lookup', caploc); %caploc - channel information

    %Remove unused channels
    EEG.NoCh = {'FP1'; 'FPZ'; 'FP2'; 'FT7'; 'FT8'; 'T7'; 'T8'; 'TP7'; 'CP5'; 'CP3'; 'CP1'; 'CPZ'; 'CP2'; 'CP4'; 'CP6'; 'TP8'; 'PO7'; 'PO5'; 'PO6'; 'PO8'; 'CB1'; 'CB2'; 'E3'; 'HEOG'}; 
    EEG = pop_select(EEG,'nochannel',EEG.NoCh); 
    EEG.allchan=EEG.chanlocs; % copy of all the channels you have (saved as EEG.allchan)


  EEG = tesa_findpulsepeak( EEG, elec(a), 'dtrnd', 'poly', 'thrshtype','dynamic', 'wpeaks', 'neg', 'plots', 'on', 'tmsLabel', '1');
%    EEG = tesa_findpulsepeak( EEG, elec, 'dtrnd', 'poly', 'thrshtype',10000, 'wpeaks', 'pos', 'plots', 'on', 'tmsLabel', '1');

% Cut out TMS pulse ( -5 ms to +15 ms)
%[EEG,nanspan] = tesa_artwidth(EEG,-5,15);
[EEG,nanspan] = tesa_artwidth(EEG,-5,15);
[EEG,nanspan] = tesa_artcheck(EEG,nanspan,50);
[~,section]= tesa_artwindow(EEG,nanspan);
[EEG]= tesa_removeandinterpolate(EEG,nanspan,section,1,2,0, elec ,1);
[~,nanspan] = tesa_artwidth(EEG,-5,15);
[~,mask]= tesa_artwindow(EEG,nanspan);

close 
%% interp then  spike filt 
blanks = []; 
blanks = NaN(size(mask));
t=[]; 
t=1:EEG.pnts;
x=[];
rawdata=[];
data=[];
cleandata=[];       
[ch,pnts,eps]=size(EEG.data);
SPK=EEG;

for c=1:ch;
    for e=1:eps;  
x=[];
rawdata=[];
data=[];
cleandata=[];           
        
        
rawdata = SPK.data(c,:,e);
data=rawdata;
data(mask) = blanks;
x=data;
nans = isnan(x);
x(nans) = interp1(t(~nans), x(~nans), t(nans),'pchip');
rawdat=x;  

[cleandat,I]= hampel(rawdat,200,3);

cleandat(I)=NaN;
x=cleandat;
nans = isnan(x);
x(nans) = interp1(t(~nans), x(~nans), t(nans),'pchip');

cleandata=x;  
cleandata(mask)=rawdata(mask)   ;     

SPK.data(c,:,e)= cleandata;
    end
end

EEG=[];
EEG=SPK;

%% Epoch
    
    % Epoch -1 to 1s ('1' is the identifier)
EEG = pop_epoch( EEG, { '1' } , [-1.0  2.0], 'newname', 'CNT file epochs', 'epochinfo', 'yes');   


    % Baseline correction -500 to -50 (making sure everything fluctuates
    % around 0) What we record is DC, so it brings baseline to 0
%     EEG = pop_rmbase( EEG, [-500   -50]); % Before the TMS pulse
%     EEG = eeg_checkset( EEG );
    
    % Loop within the loop, looking at events
%     for b = 1:size(EEG.event,2) % "." means Look into xxx before ".", we are looking at 2nd dimension
%         EEG.event(1,b).type = tp{a,1}; %replace triggers with time markers, tp = time point, T0 T1 T2
%     end
%     
%     [ALLEEG, EEG, CURRENTSET]=eeg_store(ALLEEG, EEG, a); %store data in ALLEEG for merge (double-click ALLEEG in workspace) ALLEEG is a stroage, use sparingly cuz it will slow down with more 
    



%% Merge Files
% sizeTp = 1:1:size(tp,1); %create number of time points -> 3 time points
% EEG = pop_mergeset(ALLEEG, sizeTp, 0); %merge time points

% EEG.urevent =[]; %reconstruct urevent -> making sure that information within EEG structure is consistent (event and urevent)

% for a = 1:size(EEG.event,2);
%     EEG.urevent(1,a).epoch = EEG.event(1,a).epoch;
%     EEG.urevent(1,a).type = EEG.event(1,a).type;
%     EEG.urevent(1,a).latency = EEG.event(1,a).latency;
% end

%%

EEG = pop_resample(EEG, 1000); 

savePath = [outPath filesep Sesh{aa}];
%mkdir(savePath);

EEG = pop_saveset(EEG, 'filename', [ID{aaa} '_TMSEEG_' Sesh{aa} '_'  Regions{a} '_ds.set'], 'filepath', [savePath filesep]); %ds = downsample

        end
        end
    
end
