% %% Step 3: Automatic conituous rejection in EEGLAB
% 
% [EEG_out, selreg] = pop_rejcont(EEG, 'elecrange',[1:14] ,'freqlimit',[0.5 40] ,'threshold',...
%     10,'epochlength', 1,'contiguous',4,'addlength',0.5, 'taper', 'hamming'); % Autoreject: Automated artifact rejection for MEG and EEG data
% 
% fprintf('before auto_rej: %d, after auto_rej: %d', length(EEG.data(1,:)), ...
%     length(EEG_out.data(1,:))); 
% fprintf('Remaining : \n %.4f', length(EEG_out.data(1,:))/length(EEG.data(1,:))); % report pnts remaining
% 
% if length(EEG.data(1,:))~= length(EEG_out.data(1,:))
%     ord = 1:selreg(1,1)-1;
%     if length(selreg(:,1))>1
%         for i = 2:length(selreg(:,1))
%             ord = [ord selreg(i-1,2)+1:selreg(i,1)-1];
%             j = i;
%         end
%         if length(ord)<length(EEG_out.data(1,:))
%             ord = [ord selreg(j,2)+1:length(EEG.data(1,:))];
%         end
%     end
%     ordData = zeros(33, length(ord));
%     ordData(1:num_channels,:) = EEG_out.data;
%     for i = num_channels+1:33 
%         for j = 1:length(ordData(1,:))
%             ordData(i,j) = reGenData(i,ord(j));
%         end
%     end
% else
ordData = zeros(33, length(EEG.data(1,:)));
ordData(1:num_channels,:) = EEG.data;
ordData(num_channels+1:33, :) = reGenData(num_channels+1:33, :);
% end
% 
% % EEG_out = eeg_regepochs(EEG);
% % 
% % EEG = pop_continuousartdet(EEG , 'ampth',  100, 'chanArray',  1, 'colorseg', [ 1 0.9765 0.5294], 'forder',  100, 'numChanThreshold',  1,...
% %   'stepms',  500, 'threshType', 'peak-to-peak', 'winms',  1000); % GUI: 25-Oct-2020 08:48:36
% % 
% % [EEG_out2, Indexes] = pop_eegthresh( EEG_out, 1, 1:14, -100, ...
% %                100, 0, length(reGenData(1,:)/Fs), 0, 1);
% 
% % reGenData = zeros(1:33, EEG_out.data.data(1,:));
% % reGenData(1:num_channels,:) = EEG_out.data;
% 
% out = reshape(ordData(1:14,:),14,[],1);
% original = reshape(input_data(1:14,:), 14, [], 1);
%   
% plot(1:length(original(1,:)), original, 'b', 1:length(out(1,:)), out, 'r');
%  for k=1:14
%      subplot(4,4,k),plot(1:length(original(1,:)), original(k,:), 'b', 1:length(out(1,:)), out(k,:), 'r');
%      title(ChannelName(k));
%  end
%  
% %  for k=1:14
% %      subplot(14,1,k),plot(1:length(original(1,:)), original(k,:), 'b', 1:length(out(1,:)), out(k,:), 'r');
% %      title(ChannelName(k));
% %  end
%  
% %  for k = 1:14
% %      plot(1:length(EEG.data(k,:)), EEG.data(k,:)+7000*k);
% %      hold on
% %      title('Raw Data');
% %  end
% %  
% %  legend(ChannelName);
%  
%  for k = 1:14
%      plot(1:length(EEG_out.data(k,:)), EEG_out.data(k,:)+(2300-120*k));
%      hold on
%      title('Auto Continuous Rejected Data');
%      ylim([0 3500]);
%  end
%  
% legend(ChannelName);
