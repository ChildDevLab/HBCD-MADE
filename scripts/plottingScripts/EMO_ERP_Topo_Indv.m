%% EMO Plot ERPs and Topos

EEG = pop_loadset([[output_location filesep 'processed_data' filesep ] strrep(event_struct.file_names{run}, '_desc-filtered_eeg.set', '_desc-filteredprocessed_eeg.set')]);

% % Read the JSON file contents
jsonStr = fileread(json_settings_file);
% 
% % Decode the JSON data into a MATLAB struct
settingsData = jsondecode(jsonStr);

%participant_label = 'sub-PIUMD0059';
subject_ID = participant_label;

% Plot reg topo range

PeakStart = 1000*settingsData.EMO.ERP_window_start; %final PeakStart is in MS
PeakEnd = 1000*settingsData.EMO.ERP_window_end; %It crashes if you put the maximum limit, is should be slightly below that %MA

Start = -(1000*settingsData.EMO.pre_latency);
End = (1000*settingsData.EMO.post_latency)-2;

ROIname = settingsData.EMO.ROI_of_interest;
ROI = settingsData.clusters.(ROIname)';

EEG = pop_selectevent(EEG, 'type', {'stm+'}, 'deleteevents','on');


%This small chunk of code would get rid of NaN in Condition and select only the one of interest
T = struct2table( EEG.event );
[R,TF] = rmmissing(T,'DataVariables',{'Condition'});
G = table2struct(R);
Xt = G';
EEG.event = Xt;

events = find(strcmp({EEG.event.type}, 'stm+'));

for t = events
    EEG.event(t).type =  EEG.event(t).Condition;
    EEG.event(t).stim =  EEG.event(t).Condition; %MA
    EEG.event(t).Stim_type =  EEG.event(t).Condition;
end

% anger
try
    EEG_a = pop_selectevent(EEG, 'Stim_type', 'stm_anger', 'deleteevents','on');
    EEG_a = eeg_checkset(EEG_a);
catch
    EEG_a = EEG;
    EEG_a.data(EEG_a.data <= 9999999) = 0;
    EEG_a.trials = 0;
end

% calm
try
    EEG_c = pop_selectevent(EEG, 'Stim_type', 'stm_calm', 'deleteevents','on');
    EEG_c = eeg_checkset(EEG_c);
catch
    EEG_c = EEG;
    EEG_c.data(EEG_c.data <= 9999999) = 0;
    EEG_c.trials = 0;
end

% fearful
try
    EEG_f = pop_selectevent(EEG, 'Stim_type', 'stm_fearful', 'deleteevents','on');
    EEG_f = eeg_checkset(EEG_f);
catch
    EEG_f = EEG;
    EEG_f.data(EEG_f.data <= 9999999) = 0;
    EEG_f.trials = 0;
end

% happy
try
    EEG_h = pop_selectevent(EEG, 'Stim_type', 'stm_happy', 'deleteevents','on');
    EEG_h = eeg_checkset(EEG_h);
catch
    EEG_h = EEG;
    EEG_h.data(EEG_h.data <= 9999999) = 0;
    EEG_h.trials = 0;
end


i = i+1;
meanEpoch_a = mean(EEG_a.data, 3); %average across epochs for each condition and participant
allData(1, :, :) = meanEpoch_a;

meanEpoch_c = mean(EEG_c.data, 3);
allData(2, :, :) = meanEpoch_c;

meanEpoch_f = mean(EEG_f.data, 3);
allData(3, :, :) = meanEpoch_f;

meanEpoch_h = mean(EEG_h.data, 3);
allData(4, :, :) = meanEpoch_h;

Conditions = {'angry', 'calm', 'fearful', 'happy'};
Channels = EEG.chanlocs;
Times = EEG.times;
save_name_whole = [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', 'ERP.mat')];
save([save_path filesep save_name_whole], 'Conditions', 'Channels', 'Times', 'allData')

%%
%%%TOPO BEGIN HERE
NumberOfConditions = size(allData,1);
NumberOfChannels = size(allData,2);
NumberOfPoints = size(allData,3);

PeakRange = find(EEG.times == PeakStart):find(EEG.times == PeakEnd);

PeakData = squeeze(allData(:,:,PeakRange)); % Selecting time of interest
PeakData = squeeze(mean(PeakData,3)); % Averaging across time of interest 

PeakData_a = squeeze(PeakData(1,:));
PeakData_c = squeeze(PeakData(2,:));
PeakData_f = squeeze(PeakData(3,:));
PeakData_h = squeeze(PeakData(4,:));
%PeakData_a = squeeze(PeakData('stm_anger',:)); % Selecting condition Upright 
%PeakData_c = squeeze(PeakData('stm_calm',:)); % Selecting condition Inverted
%PeakData_f = squeeze(PeakData('stm_fearful',:)); % Selecting condition Object
%PeakData_h = squeeze(PeakData('stm_happy',:)); % Selecting condition Upright2

set(0,'DefaultFigureVisible','off');

PeakStart_n = num2str(PeakStart);
PeakEnd_n = num2str(PeakEnd);

EEG_a_trials = num2str(EEG_a.trials);
EEG_c_trials = num2str(EEG_c.trials);
EEG_f_trials = num2str(EEG_f.trials);
EEG_h_trials = num2str(EEG_h.trials);
infoSafeTitle = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_a_trials,',',EEG_c_trials,',',EEG_f_trials,',',EEG_h_trials);



erp = figure;
infoSafeTitle_a = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_a_trials);
topoplot(PeakData_a, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Angry',infoSafeTitle_a), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'angry_topo.jpg';
merged_Plot_Name = [subject_ID, '_', session_label, '_', Plot_Name];
saveas(erp, [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', Plot_Name)]);

erp = figure;
infoSafeTitle_c = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_c_trials);
topoplot(PeakData_c, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Calm',infoSafeTitle_c), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'calm_topo.jpg';
merged_Plot_Name = [subject_ID, '_', session_label, '_', Plot_Name];
saveas(erp, [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', Plot_Name)]);

erp = figure;
infoSafeTitle_f = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_f_trials);
topoplot(PeakData_f, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Fearful',infoSafeTitle_f), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'fearful_topo.jpg';
merged_Plot_Name = [subject_ID, '_', session_label, '_', Plot_Name];
saveas(erp, [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', Plot_Name)]);

erp = figure;
infoSafeTitle_h = strcat('-',PeakStart_n,'-',PeakEnd_n,' ', ' n= ', EEG_h_trials);
topoplot(PeakData_h, EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
title(strcat('Happy',infoSafeTitle_h), 'FontSize', 20);
cbar('vert',0,[-.05 .05]*max(abs(date)));

cd(save_path)
Plot_Name = 'happy_topo.jpg';
merged_Plot_Name = [subject_ID, '_', session_label, '_', Plot_Name];
saveas(erp, [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', Plot_Name)]);

% Difference wave

%erp = figure;
%topoplot(PeakData_Dev - PeakData_Stan,EEG.chanlocs,'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
%title(strcat('Inverted vs Upright',infoSafeTitle), 'FontSize', 20);
%cbar('vert',0,[-.05 .05]*max(abs(date)));

%cd(save_path)
%Plot_Name = 'desc-diffInvVsUpr_topo.jpg';
%merged_Plot_Name = [subject_ID, '_', session_label, '_', Plot_Name];
%saveas(erp, [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', Plot_Name)]);

%erp = figure;
%topoplot(PeakData_Nov - PeakData_Up2, EEG.chanlocs, 'maplimits', [-5 5.0], 'electrodes', 'on', 'gridscale', 100)
%title(strcat('Object vs Upright2',infoSafeTitle), 'FontSize', 20);
%cbar('vert',0,[-.05 .05]*max(abs(date)));


%cd(save_path)
%Plot_Name = 'desc-diffObjVsUp2_topo.jpg';
%merged_Plot_Name = [subject_ID, '_', session_label, '_', Plot_Name];
%saveas(erp, [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', Plot_Name)]);

%%%TOPO ENDS HERE


%%
%%Individual ERPs starts here

name = [subject_ID,'_', session_label];

end_ind = interp1(EEG.times,1:length(EEG.times),End,'nearest');
start_ind = interp1(EEG.times,1:length(EEG.times),Start,'nearest');
Range = start_ind:end_ind;

ch = allData(:,:,1:length(Range)); %1:length(Range) instead of Range
p8_ind=find(ismember({EEG.chanlocs.labels},ROI));
ch = (ch(:,p8_ind,:));%64 FCz = 4, FZ = 6 %128 FCz = 6, Fz = 11 select channel(s) of interest Oz=75

%average across channels (unless there is only one channel of interest
ch = squeeze(mean(ch,2));

a = squeeze(ch(1,:,:));
c = squeeze(ch(2,:,:));
f = squeeze(ch(3,:,:));
h = squeeze(ch(4,:,:));
%a = squeeze(ch('stm_anger',:,:));
%c = squeeze(ch('stm_calm',:));
%f = squeeze(ch('stm_fearful',:));
%h = squeeze(ch('stm_happy',:,:));

blue = [0  0 1];
grey = [.5 .5 .5];
red = [1 0 0];
orange = [1 .5 0];


set(0,'DefaultFigureVisible','off');

title_figure = strcat(ROIname, '- N=', ...
    num2str(EEG_c.trials), ',', ...
    num2str(EEG_a.trials), ',', ...
    num2str(EEG_f.trials), ',', ...
    num2str(EEG_h.trials), ' '); %name, 
erp = figure;
hold on
plot(EEG.times(Range), c, 'color', grey, 'LineWidth', 1.5);
plot(EEG.times(Range), a, 'color', red, 'LineWidth', 1.5);
plot(EEG.times(Range), f, 'color', blue, 'LineWidth', 1.5);
plot(EEG.times(Range), h, 'color', orange, 'LineWidth', 1.5);
xlabel('Time (milliseconds)', 'FontSize', 12); % X-axis legend
ylabel('Amplitude (\muV)', 'FontSize', 12);    % Y-axis legend
title(title_figure, 'FontSize', 15);
legendHandle = legend('Calm', 'Angry', 'Fearful', 'Happy');
set(legendHandle, 'box', 'off', 'FontSize', 10);
hold off;

cd(save_path)
save_plot_name = strcat('desc-', ROIname, '_ERP.jpg');
saveas(erp, [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', save_plot_name)]);

%Diference
%novMinusstand = novel-standard2; % 3 minus 4 %Object Vs Upright2
%novMinusdeviant = deviant-standard; %2 minus 1 %Inverted vs Upright
%baseline = standard-standard;
%Upright2vs1 = standard2-standard;


%erp = figure;
%hold on
%plot(EEG.times(Range), novMinusstand, 'color', blue, 'LineWidth', 1.5);
%plot(EEG.times(Range), novMinusdeviant, 'color', red, 'LineWidth', 1.5);
%plot(EEG.times(Range), Upright2vs1, 'color', grey2, 'LineWidth', 1.5);
%plot(EEG.times(Range), baseline, 'color', grey, 'LineWidth', 1.5);
%xlabel('Time (milliseconds)', 'FontSize', 12); % X-axis legend
%ylabel('Amplitude (\muV)', 'FontSize', 12);    % Y-axis legend
%title(title_figure, 'FontSize', 20);
%legendHandle = legend('Object vs Upright Face', 'Inverted vs Upright Face', 'Upright 2 vs 1');
%set(legendHandle, 'box', 'off', 'FontSize', 10);
%hold off;

cd(save_path)
save_plot_name = strcat('desc-', ROIname, '_diffERP.jpg');
saveas(erp, [strrep(event_struct.file_names{run}, 'desc-filtered_eeg.set', save_plot_name)]);

%%Individual ERPs ends here

