%% ---------- Question 2 -----------%%
%%--- Compare MMN between patients and controls ---%

% clear
% close all
% clc

%% -- Load DATA from Workshop_Q1_Solutions.m --%%
path = ('/home/minseok/MATLAB/MATLAB/Week9/MMN_data');
cd (path) % cd = 'change directory'
filepath = fullfile(path, 'Epoched_data/Compiled');
files = dir(fullfile(filepath, '*.mat'));

%files = dir('*.mat');
for file = files'
    disp(file)
    load((fullfile(filepath, file.name)));
end

%% --------- Plot the averaged standard and deviant waves for all subjects

%------- Average all the compiled data frames
avg_standard_all_controls = mean(standards_all_controls);
avg_deviant_all_controls = mean(deviants_all_controls);
avg_standard_all_patients = mean(standards_all_patients);
avg_deviant_all_patients = mean(deviants_all_patients);
avg_MMN_all_controls = mean(MMN_all_controls);
avg_MMN_all_patients = mean(MMN_all_patients);

%--- Define latency
latency = [-50:250];

%---MMN in patients and controls
%---Hint: MMN is a negative wave, so plot the amplitudes in reverse using set (gca,'Ydir','reverse') 
figure
plot (latency, avg_MMN_all_controls)
xlim = ([-50 250]);
set (gca,'Ydir','reverse')
title('MMN in patients with schizophrenia and healthy controls')
xlabel('Latency (ms)')
ylabel('Amplitude (uv)')
hold on
plot (latency, avg_MMN_all_patients)
legend ('Controls', 'Patients')
hold off

%% STATISTICAL COMPARISON OF AVERAGED MMNs
ttest2(avg_MMN_all_patients, avg_MMN_all_controls)
