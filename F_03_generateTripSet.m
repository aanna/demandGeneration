close all; clear; clc;

%% import booking file
disp('2. Import bookings...')
bookingFile = sprintf('boookings_ecbd_161.txt');
bkData = dlmread(bookingFile, ' ', 0, 0);
origX = bkData(:,4);
origY = bkData(:,5);
destX = bkData(:,6);
destY = bkData(:,7);

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

%% find trips which started or ended within the ecbd
disp('3. Find the nearest node for each o-d...')

nodes_o = zeros(length(origX),1);
nodes_d = zeros(length(origY),1);
for i = 1:length(origX)
    pos_xy_o = [origX(i) origY(i)];
    dist_array_o = pdist2(pos_xy_o, coord_ecbd, 'euclidean');
    [M_o, cust_iter] = min(dist_array_o);
    nodes_o(i) = node_id_eCBD(cust_iter);
    
    pos_xy_d = [destX(i) destY(i)];
    dist_array_d = pdist2(pos_xy_d, coord_ecbd, 'euclidean');
    [M_d, cust_iter] = min(dist_array_d);
    nodes_d(i) = node_id_eCBD(cust_iter);
    
end

%% delete repeated pairs
disp('4. Delete repeated pairs...')

od_pairs = [nodes_o nodes_d];
od_pairs_unique = unique(od_pairs,'rows');
o_pairs_unique = od_pairs_unique(:,1);
d_pairs_unique = od_pairs_unique(:,2);

indx = zeros(length(od_pairs_unique),1);
for i = 1 : length(od_pairs_unique)
    if(o_pairs_unique(i) ~= d_pairs_unique(i))
        indx(i) = 1;
    end
end

disp('5. Delete trips from and to the same node...')
indices = find(indx);
o_pairs_unique = o_pairs_unique(indices);
d_pairs_unique = d_pairs_unique(indices);

%% save to file
disp('9. Save nodes file...')
filenameC = sprintf('od_unique_ecbd_%d_%d.txt', length(origX), length(d_pairs_unique));
fileCustomers = fopen(filenameC,'w');

for j = 1:length(d_pairs_unique)
    fprintf(fileCustomers,'%0u %0u\n', o_pairs_unique(j), d_pairs_unique(j));
end
fclose(fileCustomers);

disp('All done.')