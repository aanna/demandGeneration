close all; clear; clc;

% This script changes the start time of the trips to account for the 
% simulation start time. Originally the trip start time is reflected as a 
% time left from midnight (0 sec = midnight)
% Now the simulation start time is going to be 3am
sim_start_time = 3 *3600; % 3am in seconds
end_day = 24*3600;

disp('1. Import bookings...')
bookingFile = sprintf('boookings_ecbd_sorted_808356.txt');
bkData = dlmread(bookingFile, ' ', 0, 0);
bk_id = bkData(:,1);
bk_time = bkData(:,2);
origX = bkData(:,4);
origY = bkData(:,5);
destX = bkData(:,6);
destY = bkData(:,7);

clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% Change booking time
disp('2. Change booking time...')
% 
for i =1 : length (bk_id)
   if (bk_time (i) < sim_start_time)
    bk_time (i) = bk_time(i) + end_day;
   else
       bk_time (i) = bk_time(i) - sim_start_time;
   end
end

%% Sort according to time
disp('Sort based on time...')
% do from the terminal

%% Save to file
disp('3. Save converted but not sorted bookings...')

amod_mode = 1; % mode = 1 if this is amod trip
filenameB = sprintf('boookings_ecbd_start%dam_%d.txt', sim_start_time/3600, length(bk_id));
fileBookings = fopen(filenameB,'w');

for j = 1:length(bk_id)
    fprintf(fileBookings,'%0u %0u %0u %0f %0f %0f %0f %0u\n', j, bk_time(j), j, origX(j), origY(j), destX(j), destY(j), amod_mode);
end
fclose(fileBookings);

disp('All done.')