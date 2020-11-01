%% Step 1: Eye movement removal
%% 1.1 Subdivide 1 sec windows (50% overlapping) 
%% 1.2 Delta Band Power for each window as the features
%% 1.3 Standard K-Means Algo (upper cutoff 5? Pending 7 or 8) K:2-5, 
%%        and examine the value of K that provides min Xie-Beni Index
%% 1.4 Extract data from the cluster with max size conditioned to 
%%        lowest delta power as valid data (non-blinking)
%% 1.5 0.5 Hz high pass signals were cleaned by replacing the data points 
%%        in eye blink region by the data corresponding to filtered output 
%%        of 4 Hz high pass filter 

close all; 
clear all; clc;
[data] = open_files();
input_data = data';
Fs = 128; %sampling rate
num_channels = 14; %number of channels

%% 1.1 Subdivide 1 sec windows (50% overlapping) 

windowlength = Fs;
windowstep = Fs/2;
data_length = length(input_data(1, :));
ext = mod(data_length,(Fs/2)); %get the remaining length in the last window
num_steps = fix(data_length/(Fs/2)); %numbers of windows
new_data = zeros(length(input_data(:, 1)), (num_steps-1)*Fs+ext); %create new data frame

%load data to new_data as window integration
for i = 1:num_steps-1
    new_data(:,(i-1)*Fs+1:i*Fs) = ...
    input_data(:,((i-1)*Fs/2)+1:((i-1)*Fs/2)+Fs);
end

%load the remaining data
for i = (num_steps-1)*Fs+1:(num_steps-1)*Fs+ext
    new_data(:,i) = input_data(:,data_length - ext + i - (num_steps-1)*Fs);
end


%% 1.2 Delta Band Power for each window as the features

delta_bandpower = zeros(num_channels, num_steps-1); %create delta band power matrix
delta_range = [0.5 4]; %delta band frequency range

for i = 1:num_steps-1
    for j = 1:num_channels
        delta_bandpower(j, i) = ...
            bandpower(new_data(j,(i-1)*Fs+1:i*Fs), Fs, delta_range);
    end
end

%% 1.3 Standard K-Means Algo (upper cutoff 5? Pending 7 or 8) K:2-5, 
%    and examine the value of K that provides min Xie-Beni Index

XB = inf; %define Xie-Beni index array
cutoff = 5; % set upper cutoff threshold

for i = 2:cutoff %find the min Xie-Beni through n_clusters from 2:5
    [center,U,obj_fcn] = FCMClustering(delta_bandpower,i);
    XB = [XB, min(obj_fcn)];
end

[XBindex, C] = min(XB); %find index and value of the min Xie-Beni index
% plotfcm(delta_bandpower, center, U, obj_fcn); %plot clusters

data4Kmeans = delta_bandpower'; % Transpose to fit Kmeans
[kmeansIdx, ctr] = kmeans(data4Kmeans, C); % get label array

new_data = [new_data;zeros(1,length(new_data(1,:)))]; % create label row
new_data = new_data(:,1:(num_steps-1)*Fs-1); % Adjust data length

% Merge label from Kmeans
for i = 1:length(new_data(1,:))
    new_data(33, i) = kmeansIdx(floor(i/Fs)+1,1);
end

%% 1.4 Extract data from cluster with max size and lowest delta power 

modeCluster = mode(kmeansIdx); % get largest cluster

% Remove overlapping
reGenData = zeros(length(input_data(:,1))+1,length(input_data(1,:)));
for i = 1:num_steps-1
    reGenData(:,((i-1)*Fs/2)+1:(i*Fs/2))=...
    new_data(:,(i-1)*Fs+1:(2*i-1)/2*Fs);
end

reGenData(1:32,(num_steps-1)*Fs/2:data_length) = ...
    input_data(:,(num_steps-1)*Fs/2:data_length);
reGenData(33,(num_steps-1)*Fs/2:data_length) = new_data(33,...
    length(new_data(1,:))-(data_length-((num_steps-1)*Fs/2)):...
    length(new_data(1,:)));

%% 1.5 0.5 Hz high pass signals were cleaned by replacing the data points 
%%        in eye blink region by the data corresponding to filtered output 
%%        of 4 Hz high pass filter 

%% 4 Hz High pass filter per window, remove overlapped part.

j=0;
r=0;
for i=1:length(reGenData(1,:))
    if reGenData(33,i)~= modeCluster
        j=j+1;
        r=j;
    else
        j=0;
    end
    if j==0 && r>0
        for m=1:num_channels
            reGenData(m,i-r+1:i)=highpass(reGenData(m,i-r+1:i), 4, Fs);
        end
        r=0;    
    elseif i==length(reGenData(1,:)) && j>0
        for m=1:num_channels
            reGenData(m,i-r+1:i)=highpass(reGenData(m,i-r+1:i), 4, Fs);
        end
    end
end

% Apply 0.5Hz highpass filter for all data
for i = 1:num_channels
    reGenData(i,:) = highpass(reGenData(i,:), 0.5, Fs);
end

% Decompose signal into intrinsic mode functions

for i = 1:num_channels
    [imf, residual] = emd(reGenData(i,:));

% Zero-out imfs with Freq below 3Hz
% Zero-out function value at times when above mean(M)+std(M), M is the
% extrema of absulute value of the IMF

    [hs, f, t, imfinsf, imfinse] = hht(imf, Fs);

    M = zeros(1, length(imf(:,1)));

    for j = 1:length(imf(1,:))
        M(1,j) = max(abs(imf(:,j)));
    end

    for j = 1:length(imf(1,:))
        if max(imfinsf(:,j))<3
            imf(:,j) = zeros(length(imf(:,j)),1);
        elseif max(imfinsf(:,j))<16
            for k = 1:length(imf(1,:))
                if imf(k,j) > mean(M)+std(M)
                    imf(k,j) = 0;
                end
            end
        end
    end

    % Sum of all imfs
    IMF = sum(imf,2);
    reGenData(i,:) = IMF';
end

% Plot
t1 = 0:1/Fs:(length(reGenData(1,:))-1)/Fs;
out=reshape(reGenData(1:14,1:length(input_data(1,:))),14,[],1);
original = reshape(input_data(1:14,:), 14, [], 1);
  
plot(t1, original, 'b', t1, out, 'r');
 for k=1:14
     subplot(4,4,k),plot(t1,original(k,:),'b', t1, out(k,:), 'r');
 end






