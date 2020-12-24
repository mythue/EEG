% Main
close all; 
clear all; 
clc;
% fds = fileDatastore('*.csv', 'ReadFcn', @importdata);
fds = fileDatastore('C:\Users\qoo_m\Documents\Research Project_EEG\DataPreprocessing',...
    'FileExtensions', {'.csv'},'IncludeSubfolders', true,'ReadFcn', @importdata);
fullFileNames = fds.Files;
numFiles = length(fullFileNames);

step = ["decision_making", "reading", "thinking"];

Fs = 128; %sampling rate
num_channels = 14; %number of channels
ChannelName = ["AF3", "F7", "F3", "FC5", "T7", "P7", "O1", "O2", ...
                      "P8", "T8", "FC6", "F4", "F8", "AF4"];

BadChannelList = strings(numFiles,1);
                  
for p = 0: numFiles-1
    data = readtable(char(fullFileNames(p+1)));
    data = table2array(data);
    input_data = data';
    filteredData = input_data;
%     PreprocessingStep1();
%     PreprocessingStep2();
%     PreprocessingStep3();
%     PreprocessingStep4();
    [BadChannelList] = PreprocessingStep5(p+1, BadChannelList, filteredData, ChannelName);
    [BadChannelList] = PreprocessingStep6(p+1, BadChannelList, filteredData, input_data, num_channels, ChannelName);
%     [BadChannelList, h1, h2] = PreprocessingStep6(p+1, BadChannelList, filteredData, input_data, num_channels, ChannelName);
%     filename = ['Subject', int2str(floor(p/21)+1), 'Scenario', int2str(floor(mod(p,21)/3)), step(mod(mod(p,21),3)+1), '.mat'];
%     fig1name = ['Subject', int2str(floor(p/21)+1), 'Scenario', int2str(floor(mod(p,21)/3)), step(mod(mod(p,21),3)+1), '1.fig'];
%     fig2name = ['Subject', int2str(floor(p/21)+1), 'Scenario', int2str(floor(mod(p,21)/3)), step(mod(mod(p,21),3)+1), '2.fig'];
%     filename = strjoin(filename);
%     fig1name = strjoin(fig1name);
%     fig2name = strjoin(fig2name);
%     save(filename, 'filteredData');
%     saveas(h1, fig1name, 'fig');
%     saveas(h2, fig2name, 'fig');
end