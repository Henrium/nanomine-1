
% Run niblack algorithm 

% Get current adjust from user input
file=fopen('adjust','r');
adjust=fscanf(file,['%u']);
fclose(file);

% default starting window size
%winsize = 60;
file=fopen('winsize','r');
winsize=fscanf(file,['%u']);
fclose(file);

c = clock; 
year = c(1); month = c(2); date = c(3);
if month < 10 % convert single digit to double
    str_month = ['0',num2str(month)];
else
    str_month = num2str(month);
end

path_to_file = ['../media/documents/',num2str(year),'/',str_month,'/',num2str(date),'/'];
working_dir = './niblack/';

disp(path_to_file)
% find all .mat files in today's upload
f = dir([path_to_file,'*.tif']);
disp([path_to_file,'*.tif'])
nf = length(f);

for i = 1:nf
    if i == 1
        timestamp = f(i).datenum;
        fid = i; 
    elseif f(i).datenum > timestamp
        timestamp = f(i).datenum;
        fid = i;
    end
end

% filename of the most recently uploaded
fname = f(fid).name; 
[~,fnameonly,~] = fileparts(fname);

% save the image in jpg for direct viewing
copyfile([path_to_file,fname],'../media/documents/jpg/NBbefore.jpg')
disp([path_to_file,fname])

% delete all current MAT files in working dir
delete([working_dir,'imgs/*.mat'])

% copy file to MATLAB working dir
copyfile([path_to_file,fname],[working_dir,'imgs'])

% run characterization algorithm
%run  ./myproject/mfiles/niblack/runniblack.m
addpath('./niblack/')

% Prompt user to input adjust value from web page
runniblack(fnameonly, winsize, adjust)

load_file =[working_dir,'imgs/',fnameonly,'.mat'];
load(load_file)
imwrite(img_out,'../media/documents/jpg/NBafter.jpg','jpg')

% move char results to another folder
movefile(load_file,'./niblack_result')
