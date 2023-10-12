function createBIDS_events_physocLocal(EventsData)

%% Template Matlab script to create a BIDS compatible sub-01_ses-01_task-FullExample-01_events.tsv file
% This example lists all required and optional fields.
% When adding additional metadata please use camelcase
% 
%
% anushkab, 2018
% updated for VPNL by EG, 8/18
%%

root_dir = EventsData.rootdir;
project_label = EventsData.ProjectLabel;
sub_id = num2str(EventsData.SubID);
ses_id = EventsData.SesID;
task_id = EventsData.TaskID; 
run_id = num2str(EventsData.RunID);

acquisition = 'beh';

funcDir = fullfile(root_dir, 'beh'); %project_label, [sub_id], ['ses-' ses_id],acquisition);

events_tsv_name = fullfile(funcDir, [sub_id, '_task-', task_id, '_run-', run_id, '_events.tsv']);
              
%% make a _events table and save 
%% CONTAINS a set of REQUIRED and OPTIONAL columns
onset = EventsData.Events(:, 1);%[0]'; %REQUIRED Onset (in seconds) of the event  measured from the beginning of the acquisition of the first volume in the corresponding task imaging data file.  If any acquired scans have been discarded before forming the imaging data file, ensure that a time of 0 corresponds to the first image stored. In other words negative numbers in “onset” are allowed.

% REQUIRED. Duration of the event (measured  from onset) in seconds.  Must always be either zero or positive. A "duration" value of zero implies that the delta function or event is so short as to be effectively modeled as an impulse.
duration = EventsData.Events(:, 2);%[0]'; 

%OPTIONAL Primary categorisation of each trial to identify them as instances of the experimental conditions
trial_type = EventsData.EventLabels;

%OPTIONAL.
if size(EventsData.Events, 2) == 2
     t = table(onset,duration,trial_type);%,response_time,stim_file,HED);
else
    stim_id = EventsData.Events(:, 3);
    response = EventsData.Events(:, 4);
    accuracy = EventsData.Events(:, 5);
    response_time = EventsData.Events(:, 6);
    t = table(onset,duration,trial_type, stim_id, response, accuracy, response_time);%,response_time,stim_file,HED);

end

if ~exist(funcDir) 
    mkdir(funcDir);
end

writetable(t,events_tsv_name,'FileType','text','Delimiter','\t');
