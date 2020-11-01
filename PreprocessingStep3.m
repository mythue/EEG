%% Step 3: Automatic conituous rejection in EEGLAB

% EEG = pop_rejcont(EEG, 'elecrange',[1:EEG.nbchan] ,'freqlimit',[20 40] ,'threshold',...
%     10,'epochlength',0.5,'contiguous',4,'addlength',0.25, 'taper', 'hamming');

% EEG = pop_continuousartdet(EEG , 'ampth',  200, 'chanArray',  1, 'colorseg', [ 1 0.9765 0.5294], 'forder',  100, 'numChanThreshold',  1,...
%   'stepms',  500, 'threshType', 'peak-to-peak', 'winms',  1000); % GUI: 25-Oct-2020 08:48:36

reGenData(1:num_channels,:) = EEG.data.data;

out=reshape(reGenData(1:14,:),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(1:length(original(1,:)), original, 'b', 1:length(out(1,:)), out, 'r');
 for k=1:14
     subplot(4,4,k),plot(1:length(original(1,:)), original(k,:), 'b', 1:length(out(1,:)), out(k,:), 'r');
     title(ChannelName(k));
 end