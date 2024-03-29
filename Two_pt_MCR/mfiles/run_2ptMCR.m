function run2ptMCR(user_name,num_recon,correlation_choice)

%% Create Job ID and encrypt it %%
c = clock;  % To record temporal details
year = c(1); month = c(2); date = c(3);hour=c(4); minute=c(5); seconds=c(6); % define all time related variables
c(1) = c(1) + 7;
c(2) = c(2) + 13;
c(3) = c(3) + 17;
Job_ID = [num2str(c(2)),num2str(c(3)),num2str(c(4)),fliplr(num2str(c(1))),num2str(c(5)),num2str(c(6))];
%%%


time_stamp = ['H',num2str(hour),'/','M',num2str(minute)]; % create a time stamp to store files

if month < 10 % convert single digit to double
    str_month = ['0',num2str(month)];
else
    str_month = num2str(month);
end

if date < 10
   str_date = ['0',num2str(date)];
else
   str_date = num2str(date);
end


%% Write to Activity log %%
time_now= [num2str(year),':',num2str(month),':',num2str(date),':',num2str(hour),':',num2str(minute),':',num2str(seconds)];
user_activity = [time_now,' ',(user_name),' ','Reconstruction - Correlation Function Approach',' ',Job_ID];
fileID = fopen('./RunCount.num','a+');
fprintf(fileID,'\n%s\n',user_activity);
fclose(fileID);


stamp = [num2str(year),'/',str_month,'/',str_date,'/'];

path_to_file = ['../media/documents/',stamp]; 

 f = dir([path_to_file,'*.jpg']);
 disp([path_to_file,'*.jpg'])
 nf = length(f)
 
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

img = imread([path_to_file,fname]); % read the incming target and store pixel values

if length(size(img)) > 2
   img = img(:,:,1);
end

if (max(max(img))) > 1
  Target_img = round(img/256);
else
  Target_img = img;
end

if correlation_choice==2
    disp('2 pt lineal path');
end

path_to_write = ['/var/www/html/nm/Two_pt_MCR/Reconstruction/',Job_ID];

S2_target = evaluate(Target_img); % calculate S2 of target
L2_target = L_2D(Target_img);
Surf2_target = Ss_2D(Target_img);
C2_target = C2(Target_img);

S2_recon = zeros(length(S2_target),num_recon);
L2_recon = zeros(length(L2_target),num_recon);
Surf2_recon = zeros(length(Surf2_target),num_recon);
C2_recon = zeros(length(C2_target),num_recon);

time_req = zeros(num_recon,1);
error = zeros(num_recon,1);

for i = 1:num_recon
    [Recon_img,time_req(i,1),iter_req,error(i,1)] = two_point_recon(Target_img,size(Target_img,1),correlation_choice);
    if i==1
        mkdir(path_to_write);
	imwrite(img,[path_to_write,'/Target.jpg']);
    end
    S2_recon(:,i) = evaluate(Recon_img);
    L2_recon(:,i) = L_2D(Recon_img);
    Surf2_recon(:,i) = Ss_2D(Recon_img);
    C2_recon(:,i) = C2(Recon_img);
    imwrite(Recon_img,[path_to_write,'/Reconstruct',num2str(i),'.jpg']);
    save([path_to_write,'/Reconstruct',num2str(i),'.mat'],'Recon_img');
end

%%Plotting%%
figure('color',[1,1,1])
hold on;
plot( 0:1:length(S2_target)-1, S2_target , 'LineWidth',2.5);
legendInfo{1} = 'Target Image';
for i = 1 : num_recon
	plot( 0:1:length(S2_target)-1, S2_recon(:,i), 'LineWidth',2.5);
	legendInfo{i+1} = ['Reconstruction #',num2str(i)];
end
xlabel('Distance (Pixel)');
ylabel('2-point Correlation Function');
box on;
legend(legendInfo);
saveas(gcf,[path_to_write,'/Autocorrelation_Comparison.jpg']);
hold off;

figure('color',[1,1,1])
hold on;
plot( 0:1:length(L2_target)-1, L2_target , 'LineWidth',2.5);
for i = 1 : num_recon
	plot( 0:1:length(L2_target)-1, L2_recon(:,i), 'LineWidth',2.5);
end
xlabel('Distance (Pixel)');
ylabel('2-point Lineal Path Function');
box on;
legend(legendInfo);
saveas(gcf,[path_to_write,'/Lineal Path_Comparison.jpg']);
hold off;

figure('color',[1,1,1])
hold on;
plot( 0:1:length(C2_target)-1, C2_target , 'LineWidth',2.5);
for i=1:num_recon
	plot( 0:1:length(C2_target)-1, C2_recon(:,1),'LineWidth',2.5);
end
xlabel('Distance (Pixel)');
ylabel('2-point Cluster Correlation Function');
box on;
legend(legendInfo);
saveas(gcf,[path_to_write,'/Cluster Correlation_Comparison.jpg']);
hold off;

figure('color',[1,1,1])
hold on;
plot( 0:1:length(Surf2_target)-1, Surf2_target , 'LineWidth',2.5);
for i=1:num_recon
	plot( 0:1:length(Surf2_target)-1, Surf2_recon(:,1),'LineWidth',2.5);
end
xlabel('Distance (Pixel)');
ylabel('2-point Surface Correlation Function');
box on;
legend(legendInfo);
saveas(gcf,[path_to_write,'/Surface Correlation_Comparison.jpg']);
hold off;

%% Saving Useful Data %%
%Save correlations in single files
S2 = cat(2,S2_target,S2_recon);
L2 = cat(2,L2_target,L2_recon);
Cluster2 = cat(2,C2_target,C2_recon);
Surface2 = cat(2,Surf2_target,Surf2_recon);

save([path_to_write,'/2 Point Autocorrelation.mat'],'S2');
save([path_to_write,'/2 Point Lineal Path Correlation.mat'],'L2');
save([path_to_write,'/2 Point Cluster Correlation.mat'],'Cluster2');
save([path_to_write,'/2 Point Surface Correlation.mat'],'Surface2');

%%
delete_path = ['/home/NANOMINE/Develop/mdcs/Two_pt_MCR/media/documents/',stamp]
delete delete_path;

%% ZIP files %%
zip([path_to_write,'/Results.zip'],{'*'},path_to_write);
%% Email to user%%
Subject = ['Subject: Reconstruction complete for Job ID: ',Job_ID];
Body1 = 'Greeting from NanoMine!';
Body2 = 'You are receiving this email because you had submitted an image for reconstruction using 2 point correlation.';
Body3 = 'The reconstruction process is complete and you may view the images at : http://nanomine.northwestern.edu:8001/Two_pt_MCR_CheckResult.';
Body4 = ' You will need your Job ID for viewing the images. Details of reconstruction process are as follows:';
Metric1 = ['Time required for Job completion : ',num2str(sum(time_req)/3600),'hrs.'];
Metric2 = ['Number of Simulated annealing iterations per reconstructed image: ',num2str(iter_req)];
Metric3 = ['Average error: ',num2str(sum(error)/num_recon)];
Body5 = 'Best Wishes,';
Body6 = 'NanoMine Team.';
Footer = 'DO NOT REPLY TO THIS EMAIL.';

Body = [Body2,Body3,Body4];

fileID = fopen('/home/NANOMINE/Develop/mdcs/Two_pt_MCR/email.txt','wt+');
fprintf(fileID,'%s\n',Subject);
fprintf(fileID,'\n%s\n',Body1);
fprintf(fileID,'\n%s\n',Body);
fprintf(fileID,'\n%s\n',Metric1);
fprintf(fileID,'\n%s\n',Metric2);
fprintf(fileID,'\n%s\n',Metric3);
fprintf(fileID,'\n%s\n',Body5);
fprintf(fileID,'%s\n',Body6);
fprintf(fileID,'\n%s\n',Footer);
fclose(fileID);
end
