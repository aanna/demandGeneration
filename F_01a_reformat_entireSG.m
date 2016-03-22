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
filename = '/home/kasia/Dropbox/matlab/2016-03-Demand_generation/input/activity_schedule.txt';
delimiter = ',';
formatSpec = '%s%f%s%f%s%f%f%s%s%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);

%person_id = dataArray{:, 1};
%tour_no = dataArray{:, 2};
%tour_purpose = dataArray{:, 3};
%stop_no = dataArray{:, 4};
trip_purpose = dataArray{:, 5}; % stop_type
trip_destination_node = dataArray{:, 6}; % location of activity
%trip_destination_zone = dataArray{:, 7}; % TAZ zone
%trip_mode = dataArray{:, 8};
%isItPrimaryActivity = dataArray{:, 9};
%time_activity_starts = dataArray{:, 10};
%time_activity_ends = dataArray{:, 11};
trip_origin_node = dataArray{:, 12};
%previous_location_zone = dataArray{:, 13};
%trip_start_time = dataArray{:, 14};

clearvars filename delimiter formatSpec fileID dataArray ans;

%% import list of nodes for the entire Singapore
% to find coordinates of the nodes
disp('2. Import list of nodes for the entire Singapore...')
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

%% find coordinates for each origin and destination

disp('3. Find coordinates for each origin...')
origin_x = zeros(length(trip_origin_node), 1);
origin_y = zeros(length(trip_origin_node), 1);
for i = 1:length(trip_origin_node)
    cust_iter = find (node_id_entireSG == trip_origin_node(i));
    origin_x(i) = x_pos_entireSG (cust_iter);
    origin_y(i) = y_pos_entireSG (cust_iter);
    
end

disp('4. Find coordinates for each destination...')
dest_x = zeros(length(trip_destination_node), 1);
dest_y = zeros(length(trip_destination_node), 1);
for i = 1:length(trip_destination_node)
    cust_iter = find (node_id_entireSG == trip_destination_node(i));
    dest_x(i) = x_pos_entireSG (cust_iter);
    dest_y(i) = y_pos_entireSG (cust_iter);
    
end


%% choose mode of transport and trip purpose
% available modes: BusTravel, MRT, PrivateBus, Car Sharing, Car, Taxi,
% Motorcycle
% chosen_mode = 'Car Sharing';
% indx_mode = find(strcmp(trip_mode,chosen_mode));
% trip purpose: Work, Home, Other, Shop, Education
disp('5. choose mode of transport and trip purpose...')
chosen_tripPurpose = 'Work';
indx_purpose = find(strcmp(trip_purpose,chosen_tripPurpose));

% choose if the filter should be by mode (indx_mode) or by purpose
% (indx_purpose)
apply_filter = true;
filter = indx_purpose;
if (apply_filter)
    origin_x = origin_x (filter);
    origin_y = origin_y (filter);
    dest_x = dest_x (filter);
    dest_y = dest_y (filter); 
end

%% figure
figure()
[values_Eo, centersO] = hist3([origin_x(:) origin_y(:)],[100 100]);
imagesc(values_Eo)
colorbar
%axis equal
axis xy

% figure
figure()
[values_Ed, centersD] = hist3([dest_x(:) dest_y(:)],[100 100]);
imagesc(values_Ed)
colorbar
%axis equal
axis xy

%% save to file
% disp('5. Save customer file...')
% filenameC = sprintf('customers_entireSG_%d.txt', length(origin_x));
% fileCustomers = fopen(filenameC,'w');
% 
% for j = 1:length(origin_x) 
%     fprintf(fileCustomers,'%0u %0f %0f\n', j, origin_x(j), origin_y(j));
% end
% fclose(fileCustomers);
% 
% disp('6. Save booking file...')
% amod_mode = 1; % mode = 1 if this is amod trip
% filenameB = sprintf('boookings_entireSG_%d.txt', length(origin_x));
% fileBookings = fopen(filenameB,'w');
% 
% for j = 1:length(origin_x) 
%     fprintf(fileBookings,'%0u %0f %0f %0f %0f %0u\n', j, origin_x(j), origin_y(j), dest_x(j), dest_y(j), amod_mode);
% end
% fclose(fileBookings);
% 
% disp('All done.')
