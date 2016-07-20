close all; clear; clc;

% last update: 2016-Mar-09
% script converts the trips into the format consistent with AMOD simulator.
% it can also be defined which mode of transport or what purpose of trips
% we want to substitute by amod. By default all trips are selected.

% the file also processes the Car Sharing trips, meaning in the data set
% the car sharing trip may consists of few passengers

% input: the output from F_01 (column headers)
% trips in format: 
% 1 time_sec, integer
% 2 booking_id, integer
% 3 trip_origin_node, integer
% 4 trip_destination_node, integer
% 5 trip_purpose, character varying
% 6 trip_mode, character varying

% input: list of nodes and coordinates
% This file is based on the SimMobility output file out.network.txt,
% format:
% 1 node_id
% 2 x_coordinate
% 3 y_coordinate
% note that in SimMobility output the coordinates are in utm system in m
% amod simulator uses utm meters too :)

% output format:
% customers file (column headers) 
% 1 customer_id 
% 2 home_node_x (same as the source_node_x in booking file)
% 3 home_node_y (same as the source_node_y in booking file)

% booking file (column headers):
% 1 booking_id 
% 2 booking_time 
% 3 customer_id 
% 4 source_node_x 
% 5 source_node_y 
% 6 destination_node_x 
% 7 destination_node_x 
% 8 travel_mode

%% import trips for the entire Singapore
disp('1. Import all trips...')
filename = 'input/raw_bookings_ecbd_330.txt';
delimiter = ',';
formatSpec = '%f%f%f%f%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);

time_sec = dataArray{:, 1};
booking_id = dataArray{:, 2};
trip_origin_node = dataArray{:, 3};
trip_destination_node = dataArray{:, 4};
trip_purpose = dataArray{:, 5};
trip_mode = dataArray{:, 6};

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
x_pos_entireSG = dataArray{:, 2}; % in m
y_pos_entireSG = dataArray{:, 3}; % in m

clearvars filename delimiter formatSpec fileID dataArray ans;

%% find coordinates for each origin and destination

disp('3. Find coordinates for each origin...')
origin_x = zeros(length(trip_origin_node), 1);
origin_y = zeros(length(trip_origin_node), 1);
for i = 1:length(trip_origin_node)
    cust_iter = find (node_id_entireSG == trip_origin_node(i));
    origin_x(i) = x_pos_entireSG (cust_iter); % in m
    origin_y(i) = y_pos_entireSG (cust_iter); % in m
    
end

disp('4. Find coordinates for each destination...')
dest_x = zeros(length(trip_destination_node), 1);
dest_y = zeros(length(trip_destination_node), 1);
for i = 1:length(trip_destination_node)
    cust_iter = find (node_id_entireSG == trip_destination_node(i));
    dest_x(i) = x_pos_entireSG (cust_iter); % in m
    dest_y(i) = y_pos_entireSG (cust_iter); % in m
    
end

%% Remove number from the carsharing mode
% in the original data the car sharing mode has a number of people who
% share the ride, i.e., car sharing 3 means that there is a driver plus 2
% extra passengers (while the passengers can get off somewhere on the way,
% we do not know exactly where they board and where they alight)

% TODO

%% choose mode of transport and trip purpose
% available modes: BusTravel, MRT, PrivateBus, Car Sharing, Car, Taxi,
% Motorcycle
chosen_mode = 'Car Sharing';
indx_mode = find(strcmp(trip_mode,chosen_mode));
% trip purpose: Work, Home, Other, Shop, Education
chosen_tripPurpose = 'Work';
indx_purpose = find(strcmp(trip_purpose,chosen_tripPurpose));

% choose if the filter should be by mode (indx_mode) or by purpose
% (indx_purpose)
apply_filter = false;
filter = indx_mode;
if (apply_filter)
    time_sec = time_sec (filter);
    origin_x = origin_x (filter);
    origin_y = origin_y (filter);
    dest_x = dest_x (filter);
    dest_y = dest_y (filter); 
end

%% save to file
disp('5. Save customer file...')
filenameC = sprintf('customers_ecbd_%d.txt', length(origin_x));
fileCustomers = fopen(filenameC,'w');

for j = 1:length(origin_x) 
    fprintf(fileCustomers,'%0u %0f %0f\n', j, origin_x(j), origin_y(j));
end
fclose(fileCustomers);

disp('6. Save booking file...')
amod_mode = 1; % mode = 1 if this is amod trip
filenameB = sprintf('boookings_ecbd_%d.txt', length(origin_x));
fileBookings = fopen(filenameB,'w');

for j = 1:length(origin_x) 
    fprintf(fileBookings,'%0u %0u %0u %0f %0f %0f %0f %0u\n', j, time_sec(j), j, origin_x(j), origin_y(j), dest_x(j), dest_y(j), amod_mode);
end
fclose(fileBookings);

disp('All done.')
