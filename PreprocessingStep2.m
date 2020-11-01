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
EEG.xmax = max(max(EEG.data));
EEG.setname = 'reGenData';
EEG.comments = [];
% EEG.chanlocs = fscanf();
% ERPLAB.history = [];
locutoff = 0.5;
hicutoff = 40;
filtorder = 50;

EEG = pop_eegfilt(EEG, locutoff, hicutoff, filtorder);

% Plot comparison
t1 = 0:1/Fs:(length(EEG.data(1,:))-1)/Fs;
out = reshape(EEG.data(1:14,1:length(input_data(1,:))),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(t1, original, 'b', t1, out, 'r');
 for k=1:14
     subplot(4,4,k),plot(t1,original(k,:), 'b', t1, out(k,:), 'r');
 end

