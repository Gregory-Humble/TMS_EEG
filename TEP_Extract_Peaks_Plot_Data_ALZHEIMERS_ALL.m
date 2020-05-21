% 25/2/19
%This script plots TEPs for each subject at F3 (ch 8)
% & group (or individual) Topoplots
% & group TEP with either SEM or 95% CI
% now has GMFA

clear; close all; clc;
clearvars;

eeglab;
DataDir = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_clean_2\BL\leftpfc';
SaveDir = 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TEPoutput_ALZ_ALL';
mkdir(SaveDir);
time = [];
inPath = [];
time = {'BL'};
hemi = {'leftpfc'};
for h = 1:length(hemi);
    for t = 1:size(time,1);
        TEPdata = [];
        TEPdata_ROI = [];
        TEPlabel = [];
        TEPdata_GMFA = [];
        TEPdata_ROIlabels = [];
        inPath=([DataDir,filesep]);
        cd (inPath);
        seshdirnumber = (t - 1);
        dirListing = dir(['*_', hemi{h}, '*_reref.set']);
        names = {dirListing.name};
        groupdata = [];
        for namei = 1:numel(names);
            filename = names{namei};%
            shortname = filename(1:end-4);
            cd (inPath);
            EEG = eeg_checkset( EEG );
            EEG = pop_loadset('filename',names(namei));
            
            %removes M1, M2, and SO1 channel from data
            EEG.NoCh = {'FP1'; 'FPZ'; 'FP2'; 'FT7'; 'FT8'; 'T7'; 'T8'; 'TP7'; 'CP5'; 'CP3'; 'CP1'; 'CPZ'; 'CP2'; 'CP4'; 'CP6'; 'TP8'; 'PO7'; 'PO5'; 'PO6'; 'PO8'; 'CB1'; 'CB2'; 'E3'; 'HEOG'; 'M1'; 'M2'; 'SO1'}; 
            EEG = pop_select(EEG,'nochannel',EEG.NoCh); 
            EEG.allchan=EEG.chanlocs;
            
            EEG = pop_rmbase( EEG, [-500   0]);% baseline correct
            EEG = eeg_checkset( EEG );
            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
            temp = EEG;
            
            if h == 1
                region1 = 'F1';
            elseif h == 2
                region1 = 'F2';
            end
            t1 = -100;
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
            TEPdata_ROIlabels{namei,1} = shortname;
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
            
            %P200 - have changed from 170-230 
            tp1 = find(EEG.times == 190);
            tp2 = find(EEG.times == 250);
            TEPdata(:,4,namei) = mean(subjav(:,tp1:tp2),2);
            TEPdata_ROI(namei,4) = mean(subjav(IND,tp1:tp2),2);
            
            %% GMFA
            
            EEG = pop_tesa_tepextract( EEG, 'GMFA' );
            subGMFA = EEG.GMFA.R1.tseries;
            tp1 = find(EEG.times == -100);
            tp2 = find(EEG.times == 500);
            TEPdata_GMFA(namei,:) = subGMFA(1,tp1:tp2);
            
            %% save TEP data for each ID & TOI
            
            path = pwd;
            cd(DataDir);
            fileID = fopen('TEPdata_ROI_ALZHEIMERS_ALL.txt', 'a');
            %fprintf(fileID, '%s %f %f \n', shortname, TEPdata_ROI(i,2), TEPdata_ROI(i,3));
            fprintf(fileID, '%s %f %f %f %f %f \n', shortname, TEPdata_ROI(namei,2), TEPdata_ROI(namei,3), TEPdata_ROI(namei,4));
            fclose(fileID);
            cd(path);
            
        end  %% END OF INDIVIDUAL DATA ANALYIS
        
        %% GROUP TOPOPLOTS - AT PRECISE LATENCIES 40 60 100 200
        
            groupaverage = mean(groupdata,3); %groupdata dimensions are (channel x time points x subjects)
            toi = [40 60 100 200];
            figure;
            for j = 1:numel(toi);
            %topoplot([input],EEG.chanlocs,'style','fill','shading','interp','electrodes','labelpoint','chaninfo',EEG.chaninfo);
            subplot(1,6,j); %placement: (row, column, toi topo)
            tp = find(EEG.times >= toi(j),1);
            input = groupaverage(:,tp); %groupaverage dimensions are: (nr channels, nr tois)
            %topoplot([input],EEG.chanlocs,'electrodes','labelpoint')
            topoplot([input],EEG.chanlocs);
            title(['Latency: ' num2str(toi(j)) ]);
            hold on;
            end
            set(gcf, 'Position',  [5, 5, 1500, 900]);
            cd(SaveDir)
            saveas(gcf, 'Group_Topoplot_Precise_Latencies_BL_leftpfc_ALZHEIMERS_ALL.png');
            saveas(gcf, 'Group_Topoplot_Precise_Latencies_BL_leftpfc_ALZHEIMERS_ALL.fig');
            %pop_topoplot(EEG,1, [-600 45 60 100 200] ,'Merged datasets resampled pruned with ICA pruned with ICA pruned with ICA',[2 3] ,0,'electrodes','on');
            
        %% GROUP TOPOPLOTS - WITHIN TIME RANGES AROUND N100 P200 N45 P60
        cd(path);
        j = [];
        figure;
        groupaverage = mean(TEPdata,3); % -> mean across subjects => group ave becomes [all chan x toi] , (40 x 4)
        toi = [1,2,3,4];        
        for j = 1:numel(toi);
            %topoplot([input],EEG.chanlocs,'style','fill','shading','interp','electrodes','labelpoint','chaninfo',EEG.chaninfo);
            % subplot(1,2,j)
            subplot(1,4,j);
            input = groupaverage(:,j);
            %topoplot([input],EEG.chanlocs,'electrodes','labelpoint')
            %% absmax colour scaling
            topoplot([input],EEG.chanlocs);
            %% set my own colour map limits
            % topoplot( [input],EEG.chanlocs, 'maplimits', [-3,3]  )
            title([ TEPlabel{j}]);
            hold on
        end
        set(gcf, 'Position',  [5, 5, 1500, 900]);
        cd(SaveDir);
        saveas(gcf, 'Group_Topoplot_Within_Time_Ranges_BL_leftpfc_ALZHEIMERS_ALL.png');
        saveas(gcf, 'Group_Topoplot_Within_Time_Ranges_BL_leftpfc_ALZHEIMERS_ALL.fig');
        
        %thisfilename = ['TEPdata2plot_',time{t,1},'_',hemi{h},'.mat'];
        thisfilename = ['TEPdata2plot_',time{t,1},'_',hemi{h}, '_ALZHEIMERS_ALL.mat'];
        save(thisfilename, 'groupdata'); %this is [chan x time points x ID] (51 x 3000 x 10)
        
        %save('TEPdata_ROI_file.mat','TEPdata_ROI','-append') % (ID x TOI), (10 x 6)
        
        save(['Topoplot_allChan_x_TOI_',time{t,1},'_',hemi{h}, '_ALZHEIMERS_ALL.mat'], 'groupaverage'); %this is [chan x toi]
        
        groupaverage = [];
%         
    end   % END OF ANALYSIS OF TIME POINT (PRE OR POST)
    
end  % END OF ANAYLSIS OF HEMISPHERE ( L OR R)
%% GROUP TEP

cd(SaveDir);
figure;
groupchandata = []
groupdata = []
data = []
ch = 6 % 6 = F1
for c = ch; %1:50
    results = ['TEPdata2plot_', time{t,1}, '_', hemi{h}, '_ALZHEIMERS_ALL.mat'];
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
    'FaceColor', [0, 0, 0, 0.05], ...
    'EdgeColor', [0, 0, 0, 0.0]);
rectangle('Position', [85, -3, 60, 6], ...
    'FaceColor', [0, 0, 0, 0.05], ...
    'EdgeColor', [0, 0, 0, 0.0]);
rectangle('Position', [190, -3, 60, 6], ...
    'FaceColor', [0, 0, 0, 0.05], ...
    'EdgeColor', [0, 0, 0, 0.0]);
title('Grand Average TEP plot at baseline taken from the ROI electrode F1');
ylabel( 'Amplitude (\muV)');
xlabel( 'Time (ms)');
%N40
xlineval = [25, 55];
ylineval = [-1.6 -1.6];
plot(xlineval, ylineval, 'k--', 'LineWidth', 1);
txt = 'N40';
thistext = text(40,-1.8,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%P60
xlineval = [45, 75];
ylineval = [0.5 0.5];
plot(xlineval, ylineval, 'k--', 'LineWidth', 1);
txt = 'P60';
thistext = text(60,0.7,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%N100
txt = 'N100';
thistext = text(115,-2.2,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%P200
txt = 'P200';
thistext = text(220,2.1,txt,'FontSize',11);
thistext.HorizontalAlignment = 'center'

%Fixes legend properties to exclude random data legend entries
legend('Alzheimers',['95%CI'],'Location','bestoutside');
set(gcf, 'Position',  [5, 5, 1500, 900]);
cd (SaveDir);
saveas(gcf, 'TEP_F1_BL_leftpfc_ALZHEIMERS_ALL.png');
saveas(gcf, 'TEP_F1_BL_leftpfc_ALZHEIMERS_ALL.fig');

%% Plot all channels of group TEP
figure;
    for c = 1:40; %1:50
        results = ['TEPdata2plot_', time{t,1}, '_', hemi{h}, '_ALZHEIMERS_ALL.mat'];
        load (results);
        pre_groupchandata = groupdata(c,:,:);
        data = pre_groupchandata;
        if c == 6 ; % channel F1
            linecolour = 'r';
        else
        linecolour = 'k';
        end
        M = mean(data,3);
        leg1 = plot(EEG.times,M,linecolour);
        hold on
        drawnow;

        toi = [0];
        xlim([-100 500]);
        ylim([-4 4]);
        for j = 1:numel(toi)
            plot([toi(j) toi(j)], get(gca,'ylim'),'k--');
        end
        xlim([-100 500]);
        ylim([-4 4]);
        grid on
        xticks([-100 0 100 200 300 400 500])
        hold on
        legend('off')
    end
    %plot EOI on top 
    c = 6; %F1
        results = ['TEPdata2plot_', time{t,1}, '_', hemi{h}, '_ALZHEIMERS_ALL.mat'];
        load (results);
        pre_groupchandata = groupdata(c,:,:);
        data = pre_groupchandata;
        linecolour = 'r';
        M = mean(data,3);
        leg1 = plot(EEG.times,M,linecolour, 'LineWidth',3);
        legend('F1');
        hold on;
        drawnow;
        
    title('Grand Average TEP butterfly plot at baseline with stimulation of the Left DLPFC');
    ylabel( 'Amplitude (\muV)');
    xlabel( 'Time (ms)');

    %N40
    txt = 'N40';
    thistext = text(40,-1.5,txt,'FontSize',11, 'Color', 'b');
    thistext.HorizontalAlignment = 'center';

    %P60
    txt = 'P60';
    thistext = text(60,1.5,txt,'FontSize',11, 'Color', 'b');
    thistext.HorizontalAlignment = 'center';

    %N100
    txt = 'N100';
    thistext = text(120,-2,txt,'FontSize',11, 'Color', 'b');
    thistext.HorizontalAlignment = 'center';

    %P200
    txt = 'P200';
    thistext = text(200,2.3,txt,'FontSize',11, 'Color', 'b');
    thistext.HorizontalAlignment = 'center';

    %plot the group averaged GMFA offset by 4.5
    newyvector = [-100:500];
    p = plot(newyvector,mean(TEPdata_GMFA,1)-4.5);
    set(p, 'Color', 'green', 'LineWidth', 2);
    
    %fix legend entries
    L(1) = plot(nan, nan, 'r-', 'LineWidth', 3);
    L(2) = plot(nan, nan, 'k-');
    L(3) = plot(nan, nan, 'g-', 'LineWidth', 2);
    legend(L, {'F1', 'All other electrodes', 'GMFA'});
    set(gcf, 'Position',  [5, 5, 1500, 900]);
    cd (SaveDir);
    saveas(gcf, 'Grand_Average_ButterflyPlotTEP_F1_BL_leftpfc_ALZHEIMERS_ALL.png');
    saveas(gcf, 'Grand_Average_ButterflyPlotTEP_F1_BL_leftpfc_ALZHEIMERS_ALL.fig');