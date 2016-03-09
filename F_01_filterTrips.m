close all; clear; clc;

% last update: 2016-Mar-09
% to filter the trips which are within the zone or coming to the zone or
% ending within the zone

% input is the activity-based schedule from SimMobility mid-term
% format: (column headers)
% 1   person_id character varying - unique id for each person
% 2   tour_no integer - describes if it is 1 or 2 or 3?tour in the day
% 3   tour_type character varying - purpose of the trip (in therms of the Primary Activity): work/shop/education/other
% 4   stop_no integer - stop to perform activities
% 5   stop_type character varying - what is the current activity the person performs
% 6   stop_location integer, // node id of the trip destination
% 7   stop_zone integer, // TAZ zone
% 8   stop_mode character varying, //trip mode
% 9   primary_stop boolean,
% 10   arrival_time numeric, // START TIME OF THE ACTIVITY
% 11  departure_time numeric, // END TIME OF THE ACTIVITY
% 12  prev_stop_location integer, //trip origin node
% 13  prev_stop_zone integer,
% 14  prev_stop_departure_time numeric, //trip start time

% output: 
% trips in format: 
% 1 time_sec, integer
% 2 booking_id, integer
% 3 trip_origin_node, integer
% 4 trip_destination_node, integer
% 5 trip_purpose, character varying
% 6 trip_mode, character varying

%% import trips for the entire Singapore
disp('1. Import the activity-based trips...')
filename = 'input/activity_schedule_sample.txt';
delimiter = ',';
formatSpec = '%s%f%s%f%s%f%f%s%s%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);

person_id = dataArray{:, 1};
%tour_no = dataArray{:, 2};
%tour_purpose = dataArray{:, 3};
%stop_no = dataArray{:, 4};
trip_purpose = dataArray{:, 5}; % stop_type
trip_destination_node = dataArray{:, 6}; % location of activity
%trip_destination_zone = dataArray{:, 7}; % TAZ zone
trip_mode = dataArray{:, 8};
%isItPrimaryActivity = dataArray{:, 9};
%time_activity_starts = dataArray{:, 10};
%time_activity_ends = dataArray{:, 11};
trip_origin_node = dataArray{:, 12};
%previous_location_zone = dataArray{:, 13};
trip_start_time = dataArray{:, 14};

clearvars filename delimiter formatSpec fileID dataArray ans;

%% import list of nodes within the analysed zone
disp('2. Import list of nodes within the analysed zone...')
filename = 'input/ecbd_nodes.csv';
delimiter = ',';
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

node_id_eCBD = dataArray{:, 1};
x_pos_eCBD = dataArray{:, 2}; % in cm
y_pos_eCBD = dataArray{:, 3}; % in cm

clearvars filename delimiter formatSpec fileID dataArray ans;

%% import list of nodes for the entire Singapore
disp('3. Import list of nodes for the entire Singapore...')
filename = 'input/entireSG_nodes.csv';
delimiter = ',';
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

node_id_entireSG = dataArray{:, 1};
x_pos_entireSG = dataArray{:, 2}; % in cm
y_pos_entireSG = dataArray{:, 3}; % in cm

clearvars filename delimiter formatSpec fileID dataArray ans;

%% find trips which started or ended within the ecbd
disp('4. Find trips which started or ended within the ecbd...')
ids_witin = [];

for i = 1: length(person_id)
    [indx, TorF] = find(node_id_eCBD == trip_origin_node(i) | node_id_eCBD == trip_destination_node(i));
     if (~isempty(indx))
         ids_witin = [ids_witin; i];
     end
end

time_before_convert = trip_start_time(ids_witin);
% person_id = person_id(ids_witin); do not have to carry it forward
trip_origin_node = trip_origin_node(ids_witin);
trip_destination_node = trip_destination_node(ids_witin);
trip_purpose = trip_purpose(ids_witin);
trip_mode = trip_mode(ids_witin);

%% convert time to seconds
% input time is as follows:
% day starts at 3am and finishes at 26hr
% the time for trips is in 30 minutes intervals and coded as following:
%  3.25 -> trips between 3-3:30am
%  3.75 -> trips between 3:30-4am etc up to 26.75 for the trips between 2:30-3am

% output time
% in seconds starting at 3am = 0sec

hours = floor(time_before_convert/1);
minutes = rem(time_before_convert, 1);

for i = 1 : length(hours)
    if (hours(i) == 25)
        hours(i) = 1;
    elseif (hours(i) == 26)
        hours(i) = 2;
    elseif (hours(i) == 24)
        hours(i) = 0;
    end
    
end

% minutes are uniformly distributed in the intervals of 30 minutes
for i = 1 : length(minutes)
    if (minutes(i) == 0.25)
        minutes(i) = randi([0, 29]);
        
    elseif (minutes(i) == 0.75)
        minutes(i) = randi([30, 59]);
    end
    
end
time_sec = hours*60*60 + minutes*60; % size after selection

%% sort trips in ascending order of time
% to sort the output file use the unix command:
% i.e., sorting file on the basis of 2nd field , numerically
% sort -t"," -k2n,2 file 
% in this specific output file use sort -t"," -k1n,1 file
% '-t' option is used to provide the delimiter in case of files with 
% delimiter. '-k' is used to specify the keys on the basis of which 
% the sorting has to be done. The format of '-k' is : '-km,n' where m is 
% the starting key and n is the ending key.

%% save to file
disp('5. Save to file...')
fileTOSave = sprintf('bookings_ecbd_%d.txt', length(ids_witin));
bookingFile = fopen(fileTOSave,'w');
for j = 1:length(ids_witin)
    fprintf(bookingFile,'%0u,%u,%0u,%0u,%s,%s\n', time_sec(j), j, trip_origin_node(j), trip_destination_node(j), trip_purpose{j}, trip_mode{j});
end
fclose(bookingFile);

% newBooking_f = sprintf('bookings_ecbd_%d.txt', length(ids_witin));
% delimiter = ' ';
% dlmwrite(newBooking_f, customers_in_cbd, delimiter);

disp('All done.')
