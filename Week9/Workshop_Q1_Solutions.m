%% ---------------------- WORKSHOP 9 Solutions -----------------------%%
%%%---------------------- Anjali March 2024 ------------------------%%
%%%------------------------- Question 1 ---------------------------%%

%% Fz_data :
%    Amplitude (y-axis)
%    Latency (x-axis)
%    Stimuli type (vertical lines interspaced)

close all

%% INITIALISE VARIABLES

%%---------- Set subject and group labels for saving files later
group = 'Controls';

%----------- Set path
path = ('/Users/anjalibhat/Documents/MATLAB/5PASNCBS_2024/Week_9/MMN_data');
cd (path) % cd = 'change directory'
files = dir(fullfile(path, group));
N = (length(files)) - 2; %number of subjects in group, accounting for ghost files
%% LOOP

for num = 1:N

%----------- Load data

load(fullfile('MMN_data', group, strcat('Fz_data_control', int2str(num), '.mat')));
sub = strcat('control', int2str(num));

%----------- Inspect data
len = length(Fz_data(:,1));
plot(Fz_data(1:len/15)) %plot the the EEG recording for the first half minute or so, just to check
title(sub)
xlabel('Latency (ms)')
ylabel('Amplitude (uv)')

%% FORMAT DATA

%%---------- Use the 'find' function to extract the onset times

% We are surprised when met with deviant stimuli
% Stimuli Type:
%   Use 1 if wish to represent standard stimuli
%   Use 2 if wish to represent deviant  stimuli
onsets = find(Fz_data(:,3) ~= 0); %Find the indices of the timepoints at which the stimuli were presented

% In this case, the timepoints (in the second column of Fz_data) are the
% same as the indices; but in case they are not, the following can be used
% to ensure the onsets variable contains the timepoints:

% for i = 1: length(onsets) 
%     n = onsets(i,1);
%     onsets(i,1) = Fz_data(n,2);
% end

%%---------- Separate data into epochs

%--- Onsets for epochs
% Chop up onsets into time windows
% 1075 time windows (rows); # stimuli presented
%    i := relevant point of onset
% - 50 := slightly before onset
% +250 := slightly after onset
for i = 1: length(onsets)
    window(i,:) = onsets(i)-50: onsets(i)+250; % each row is a time window of onsets
end

%--- Use onsets to epoch the amplitudes
[nrows, ncolumns] = size(window);

for i = 1:nrows
    for j = 1:ncolumns
        n = window(i,j);
        Epoched(i,j) = Fz_data(n,1); 
    end
end

%-----Baseline correct
for i = 1:length(Epoched)
    mean_amp = mean(Epoched(i,1:50));
    Epoched_data(i,:) = Epoched(i,:) - mean_amp;
end

%% COMPARE STANDARDS AND DEVIANTS

%%---------- Separate epoched amplitude data into standards and deviants
%--- Find the number of standard tones
nstandards = length(find(Fz_data(:,3) == 1)); 

%--- Find the number of deviant tones
ndeviants = length(find(Fz_data(:,3) == 2));

%--- For loop to assign the epoched data to 'standard' or 'deviant' matrices, respectively 

m = 1; % initialise indices that change within the for loop
n = 1; % initialise indices that change within the for loop

for i = 1:nrows
    x = onsets(i);
    if Fz_data(x,3) == 1
        standards(m,:) = Epoched_data(i,:);
        m = m+1;
    elseif Fz_data(x,3) == 2
        deviants(n,:) = Epoched_data(i,:);
        n = n+1; 
    end
end

%%---------- Use a for loop to plot all the standard waves on one plot
%%---------- Then do the same for deviants
latency = ([-50:250]);

% for i = 1: length(standards)
% plot(latency, standards(i,:)) 
% xlim = ([-50 250]);
% title('Standards')
% xlabel('Latency(ms)')
% ylabel('Amplitude (uv)')
% hold on
% end
% hold off
% 
% 
% for i = 1: length(deviants(:,1))
% plot(latency, deviants(i,:)) 
% xlim = ([-50 250]);
% title('Deviants')
% xlabel('Latency(ms)')
% ylabel('Amplitude (uv)')
% hold on
% end
% hold off

%%----------  Average the waves

avg_standard = mean(standards);
avg_deviant = mean(deviants); 

%--- Plot the averaged standard and deviant waves for the single subject
figure
plot(latency, avg_standard) 
xlim = ([-50 250]);
title('Deviants')
xlabel('Latency (ms)')
ylabel('Amplitude (uv)')
hold on

plot(latency, avg_deviant)
legend ('Standard', 'Deviant')
hold off

%% SAVING DATA
%%---------- Use the 'fullfile' and 'strcat' functions to save the epoched data (standards, deviants and all) as .mat files

% fullfile to specify where to put stuff
save(fullfile('Epoched_data', group, strcat('Epoched_', sub, '.mat')), 'Epoched_data')
save(fullfile('Epoched_data', group, strcat('standards_', sub, '.mat')), 'standards')
save(fullfile('Epoched_data', group, strcat('deviants_', sub, '.mat')), 'deviants')

%% COMPUTE MMN
%%--------- Compute the MMN 
MMN = avg_standard - avg_deviant;
plot(latency, MMN); 
save(fullfile('MMN', group, strcat('MMN_', sub, '.mat')), 'MMN')

%%---------------- Add the averaged waves to a compilation data frame
if group == 'Controls'
    standards_all_controls(num,:) = avg_standard;
    deviants_all_controls(num,:) = avg_deviant;
    MMN_all_controls(num,:) = MMN;
    save(fullfile('Epoched_data/Compiled', strcat('standards_all_controls.mat')), 'standards_all_controls')
    save(fullfile('Epoched_data/Compiled', strcat('deviants_all_controls.mat')), 'deviants_all_controls')
    save(fullfile('Epoched_data/Compiled', strcat('MMN_all_controls.mat')), 'MMN_all_controls')
elseif group == 'Patients'
    standards_all_patients(num,:) = avg_standard;
    deviants_all_patients(num,:) = avg_deviant;
    MMN_all_patients(num,:) = MMN;
    save(fullfile('Epoched_data/Compiled', strcat('standards_all_patients.mat')), 'standards_all_patients')
    save(fullfile('Epoched_data/Compiled', strcat('deviants_all_patients.mat')), 'deviants_all_patients')
    save(fullfile('Epoched_data/Compiled', strcat('MMN_all_patients.mat')), 'MMN_all_patients')
end

%% CLEAR EVERYTHING NOW - SO THAT THE WHOLE SCRIPT CAN BE LOOPED
%----- Clear all but compilation data frames (so they're not overwritten)
clear avg_deviant avg_standard deviants Epoched_data Fz_data 
clear i j latency m MMN n ncolumns ndeviants nrows nstandards num onsets standards
clear sub window x xlim
clc

end