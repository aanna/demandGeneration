close all; clear; clc;

% last update: 2016-Mar-15
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
filename = 'input/activity_schedule_sample.txt';
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
coord_ecbd = [x_pos_eCBD y_pos_eCBD];

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

indx_array = zeros(length(trip_start_time),1);
for i = 1: length(trip_start_time)
    indx = find(node_id_eCBD == trip_origin_node(i) | node_id_eCBD == trip_destination_node(i));
    if(~isempty(indx))
        indx_array(i) = i;
    end
end

indx_array = find (indx_array);
time_before_convert = trip_start_time(indx_array);
% person_id = person_id(ids_witin); do not have to carry it forward
trip_origin_node = trip_origin_node(indx_array);
trip_destination_node = trip_destination_node(indx_array);
trip_purpose = trip_purpose(indx_array);
trip_mode = trip_mode(indx_array);

%% find coordinates for each origin and destination

disp('5. Find coordinates for each origin...')
origin_x = zeros(length(trip_origin_node), 1);
origin_y = zeros(length(trip_origin_node), 1);
for i = 1:length(trip_origin_node)
    cust_iter = find (node_id_eCBD == trip_origin_node(i));
    if (isempty(cust_iter))
        cust_iter = find (node_id_entireSG == trip_origin_node(i));
        % find coordinates of that node
        pos_xy = [x_pos_entireSG(cust_iter) y_pos_entireSG(cust_iter)];
        % and find the nearest node to this coodr in cbd and its indx
        dist_array = pdist2(pos_xy, coord_ecbd, 'euclidean');
        [M, cust_iter] = min(dist_array);
    end
    origin_x(i) = x_pos_eCBD (cust_iter); % in m
    origin_y(i) = y_pos_eCBD (cust_iter); % in m
    
end

disp('6. Find coordinates for each destination...')
dest_x = zeros(length(trip_destination_node), 1);
dest_y = zeros(length(trip_destination_node), 1);
for i = 1:length(trip_destination_node)
    cust_iter = find (node_id_eCBD == trip_destination_node(i));
    if (isempty(cust_iter))
        cust_iter = find (node_id_entireSG == trip_origin_node(i));
        % find coordinates of that node
        pos_xy = [x_pos_entireSG(cust_iter) y_pos_entireSG(cust_iter)];
        % and find the nearest node to this coodr in cbd and its indx
        dist_array = pdist2(pos_xy, coord_ecbd, 'euclidean');
        [M, cust_iter] = min(dist_array);
    end
    dest_x(i) = x_pos_eCBD (cust_iter); % in m
    dest_y(i) = y_pos_eCBD (cust_iter); % in m
    
end

%% convert time to seconds
disp('7. Convert time to seconds...')
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

% %% save to file
% disp('5. Save to file...')
% fileTOSave = sprintf('raw_bookings_ecbd_%d.txt', length(ids_witin));
% bookingFile = fopen(fileTOSave,'w');
% for j = 1:length(ids_witin)
%     fprintf(bookingFile,'%0u,%u,%0u,%0u,%s,%s\n', time_sec(j), j, trip_origin_node(j), trip_destination_node(j), trip_purpose{j}, trip_mode{j});
% end
% fclose(bookingFile);
%
% % newBooking_f = sprintf('bookings_ecbd_%d.txt', length(ids_witin));
% % delimiter = ' ';
% % dlmwrite(newBooking_f, customers_in_cbd, delimiter);
%
% disp('All done.')

%% Remove number from the carsharing mode
% in the original data the car sharing mode has a number of people who
% share the ride, i.e., car sharing 3 means that there is a driver plus 2
% extra passengers (while the passengers can get off somewhere on the way,
% we do not know exactly where they board and where they alight)

% TODO

%% choose mode of transport and trip purpose
disp('8. choose mode of transport and trip purpose...')
% available modes: BusTravel, MRT, PrivateBus, Car Sharing, Car, Taxi,
% Motorcycle
%chosen_mode = 'Car Sharing';
excluded_mode = 'MRT';
excluded_mode2 = 'BusTravel';
indx_mode1 = find(strcmp(trip_mode,excluded_mode));
indx_mode2 = find(strcmp(trip_mode,excluded_mode2));
indx_mode = sortrows([indx_mode1; indx_mode2]);
% trip purpose: Work, Home, Other, Shop, Education
%chosen_tripPurpose = 'Work';
%indx_purpose = find(strcmp(trip_purpose,chosen_tripPurpose));

% choose if the filter should be by mode (indx_mode) or by purpose
% (indx_purpose)
apply_chosen_filter = false;
apply_excluded_filter = true;
filter = indx_mode;
if (apply_chosen_filter)
    time_sec = time_sec (filter);
    origin_x = origin_x (filter);
    origin_y = origin_y (filter);
    dest_x = dest_x (filter);
    dest_y = dest_y (filter);
elseif (apply_excluded_filter)
    time_sec (filter) = [];
    origin_x (filter) = [];
    origin_y (filter) = [];
    dest_x (filter) = [];
    dest_y (filter) = [];
end

%% save to file
disp('9. Save customer file...')
filenameC = sprintf('customers_ecbd_%d.txt', length(origin_x));
fileCustomers = fopen(filenameC,'w');

for j = 1:length(origin_x)
    fprintf(fileCustomers,'%0u %0f %0f\n', j, origin_x(j), origin_y(j));
end
fclose(fileCustomers);

disp('10. Save booking file...')
amod_mode = 1; % mode = 1 if this is amod trip
filenameB = sprintf('boookings_ecbd_%d.txt', length(origin_x));
fileBookings = fopen(filenameB,'w');

for j = 1:length(origin_x)
    fprintf(fileBookings,'%0u %0u %0u %0f %0f %0f %0f %0u\n', j, time_sec(j), j, origin_x(j), origin_y(j), dest_x(j), dest_y(j), amod_mode);
end
fclose(fileBookings);

disp('All done.')