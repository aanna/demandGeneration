close all; clear; clc;

% last update: 2016-July-19
% this script assumes that the trips are already filetered to the analyzed
% zone and mode. 
% based on the mid term output format script generates the amod trips.

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

% input: list of nodes and coordinates
% This file is based on the SimMobility output file out.network.txt,
% format:
% 1 node_id
% 2 x_coordinate
% 3 y_coordinate
% note that in SimMobility output the coordinates are in utm system in cm !
% therefore we have to convert them into meters (we do not use coordinates
% in this script, only the node ids)

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
filename = 'input-2016-07/dasCorrected.csv';
delimiter = ',';
formatSpec = '%s%f%s%f%s%f%f%s%s%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);

%person_id = dataArray{:, 1};
%tour_no = dataArray{:, 2};
%tour_purpose = dataArray{:, 3};
%stop_no = dataArray{:, 4};
%trip_purpose = dataArray{:, 5}; % stop_type
trip_destination_node = dataArray{:, 6}; % location of activity
%trip_destination_zone = dataArray{:, 7}; % TAZ zone
%trip_mode = dataArray{:, 8};
%isItPrimaryActivity = dataArray{:, 9};
%time_activity_starts = dataArray{:, 10};
%time_activity_ends = dataArray{:, 11};
trip_origin_node = dataArray{:, 12};
%previous_location_zone = dataArray{:, 13};
trip_start_time = dataArray{:, 14};

clearvars filename delimiter formatSpec fileID dataArray ans;

%% import list of nodes within the analysed zone
disp('2. Import list of nodes within the analysed zone...')
filename = 'input-2016-07/ecbd_nodes_noSink_19-Jul-2016.txt';
delimiter = ' ';
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

node_id_eCBD = dataArray{:, 1};
x_pos_eCBD = dataArray{:, 2}; % in cm
y_pos_eCBD = dataArray{:, 3}; % in cm
coord_ecbd = [x_pos_eCBD y_pos_eCBD];

clearvars filename delimiter formatSpec fileID dataArray ans;

%% convert time to seconds
disp('3. Convert time to seconds...')
% input time is as follows:
% day starts at 3am and finishes at 26hr
% the time for trips is in 30 minutes intervals and coded as following:
%  3.25 -> trips between 3-3:30am
%  3.75 -> trips between 3:30-4am etc up to 26.75 for the trips between 2:30-3am

% output time
% in seconds starting at 3am = 0sec

hours = floor(trip_start_time/1);
minutes = rem(trip_start_time, 1);

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

%% Find coordinates for each origin
disp('4. Find coordinates for each origin...')
origin_x = zeros(length(trip_origin_node), 1);
origin_y = zeros(length(trip_origin_node), 1);
for i = 1:length(trip_origin_node)
    cust_iter = find (node_id_eCBD == trip_origin_node(i));
    if (isempty(cust_iter))
        % it is a sink node and a replacement for this node has to be found
        
    end
    origin_x(i) = x_pos_eCBD (cust_iter); % in m
    origin_y(i) = y_pos_eCBD (cust_iter); % in m
    
end

disp('5. Find coordinates for each destination...')
dest_x = zeros(length(trip_destination_node), 1);
dest_y = zeros(length(trip_destination_node), 1);
for i = 1:length(trip_destination_node)
    cust_iter = find (node_id_eCBD == trip_destination_node(i));
    if (isempty(cust_iter))
        % it is a sink node and a replacement for this node has to be found
        
    end
    dest_x(i) = x_pos_eCBD (cust_iter); % in m
    dest_y(i) = y_pos_eCBD (cust_iter); % in m
    
end

%% save to file
disp('6. Save customer file...')

c = datetime('today');
dateString = datestr(c);

filenameC = sprintf('customers_ecbd_%d_%s.txt', length(origin_x), dateString);
fileCustomers = fopen(filenameC,'w');

for j = 1:length(origin_x)
    fprintf(fileCustomers,'%0u %0f %0f\n', j, origin_x(j), origin_y(j));
end
fclose(fileCustomers);

disp('10. Save booking file...')
amod_mode = 1; % mode = 1 if this is amod trip
filenameB = sprintf('boookings_ecbd_%d_%s.txt', length(origin_x), dateString);
fileBookings = fopen(filenameB,'w');

for j = 1:length(origin_x)
    fprintf(fileBookings,'%0u %0u %0u %0f %0f %0f %0f %0u\n', j, time_sec(j), j, origin_x(j), origin_y(j), dest_x(j), dest_y(j), amod_mode);
end
fclose(fileBookings);

disp('All done.')