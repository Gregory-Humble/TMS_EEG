clear all; clc; close all;
workDir='E:\Alz_Clinical_Trial';
saveDir= 'E:\Alz_Clinical_Trial\Alz_Data_Analysis_10JAN20\TMSEEG\TMSEEG_ALZ_data';
mkdir(saveDir) %mkdir creates the folder of the saveDir path
cd(workDir) %changes directory to the workDir
dirList=dir() %returns a list of the elements of the current directory workDir
folders={dirList.name} %creates the variable folders which is a string of the names of the elements of dirList which is the current directory
folders=folders(3:end-2) %This corrects to take only the folders names that I need
for i=1:numel(folders) % loop through my list
    
    thisfolder=folders{i}; % returns the current folder name in folders and sets it to the thisfolder variable
    info=strsplit(thisfolder,' '); % split into info
    ID=info{1};                  % get ID num from folder name
    cd([workDir,filesep,thisfolder]);        % go to current folder
    
    %% WORKING IN SUBJECT DIRECTORY
    dirList=dir();
    files={dirList.name}
    files=files(7:end) %5 correct only files I need
    for j = 1:numel(files)
        cd([workDir,filesep,thisfolder]);        % go to current folder
        thisfile=files{j}
        info=strsplit(thisfile,{'_','.'}); % split into info
        ID=info{1};
        STIMSITE=info{2};
        TP=info{3};
        %setname= [ID,'_',TASK,'_',TP]
        cntname = [ID,'_',STIMSITE,'_',TP]
        source = [workDir,filesep,thisfolder,filesep,thisfile]
       
        OUT = [saveDir,filesep,STIMSITE,'_',TP]
        mkdir(OUT)
        copyfile(source,OUT,'f')
    end
end