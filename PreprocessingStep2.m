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
out=reshape(EEG.data(1:14,1:length(input_data(1,:))),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(t1, original, 'b', t1, out, 'r');
 for k=1:14
     subplot(4,4,k),plot(t1,original(k,:), 'b', t1, out(k,:), 'r');
 end

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
 end

%% Step 4: Removing EOG-like artifacts and Head Movements
% 4.1 Butterworth bandpass filter with [1 15Hz], remove data when envelope
%         exceeding 4 std

bandpass_range = [1 15]; % Hz
n = 2; % Filter order: second order as default, try higher order for more accurate outputs

[b, a] = butter(n, bandpass_range/(Fs/2)); % Get filter coefficients
filteredData = zeros(length(reGenData(:,1)), length(reGenData(1,:)));

for i = 1:num_channels
    filteredData(i,:) = filtfilt(b, a, reGenData(i,:)); % Apply Butterworth filter using zero-phase filtering
end

% plot
out=reshape(filteredData(1:14,:),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(1:length(original(1,:)), original, 'b', 1:length(out(1,:)), out, 'r'); %blue for origin red for new data
 for k=1:14
     subplot(4,4,k),plot(1:length(original(1,:)), original(k,:), 'b', 1:length(out(1,:)), out(k,:), 'r');
 end

% Apply Hilbert Transform
for i = 1:num_channels
    filteredData(i,:) = abs(hilbert(filteredData(i,:)));
end

% Match the data
for i = num_channels+1:length(reGenData(:,1))
    filteredData(i,:) = reGenData(i, :);
end

% plot
out=reshape(filteredData(1:14,:),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(1:length(original(1,:)), original, 'b', 1:length(out(1,:)), out, 'r'); %blue for origin red for new data
 for k=1:14
     subplot(4,4,k),plot(1:length(original(1,:)), original(k,:), 'b', 1:length(out(1,:)), out(k,:), 'r');
 end

% Remove outliers 4 std above the mean
for i = 1:num_channels   
    idx = bsxfun(@gt, filteredData(i,:), mean(filteredData(i,:)) + ...
        4*std(filteredData(i,:)))|bsxfun(@lt, filteredData(i,:), ...
        mean(filteredData(i,:)) - 4*std(filteredData(i,:)));
    idx = any(idx, 1);
    filteredData(:, idx) = [];
end

% 4.2 Remove 2-axis gyroscope data over 5 std from the mean change

for i = num_channels+1:num_channels+2   
    idx = bsxfun(@gt, filteredData(i,:), mean(filteredData(i,:)) + ...
        5*std(filteredData(i,:)))|bsxfun(@lt, filteredData(i,:), ...
        mean(filteredData(i,:)) - 5*std(filteredData(i,:)));
    idx = any(idx, 1);
    filteredData(:, idx) = [];
end

%% Step 5: Remove bad channel based on quality average CQ < 1

marker = strings(1,14);
ChannelName = ["AF3", "F7", "F3", "FC5", "T7", "P7", "O1", "O2", ...
                      "P8", "T8", "FC6", "F4", "F8", "AF4"];

for i = 17:32
    if mean(filteredData(i,:)) < 1  
        marker(1,i-16) = ChannelName(i-16); %+" is Bad Channel";
    end
end

% show if any bad channel
marker(strcmp('',marker)) = [];
if strlength(marker)>0
    fprintf('%s, ', marker{1:end-1});
    fprintf('and %s are bad channels.\n', marker{end}); 
end

%% Step 6: Divide data into segments (10 or 5 ?pending, 1 segment 1/0.5 min) and flag channels that have 
%%             average variance 2 std over all channels; 
%%             segments with a variance over 3 std above the average variance of 
%%             the channel are flagged "bad"; 
%%             and all segments that have an average variance over 3 std 
%%             above the globe variance are marked "bad"


% Flag channels that consistently have a variance 3 std over all channels;
potentialBadChannel = zeros(num_channels, 1);

% Calculate Variance across channels

V = zeros(num_channels, 1);

for i = 1:num_channels
    
V(i,1) = var(filteredData(i, :), 0, 2);

end

badChannelMarker = strings(1,14);

for i = 1:num_channels
        if abs(V(i,1)) > mean(V)+3*std(V)
            potentialBadChannel(i,1) = 1; % Check for potential bad channels
            badChannelMarker(1,i) = ChannelName(i); 
        end
end

% show if any bad channel
badChannelMarker(strcmp('',badChannelMarker)) = [];
if strlength(badChannelMarker)>0 
    fprintf('%s, ', badChannelMarker{1:end-1});
    fprintf('and %s are bad channels.\n', badChannelMarker{end}); 
end

t1 = 0:1/Fs:(length(EEG.data(1,:))-1)/Fs;
out=reshape(filteredData(1:14,:),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(1:length(original(1,:)), original, 'b', 1:length(out(1,:)), out, 'r'); %blue for origin red for new data
 for k=1:14
     subplot(4,4,k),plot(1:length(original(1,:)), original(k,:), 'b', 1:length(out(1,:)), out(k,:), 'r');
 end
