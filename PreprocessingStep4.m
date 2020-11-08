%% Step 4: Removing EOG-like artifacts and Head Movements
% 4.1 Butterworth bandpass filter with [1 15Hz], remove data when envelope
%         exceeding 4 std

bandpass_range = [1 15]; % Hz
n = 2; % Filter order: second order as default, try higher order for more accurate outputs

[b, a] = butter(n, bandpass_range/(Fs/2)); % Get filter coefficients
filteredData = zeros(length(ordData(:,1)), length(ordData(1,:)));

for i = 1:num_channels
    filteredData(i,:) = filtfilt(b, a, ordData(i,:)); % Apply Butterworth filter using zero-phase filtering
end

% plot
out=reshape(filteredData(1:14,:),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(1:length(original(1,:)), original, 'b', 1:length(out(1,:)), out, 'r'); %blue for origin red for new data
 for k=1:14
     subplot(4,4,k),plot(1:length(original(1,:)), original(k,:), 'b', 1:length(out(1,:)), out(k,:), 'r');
     title(ChannelName(k));
 end

envelopeData = filteredData;
 
% Apply Hilbert Transform
for i = 1:num_channels
    envelopeData(i,:) = abs(hilbert(filteredData(i,:)));
end

% Match the data
for i = num_channels+1:length(ordData(:,1))
    filteredData(i,:) = ordData(i, :);
end

% plot
out=reshape(filteredData(1:14,:),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(1:length(original(1,:)), original, 'b', 1:length(out(1,:)), out, 'r'); %blue for origin red for new data
 for k=1:14
     subplot(4,4,k),plot(1:length(original(1,:)), original(k,:), 'b', 1:length(out(1,:)), out(k,:), 'r');
     title(ChannelName(k));
 end

% Remove outliers 4 std above the mean of envelope
for i = 1:num_channels   
    idx = bsxfun(@gt, envelopeData(i,:), mean(envelopeData(i,:)) + ...
        4*std(envelopeData(i,:)))|bsxfun(@lt, envelopeData(i,:), ...
        mean(envelopeData(i,:)) - 4*std(envelopeData(i,:)));
    idx = any(idx, 1);
    envelopeData(:, idx) = [];
    filteredData(:, idx) = [];
end

% plot
out=reshape(filteredData(1:14,:),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(1:length(original(1,:)), original, 'b', 1:length(out(1,:)), out, 'r'); %blue for origin red for new data
 for k=1:14
     subplot(4,4,k),plot(1:length(original(1,:)), original(k,:), 'b', 1:length(out(1,:)), out(k,:), 'r');
     title(ChannelName(k));
 end
 
% 4.2 Remove 2-axis gyroscope data over 5 std from the mean change

for i = num_channels+1:num_channels+2   
    idx = bsxfun(@gt, filteredData(i,:), mean(filteredData(i,:)) + ...
        5*std(filteredData(i,:)))|bsxfun(@lt, filteredData(i,:), ...
        mean(filteredData(i,:)) - 5*std(filteredData(i,:)));
    idx = any(idx, 1);
    filteredData(:, idx) = [];
end