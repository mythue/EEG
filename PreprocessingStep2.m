%% Step 2: FIR filter (through EEGLAB)

EEG = struct;
EEG.data = reGenData(1:num_channels,:);
EEG.srate = Fs;
EEG.pnts = length(reGenData(1,:));
EEG.nbchan = num_channels;
EEG.event = [];
EEG.urevent = [];
EEG.epoch = [];
EEG.trials = 1;
EEG.xmin = 0;
EEG.xmax = length(EEG.data(1,:));
EEG.icawinv =[];
EEG.icaweights = [];
EEG.icasphere = [];
EEG.icaact =[];
EEG.icachansind = [];
EEG.setname = 'reGenData';
EEG.comments = [];
EEG.etc = [];
EEG.chanlocs = [];
EEG.event = [];
EEG.history = "EEG.etc.eeglabvers = '2019.1'; % this tracks which version of EEGLAB is being used, you may ignore itEEG = pop_importdata('dataformat','matlab','nbchan',0,'data','C:\\Users\\qoo_m\\Documents\\Research Project_EEG\\MATLAB\\s1dm.mat','setname','Data','srate',128,'pnts',0,'xmin',0,'chanlocs','C:\\Users\\qoo_m\\Documents\\Research Project_EEG\\MATLAB\\Data Preprocessing\\eeg_loc_14.ced');EEG = eeg_checkset( EEG );EEG = pop_continuousartdet( EEG , 'ampth',  100, 'chanArray',  1:14, 'colorseg', [ 1 0.9765 0.5294], 'fcutoff', [ 0.5 40], 'forder',  100, 'numChanThreshold',  1, 'stepms',  500, 'threshType', 'peak-to-peak', 'winms',  1000 ); % GUI: 07-Nov-2020 12:34:30EEG = eeg_checkset( EEG )";
% ERPLAB.history = [];
locutoff = 0.5;
hicutoff = 40;
filtorder = 50;

EEG = pop_eegfilt(EEG, locutoff, hicutoff, filtorder);

% Plot comparison separate
t1 = 0:1/Fs:(length(EEG.data(1,:))-1)/Fs;
out = reshape(EEG.data(1:14,1:length(input_data(1,:))),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(t1, original, 'b', t1, out, 'r');
 for k=1:14
     subplot(4,4,k),plot(t1,original(k,:), 'b', t1, out(k,:), 'r');
     title(ChannelName(k));
 end

% One Figure
 
 for k = 1:14
     plot(1:length(out(k,:)), out(k,:)+(105000-7000*k));
     hold on
     title('Step 2 Result');
     ylim([0 105000]);
 end
 
legend(ChannelName);
