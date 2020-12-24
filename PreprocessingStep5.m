%% Step 5: Remove bad channel based on quality average CQ < 1

function [BadChannelList] = PreprocessingStep5(p, BadChannelList, filteredData, ChannelName)

marker = strings(1,14);

for i = 17:32
    if mean(filteredData(i,:)) < 1  
        marker(1,i-16) = ChannelName(i-16); %+" is Bad Channel";
    end
end

% show if any bad channel
marker(strcmp('',marker)) = [];
if numel(marker)>1
    fprintf('%s, ', marker{1:end-1});
    fprintf('and %s are bad channels.\n', marker{end}); 
    BadChannelList(p,1) = strcat(marker{1:end-1});
elseif numel(marker)>0
    fprintf('%s is a bad channel.\n', marker{end}); 
    BadChannelList(p,1) = join(marker{end});
end
end