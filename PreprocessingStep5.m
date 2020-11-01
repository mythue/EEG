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
