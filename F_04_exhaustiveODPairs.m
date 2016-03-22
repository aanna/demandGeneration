close all; clear; clc;
% script generates exhaustive od pairs

%% import list of nodes within the analysed zone
disp('1. Import list of nodes within the analysed zone...')
filename = 'input/ecbd_nodes.csv';
delimiter = ',';
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

node_id_eCBD = dataArray{:, 1};

clearvars filename delimiter formatSpec fileID dataArray ans;

%% generated ODs
disp('2. Generate ODs...')
origin = zeros(length(node_id_eCBD)*length(node_id_eCBD),1);
dest = zeros(length(node_id_eCBD)*length(node_id_eCBD),1);

k = 1;
for i = 1 : length(node_id_eCBD)
    for j = 1 : length(node_id_eCBD)
        origin(k) = node_id_eCBD(i); 
        dest(k) = node_id_eCBD(j);
        k = k + 1;
    end
end

%% save to file
disp('3. Save OD pairs...')
filenameB = sprintf('ODpairs_%d.txt', length(origin));
fileBookings = fopen(filenameB,'w');

for j = 1:length(origin)
    fprintf(fileBookings,'%0u %0u\n', origin(j), dest(j));
end
fclose(fileBookings);

disp('All done.')
