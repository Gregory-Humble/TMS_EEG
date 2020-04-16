% 25/2/19
%This script plots TEPs for each subject at F3 (ch 8)
% & group (or individual) Topoplots 
% & group TEP with either SEM or 95% CI
% now has GMFA

clear; close all;
clearvars;
% addpath (genpath('F:\~MAPrc\TMS_EEG_MDD\2_output'));
% addpath ('\\ad.monash.edu\home\User031\rcash\Documents\MATLAB\eeglab13_6_5b');

eeglab;
% scriptDir= '\\ad.monash.edu\home\User031\rcash\Documents\MATLAB\TMS_EEG';
% cd(scriptDir)

DataDir = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_clean_2\BL';
SaveDir = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TEPoutput';
mkdir(SaveDir)
time = []
inPath = []

time = {'BL'};
hemi = {'leftpfc', 'rightpfc'}; 
for h = 1:length(hemi); 
for t = 1:size(time,1)
TEPdata = [];
TEPdata_ROI = [];
TEPlabel = [];
TEPdata_GMFA = [];
TEPdata_ROIlabels = [];    
   
    %   time = ('5_group_S1pre')
    inPath=([DataDir,filesep]);
    cd (inPath);

    % % inPath='F:\Robin\~MAPrc\TMS_EEG_MDD\6_group_HC';
    % %  inPath='F:\Robin\~MAPrc\TMS_EEG_MDD\5_group_S1pre';
    % inPath='F:\Robin\~MAPrc\TMS_EEG_MDD\5_group_S1post';
    % 
    % DataDir = 'F:\Robin\~MAPrc\TMS_EEG_MDD\'
    % % infolder = '6_group_HC'; 
    % %  infolder = '5_group_S1pre';
    %   infolder = '5_group_S1post';
    % 
    % cd (inPath);
    % 
    % %list = rdir('F:\~MAPrc\TMS_EEG_MDD\4_group\*_TMSEEG_S1_final_T0.set');
    % %names={list.name}'
    % 
    % %outfolder = '6_group_S1post_HC'; %where you want to save the data
    % %mkdir(outfolder);
    % 
    % cd ([DataDir,infolder])

    %  dirListing= dir('*_TMSEEG_S1_final_T0.set');
    seshdirnumber = (t - 1);
    dirListing = dir(['*_', hemi{h}, '*_reref.set']);

    names = {dirListing.name};
    groupdata = []; 
    for namei = 1:numel(names)
        filename = names{namei}%
        shortname = filename(1:end-4)


            cd (inPath)
        % cd ([DataDir,infolder]);  
        EEG = eeg_checkset( EEG );  
        EEG = pop_loadset('filename',names(namei));

        EEG = pop_rmbase( EEG, [-500   0]);% baseline correct
        EEG = eeg_checkset( EEG ); 
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        temp = EEG;

        if h == 1
        region1 = 'F1';
        elseif h == 2
        region1 = 'F2';
        end
            t1 = -50;
            t2 = 500; %600;
            tp1 = find(EEG.times == t1);
            tp2 = find(EEG.times == t2);     
        %% Indexing channel
            COI = {EEG.chanlocs.labels};  % "channel of interest" (Actually the list of channels) 
            IND = find(cellfun(@(xx) strcmp(xx, region1), COI)); % finds channel number of region 1 electrode channel

        %% plot TEP for each ID
            plot(temp.times(:,tp1:tp2,:),mean(temp.data(IND,tp1:tp2,:),3),'b');hold on;   
             subjav = mean(EEG.data,3); %average across epochs ->  subave = chan x time points
             groupdata(:,:,namei) = subjav; 

        %% save TEP average for N100, P200 P30','N45','P60'    

            TEPlabel = {'N40','P60','N100','P200'}; %calcs ave for given tp time range (defined below), for each ID
            %N40
            tp1 = find(EEG.times == 25);
            tp2 = find(EEG.times == 55);   
            TEPdata(:,1,namei) = mean(subjav(:,tp1:tp2),2); % 1 -> TEPdata = [all chans x column1 ( = N100) x ID] 
            %   TEPdata_ROIlabels(i,1)=i; %char2str(shortname)
            TEPdata_ROIlabels{namei,1} = shortname
            TEPdata_ROI(namei,1) = mean(subjav(IND,tp1:tp2),2); %N100 for each ID at channel 8


            %P60    
            tp1 = find(EEG.times == 45);
            tp2 = find(EEG.times == 75);   
            TEPdata(:,2,namei) = mean(subjav(:,tp1:tp2),2); 
            TEPdata_ROI(namei,2) = mean(subjav(IND,tp1:tp2),2); %P200 for each ID at channel 8

            %N100
            tp1 = find(EEG.times == 85);
            tp2 = find(EEG.times == 145);   
            TEPdata(:,3,namei) = mean(subjav(:,tp1:tp2),2); 
            TEPdata_ROI(namei,3) = mean(subjav(IND,tp1:tp2),2); 

            %P200    
            tp1 = find(EEG.times == 170);
            tp2 = find(EEG.times == 230);   
            TEPdata(:,4,namei) = mean(subjav(:,tp1:tp2),2); 
            TEPdata_ROI(namei,4) = mean(subjav(IND,tp1:tp2),2);  

%             %P60    
%             tp1 = find(EEG.times == 55);
%             tp2 = find(EEG.times == 75);   
%             TEPdata(:,5,namei) = mean(subjav(:,tp1:tp2),2); 
%             TEPdata_ROI(namei,6) = mean(subjav(IND,tp1:tp2),2); 
        
        %% GMFA    

        EEG = pop_tesa_tepextract( EEG, 'GMFA' );
        subGMFA = EEG.GMFA.R1.tseries;
            tp1 = find(EEG.times == -100);
            tp2 = find(EEG.times == 600); 
            TEPdata_GMFA(namei,:) = subGMFA(1,tp1:tp2);

            

        %% save TEP data for each ID & TOI    

        path = pwd
        cd (DataDir)
            fileID = fopen('TEPdata_ROI.txt', 'a');
        %     fprintf(fileID, '%s %f %f \n', shortname, TEPdata_ROI(i,2), TEPdata_ROI(i,3));
            fprintf(fileID, '%s %f %f %f %f %f \n', shortname, TEPdata_ROI(namei,2), TEPdata_ROI(namei,3), TEPdata_ROI(namei,4));
            fclose(fileID);
        cd (path)  

    
    end  %% END OF INDIVIDUAL DATA ANALYIS

    %% GROUP TOPOPLOTS - AT PRECISE LATENCIES 30 45 60 100 200

%     groupaverage= mean(groupdata,3); %groupdata dimensions are (channel x time points x subjects)
%     toi= [-600 30 45 60 100 200];
%     figure
%     for j =1:numel(toi)
%     %topoplot([input],EEG.chanlocs,'style','fill','shading','interp','electrodes','labelpoint','chaninfo',EEG.chaninfo);
%     subplot(1,6,j) %placement: (row, column, toi topo) 
%     tp=find(EEG.times>= toi(j),1); 
%     input=groupaverage(:,tp); %groupaverage dimensions are: (nr channels, nr tois)
%     %topoplot([input],EEG.chanlocs,'electrodes','labelpoint')
%     topoplot([input],EEG.chanlocs)
%     title(['Latency: ' num2str(toi(j)) ])
%     hold on 
%     end 
%     %pop_topoplot(EEG,1, [-600 45 60 100 200] ,'Merged datasets resampled pruned with ICA pruned with ICA pruned with ICA',[2 3] ,0,'electrodes','on');

     %% GROUP TEP
% 
%     figure;
%     for c= 8; %1:50
%     groupchandata=groupdata(c,:,:)
%     data=groupchandata; 
%     linecolour='r'; shadingalpha=0.3;%1/50; 
%         M = mean(data,3);
%         plot(EEG.times,M,linecolour); 
%         hold on 
%         %CI = 1.96*(std(data,0,3)./(sqrt(size(data,3))));%% 95%CI 
%         CI =(std(data,0,3)./(sqrt(size(data,3)))); %% SEM in 3rd dimension; preceding '0' is necessary in std usage
%         f = fill([EEG.times,fliplr(EEG.times)],[M-CI,fliplr(M+CI)],linecolour); 
%         set(f,'FaceAlpha',shadingalpha);set(f,'EdgeColor', 'none'); 
%     drawnow;
% 
%     toi= [0 45 60 100 200]; 
%     for j =1:numel(toi)
%     plot([toi(j) toi(j)], get(gca,'ylim'),'k--');
%     end
%     xlim([-100 500])
%     ylim([-3 3])
%     grid on
%     xticks([-100 -50 0 45 60 100 200 250 300 350 400 450 500])
%     end


    %% GROUP TOPOPLOTS - WITHIN TIME RANGES AROUND N100 P200 P30 N45 P60
    j = []
    figure

    groupaverage = mean(TEPdata,3); % -> mean across subjects => group ave becomes [all chan x toi] , (51 x 5)
    % toi= [1,2];  %% 
    toi = [1,2,3,4];  

    for j = 1:numel(toi)
    %topoplot([input],EEG.chanlocs,'style','fill','shading','interp','electrodes','labelpoint','chaninfo',EEG.chaninfo);
    % subplot(1,2,j)
    subplot(1,5,j)
    input = groupaverage(:,j);
    %topoplot([input],EEG.chanlocs,'electrodes','labelpoint')
    %% absmax colour scaling 
    topoplot([input],EEG.chanlocs);
   %% set my own colour map limits
    % topoplot( [input],EEG.chanlocs, 'maplimits', [-3,3]  )
     title([ TEPlabel{j}]);
    hold on 
    end 

    cd (SaveDir)
    save(['TEPdata2plot_' , time{t,1},'_',hemi{h}, '.mat'], 'groupdata'); %this is [chan x time points x ID] (51 x 3000 x 10)

    %save('TEPdata_ROI_file.mat','TEPdata_ROI','-append') % (ID x TOI), (10 x 6) 
    
    save(['Topoplot_allChan_x_TOI_' , time{t,1},'_',hemi{h}, '.mat'], 'groupaverage'); %this is [chan x toi] 
    
    groupaverage =[];
 
end   % END OF ANALYSIS OF TIME POINT (PRE OR POST)

end  % END OF ANAYLSIS OF HEMISPHERE ( L OR R) 
%% GROUP TEP @ R & R

cd (SaveDir)

figure;

groupchandata = []
groupdata = []
data = []

ch = 6 % 6 = F1
for c = ch; %1:50
results = ['TEPdata2plot_', time{t,1}, '_', hemi{h}, '.mat'];
load (results);
pre_groupchandata = groupdata(c,:,:);

data = pre_groupchandata; 
linecolour = 'r'; shadingalpha = 0.3;%1/50; 
    M = mean(data,3);
    leg1 = plot(EEG.times,M,linecolour); 
    hold on 
    CI = 1.96*(std(data,0,3)./(sqrt(size(data,3))));%% 95%CI 
    %CI =(std(data,0,3)./(sqrt(size(data,3)))); %% SEM in 3rd dimension; preceding '0' is necessary in std usage
    f = fill([EEG.times,fliplr(EEG.times)],[M-CI,fliplr(M+CI)],linecolour); 
    set(f,'FaceAlpha',shadingalpha);set(f,'EdgeColor', 'none'); 
drawnow;

% groupchandata =[]
% groupdata = []
% data = []

% results = ['TEPdata2plot_' , 'controls','_','LDLPFC', '.mat']
% load (results);
% post_groupchandata = groupdata;

% groupchandata = groupdata(c,:,:);
% data = groupchandata; 
% linecolour = 'b'; shadingalpha=0.3;%1/50; 
%     M = mean(data,3);
%     plot(EEG.times,M,linecolour); 
%     hold on 
%     CI = 1.96*(std(data,0,3)./(sqrt(size(data,3))));%% 95%CI 
%     %CI =(std(data,0,3)./(sqrt(size(data,3)))); %% SEM in 3rd dimension; preceding '0' is necessary in std usage
%     f = fill([EEG.times,fliplr(EEG.times)],[M-CI,fliplr(M+CI)],linecolour); 
%     set(f,'FaceAlpha',shadingalpha);set(f,'EdgeColor', 'none'); 
% drawnow;
 
toi = [0];
xlim([-100 500]);
ylim([-3 3]);
for j = 1:numel(toi)
plot([toi(j) toi(j)], get(gca,'ylim'),'k--');
end
xlim([-100 500]);
ylim([-3 3]);
grid on
xticks([-100 -50 0 45 60 100 150 200 250 300 350 400 450 500])
hold on
legend('Alzheimers',['95%CI'],'Location','bestoutside')%,r, b)
% legend('off')
end
%add opaque rectangles
rectangle('Position', [25, -3, 50, 6], ...
                'FaceColor', [0, 0, 0, 0.2], ...
                'EdgeColor', [0, 0, 0, 0.0]);
rectangle('Position', [85, -3, 60, 6], ...
                'FaceColor', [0, 0, 0, 0.2], ...
                'EdgeColor', [0, 0, 0, 0.0]);
rectangle('Position', [170, -3, 60, 6], ...
                'FaceColor', [0, 0, 0, 0.2], ...
                'EdgeColor', [0, 0, 0, 0.0]);
title('Grand Average TEP plots at baseline taken from the ROI electrode F1');
ylabel( 'Amplitude (\muV)');
xlabel( 'Time (ms)');
%N40
xlineval = [25, 55];
ylineval = [-0.6 -0.6];
plot(xlineval, ylineval, 'k--', 'LineWidth', 1);
txt = 'N40';
thistext = text(40,-0.7,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%P60
xlineval = [45, 75];
ylineval = [1 1];
plot(xlineval, ylineval, 'k--', 'LineWidth', 1);
txt = 'P60';
thistext = text(60,1.1,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%N100
txt = 'N100';
thistext = text(115,-2.6,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%P200
txt = 'P200';
thistext = text(200,2,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%Fixes legend properties to exclude random data legend entries
legend('Alzheimers',['95%CI'],'Location','bestoutside');

cd (SaveDir);

saveas(gcf, 'TEP_F1_BL_leftpfc.png');
saveas(gcf, 'TEP_F1_BL_leftpfc.fig');
% 
% figure;
% 
% groupchandata =[]
% groupdata = []
% data = []
% 
% ch=8 % 8= F3 10=Fz; 12=F4
% for c= ch; %1:50
% results= ['TEPdata2plot_' , 'controls','_','RDLPFC', '.mat']
% load (results);
% pre_groupchandata=groupdata(c,:,:);
% 
% data=pre_groupchandata; 
% linecolour='r'; shadingalpha=0.3;%1/50; 
%     M = mean(data,3);
%     plot(EEG.times,M,linecolour); 
%     hold on 
%     CI = 1.96*(std(data,0,3)./(sqrt(size(data,3))));%% 95%CI 
%     %CI =(std(data,0,3)./(sqrt(size(data,3)))); %% SEM in 3rd dimension; preceding '0' is necessary in std usage
%     f = fill([EEG.times,fliplr(EEG.times)],[M-CI,fliplr(M+CI)],linecolour); 
%     set(f,'FaceAlpha',shadingalpha);set(f,'EdgeColor', 'none'); 
% drawnow;
% 
% groupchandata =[]
% groupdata = []
% data = []
% 
% results= ['TEPdata2plot_' , 'meditators','_','RDLPFC', '.mat']
% load (results);
% post_groupchandata = groupdata;
% 
% groupchandata=groupdata(c,:,:);
% data=groupchandata; 
% linecolour='b'; shadingalpha=0.3;%1/50; 
%     M = mean(data,3);
%     plot(EEG.times,M,linecolour); 
%     hold on 
%     CI = 1.96*(std(data,0,3)./(sqrt(size(data,3))));%% 95%CI 
%     %CI =(std(data,0,3)./(sqrt(size(data,3)))); %% SEM in 3rd dimension; preceding '0' is necessary in std usage
%     f = fill([EEG.times,fliplr(EEG.times)],[M-CI,fliplr(M+CI)],linecolour); 
%     set(f,'FaceAlpha',shadingalpha);set(f,'EdgeColor', 'none'); 
% drawnow;
%  
% toi= [0 45 60 100 200]; 
% for j =1:numel(toi)
% plot([toi(j) toi(j)], get(gca,'ylim'),'k--');
% end
% xlim([-100 500])
% ylim([-3 3])
% grid on
% xticks([-100 -50 0 45 60 100 200 250 300 350 400 450 500])
% 
% legend('CNT RDLPFC',['95%CI'], 'MED RDLPFC',['95%CI'],'Location','bestoutside')%,r, b)
% % legend('off')
% 
% end
% 

%% GROUP TOPOPLOT

groupaverage = [];
j = [];

figure;
hold on
    
groupaverage = [];
j = [];

results = ['Topoplot_allChan_x_TOI_BL_leftpfc.mat']
load (results);

    toi = [1,2,3,4];  

    for j = 1:numel(toi)
    %topoplot([input],EEG.chanlocs,'style','fill','shading','interp','electrodes','labelpoint','chaninfo',EEG.chaninfo);
    % subplot(1,2,j)
    subplot(2,5,j+5)
    input = groupaverage(:,j);
    %topoplot([input],EEG.chanlocs,'electrodes','labelpoint')
    topoplot([input],EEG.chanlocs);
    title([ TEPlabel{j}]);
    hold off    
    end 
    
hold on
results = ['Topoplot_allChan_x_TOI_BL_leftpfc.mat']
load (results);

    toi = [1,2,3,4];  

    for j = 1:numel(toi)
    %topoplot([input],EEG.chanlocs,'style','fill','shading','interp','electrodes','labelpoint','chaninfo',EEG.chaninfo);
    % subplot(1,2,j)
    subplot(2,5,j+5)
    input = groupaverage(:,j);
    %topoplot([input],EEG.chanlocs,'electrodes','labelpoint')
    topoplot([input],EEG.chanlocs);
    title([ TEPlabel{j}]);
    hold off    
    end
    
saveas(gcf, 'TOPOPLOT_F1_BL_leftpfc.png');
saveas(gcf, 'TOPOPLOT_F1_BL_leftpfc.fig');
%     
% figure
% hold on
% results = ['Topoplot_allChan_x_TOI_BL_rightpfc.mat']
% load (results);
% 
%     toi = [1,2,3,4];  
% 
%     for j =1:numel(toi)
%     %topoplot([input],EEG.chanlocs,'style','fill','shading','interp','electrodes','labelpoint','chaninfo',EEG.chaninfo);
%     % subplot(1,2,j)
%     subplot(2,5,j+5)
%     input=groupaverage(:,j);
%     %topoplot([input],EEG.chanlocs,'electrodes','labelpoint')
%     topoplot([input],EEG.chanlocs);
%      title([ TEPlabel{j}]);
%     hold off    
%  
%     end 
%     
% figure
% hold on
% results = ['Topoplot_allChan_x_TOI_meditators_RDLPFC.mat']
% load (results);
% 
%     toi= [1,2,3,4];  
% 
%     for j = 1:numel(toi)
%     %topoplot([input],EEG.chanlocs,'style','fill','shading','interp','electrodes','labelpoint','chaninfo',EEG.chaninfo);
%     % subplot(1,2,j)
%     subplot(2,5,j+5)
%     input=groupaverage(:,j);
%     %topoplot([input],EEG.chanlocs,'electrodes','labelpoint')
%     topoplot([input],EEG.chanlocs);
%      title([ TEPlabel{j}]);
%     hold off    
% 
%     end 
    