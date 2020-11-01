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
