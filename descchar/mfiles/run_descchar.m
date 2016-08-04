% Run_descchar.m: This file works with views.py in Django app 'myapp' to run microstrut
% Run the most recently uploaded file 
c = clock; 
year = c(1); month = c(2); date = c(3);
if month < 10 % convert single digit to double
    str_month = ['0',num2str(month)];
else
    str_month = num2str(month);
end

if date < 10 % convert single digit to double
    str_date = ['0',num2str(date)];
else
    str_date = num2str(date);
end

path_to_file = ['../media/documents/',num2str(year),'/',str_month,'/',str_date,'/'];
working_dir = './descriptor_char/';

disp(path_to_file)

% find all .mat files in today's upload
f = dir([path_to_file,'*.mat']);

nf = length(f);

disp(nf)

for i = 1:nf
    if i == 1
        % first file of today
        timestamp = f(i).datenum;
        fid = i; 
    elseif f(i).datenum > timestamp
        % latest upload of today
        timestamp = f(i).datenum;
        fid = i;
    end
end

% filename of the most recently uploaded
fname = f(fid).name; 
[~,fnameonly,~] = fileparts(fname);

% save the image in jpg for direct viewing
load([path_to_file,fname])
%imwrite(img_out,'../media/documents/jpg/image.jpg','jpg')
imwrite(img_out,'/var/www/html/nm/image.jpg','jpg')  
% delete all current file in working dir
delete([working_dir,'imgs/*.mat'])

% copy file to MATLAB working dir
copyfile([path_to_file,fname],[working_dir,'imgs'])

% run characterization algorithm
run  ./descriptor_char/MAIN.m

% move char results to another folder
movefile([working_dir,'imgs/ch_result.mat'],'./char_result')

