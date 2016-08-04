function [NP_center,NP_center_sub] = generate_np_dist(VF,NP_radius,mean_num_NP,dev,ly,lx,lz,type,plot)
tic
%% The explanation of the function
% This function is used to generate a distribution of NP, the output is the
% core coordinates (both linear and sub) of NP. The algorithm is as follows
% 
% 1) divide total NP into several clusters, the number of NP per cluster is
% determined by a normal distribution with mu = mean_num_NP and sigma =
% dev;

% 2)Generate the core coordinates of each cluster center, a non-penetrating
% radius can be set to avoid overlap of clusters

% 3)Generate the coordiantes of each NP (center) within each cluster, the
% NP coordinates is generated successively. The newly added NP has be
% touching one of the existing NP, but the overlapping is limited by setting a
% peneration radius min_r. The sampling space increase with r^2.

%% The input variable
% VF- volume fraction
% mean_num_NP- average number of NP per cluster
% dev- deviation(sigma) of the normal distribution of how many particles per

% lx,ly,lz- simulation box, integer
% NP_radius (nm)


%% The output variable
% NP_center: linear index of the center coordinates of each NP in
% [lx,ly,lz];
% NP_center_sub: the sub index

%% Initializing parameters
global dist %the minimum distance to the boundary.
NP_vol = 4/3*3.14*NP_radius^3;
d = round(2*NP_radius); % distance between two NP core
N = lx*ly*lz*VF/NP_vol; % total number of NP
min_d = 2*NP_radius - 0.5; % non-penerating radius of each NP
max_num_NP = round(mean_num_NP + 4*dev); %ignore the portion away from 4 sigma
num_cluster = zeros(max_num_NP,1);

if strcmp(type,'string') || strcmp(type,'line') ||strcmp(type,'sheet') 
    coeff = 0;flg_type = 0;
else coeff = 0.2;flg_type = 1;
end

%% find the true average number of NP per cluster (used to estimiate how many clusters in total), accounting for the loss
% at normdist <0,
ratio = 1-normcdf(0,mean_num_NP,dev);
true_mean=0;
for i=1:1:max_num_NP
    true_mean = i*normpdf(i,mean_num_NP,dev)/ratio + true_mean;
end



%% record the number of clusters that contain i NPs
for i=1:1:max_num_NP
    num_cluster(i) = round(N/true_mean*normpdf(i,mean_num_NP,dev)/ratio);
end

 

%figure;
assignin('base','num_cluster',num_cluster);
%plot([1:1:size(num_cluster,2)],num_cluster);


tot_cluster = sum(num_cluster);
% if the num_cluster(i) is too small
if tot_cluster == 0 && N/mean_num_NP > 0.8
    for i=1:1:round(N/mean_num_NP)
        num_cluster(mean_num_NP+i-1) = 1;
    end
    tot_cluster = sum(num_cluster);
end

NP_center = zeros(tot_cluster,max_num_NP); % assign the size the NP_center (redundant)
disp(['the total number of clusters is ',num2str(tot_cluster)])



%% find the nonpenerating radius of each cluster
cluster_radius = zeros(tot_cluster,1);

for j=1:1:max_num_NP
    if j == 1
        for i=1:1:num_cluster(1)
            cluster_radius(i) = d/2;
        end
    else  
        for i=sum(num_cluster(1:j-1))+1:1:sum(num_cluster(1:j))
            cluster_radius(i) = d*j/2; % set to be the length of a string contain  j NP
        end
    end
end



%% find the center coordinates of one cluster
disp('now generating center of each cluster') 
cluster_center = zeros(tot_cluster,3);

for j=1:1:tot_cluster
        flg = 1;
        while flg == 1
            cluster_center(j,:) = [randi([1,ly]),randi([1,lx]),randi([1,lz])];
            cluster_center(j,:) = PBC_dist(cluster_center(j,:),[ly,lx,lz],dist);
            disp(num2str(cluster_center(j,:)));
            % Then a while loop is used to avoid overlapping of each cluster
            i = 1; % looping variable
            flg_c = zeros(j-1); %boole varible in inner while loop
            
            while j > 1 && i < j && flg_type == 1;
                if pdist([cluster_center(j,:);cluster_center(i,:)]) < coeff*(cluster_radius(i) + cluster_radius(j)) % this confinement does not impact significantly to overlap
                        flg_c(i) = 1;    
                end
                        i=i+1;            
            end
            
            if sum(flg_c) == 0
                flg = 0; % stop loop
                %disp(['find',num2str(j)]);
                NP_center(j,1) =  sub2ind([ly,lx,lz],cluster_center(j,1),cluster_center(j,2),cluster_center(j,3));
            end   
            
        end   
end
toc

%% find the NP_coordinates within each cluster

for j=2:1:max_num_NP % every type of cluster (j NP in each cluster)
    for i=sum(num_cluster(1:j-1))+1:1:sum(num_cluster(1:j)) % every cluster within each type, total number num_cluster(j),ith cluster
        disp(['now assembling No.',num2str(i),' cluster'])  
        
        center = zeros(j,3); % assigne the matrix to record the sub coordinates of each NP within this type of cluster
        center(1,:) = cluster_center(i,:);   
        blacklist = zeros(j,1);% set up a blacklist in case the neigbors around a NP is all occupied
        
        if strcmp(type,'line')
            addx0 = randi([-d,d]);
            abs_addy0 = floor(sqrt(d^2-addx0^2));
            addy0 = randi([-abs_addy0,abs_addy0]);
            abs_addz0 = floor(sqrt(d^2-addx0^2-addy0^2));
            addz0 = randi([-abs_addz0,abs_addz0]);
            
            add=[addx0,addy0,addz0];
            order = randperm(3);
            addx0 = add(order(1));
            addy0 = add(order(2));
            addz0 = add(order(3));
            
            
        end
        
        if strcmp(type,'sheet') && j >= 4
            ry = floor(sqrt(j));
            rz = floor(j/ry);
        end      
        
        
        for k=2:1:j % j NP in each cluser
            flg2=1;    
            %set a while loop to determine weather the picked NP (the one
            %that the new NP is touching) belongs to the blacklist
            if strcmp(type,'round')
                pick_NP = 1;
                while ismember(pick_NP,blacklist)
                    pick_NP = pick_NP + 1;
                end
                
            elseif strcmp(type,'string')
                pick_NP = k-1;
                while ismember(pick_NP,blacklist)
                    if pick_NP == k-2
                        display('error')
                        pause
                    end
                    if pick_NP == k-1
                        pick_NP = 1;
                    else pick_NP = pick_NP + 1;
                    end
                end
                
            elseif  strcmp(type,'random')
                pick_NP = randi([1,k-1]);% this is randomly picked
                while ismember(pick_NP,blacklist)
                    if pick_NP == k-1
                        pick_NP = 1;
                    else pick_NP = pick_NP + 1;
                    end
                end
                
            elseif strcmp(type,'line')
                pick_NP = k-1;
                
                while ismember(pick_NP,blacklist)
                    if pick_NP == k-2
                        display('error')
                        pause
                    end
                    if pick_NP == k-1
                        pick_NP = 1;
                    else pick_NP = pick_NP + 1;
                    end
                end
                
                trial_coord = center(pick_NP,:) + [addy0, addx0, addz0];        
                trial_coord = PBC_dist(trial_coord,[ly,lx,lz],dist); % PBC: periodic condition                
                NP_center(i,k) = sub2ind([ly,lx,lz],trial_coord(1),trial_coord(2),trial_coord(3));
                center(k,:) = trial_coord;
                flg2 = 0;
                
            elseif strcmp(type,'sheet')
                flg2 = 0;
                if j < 4             
                    trial_coord = center(1,:) + [k-1,0,0]*d;
                    trial_coord = PBC_dist(trial_coord,[ly,lx,lz],dist);
                    NP_center(i,k) = sub2ind([ly,lx,lz],trial_coord(1),trial_coord(2),trial_coord(3));
                    center(k,:) = trial_coord;
                end
                
                if j>=4
                    if k <= ry*rz
                        [addy,addz] = ind2sub([ry,rz],k);
                        addy=addy-1;
                        addz=addz-1;
                        trial_coord = center(1,:) + [addy,0,addz]*d;
                        trial_coord = PBC_dist(trial_coord,[ly,lx,lz],dist);
                        NP_center(i,k) = sub2ind([ly,lx,lz],trial_coord(1),trial_coord(2),trial_coord(3));
                        center(k,:) = trial_coord;
                    else
                        trial_coord = center(1,:) + [ry,0,k-ry*rz]*d;
                        trial_coord = PBC_dist(trial_coord,[ly,lx,lz],dist);
                        NP_center(i,k) = sub2ind([ly,lx,lz],trial_coord(1),trial_coord(2),trial_coord(3));
                        center(k,:) = trial_coord;                    
                    end
                end
            end
            
            
            % set a while loop to determine if the generated NP coordinates
            % satisfy certain conditions

            trial_count = 0;
            while flg2 == 1
                % find suitable addx, addy, addz and make sure
                % addx^2+addy^2+addz^2 < d^2, round to nearest integer
                addx = randi([-d,d]);
                abs_addy = floor(sqrt(d^2-addx^2));
                addy = randi([-abs_addy,abs_addy]);
                abs_addz = floor(sqrt(d^2-addx^2-addy^2));
                addz = randi([-abs_addz,abs_addz]);
                
                add   = [addx,addy,addz];
                order = randperm(3);
                addx = add(order(1));
                addy = add(order(2));
                addz = add(order(3));
                
                trial_coord = center(pick_NP,:) + [addy, addx, addz];
                
                % check compatibility
                conflict = 0;
                for ii = 1:1:k-1
                    if pdist([trial_coord;center(ii,:)]) < min_d %||any(trial_coord<1) || trial_coord(1) > ly || trial_coord(2) > lx ||trial_coord(3) > lz %the distance to any existing NP center cannot be less than d-1
                        conflict = 1;
                    end
                end
                
                % if no confict found, assigne the new coordiantes to
                % center
                if conflict == 0;
                    flg2 = 0;
                    trial_coord = PBC_dist(trial_coord,[ly,lx,lz],dist);
                    
%                     if trial_coord(1)<4;
%                         disp('lala');
%                     end
                    
                    NP_center(i,k) = sub2ind([ly,lx,lz],trial_coord(1),trial_coord(2),trial_coord(3));
                    center(k,:) = trial_coord;
                end
                
                % set up a maximum trial number, when reached, switch
                % pick_NP
                trial_count = trial_count + 1;
                
                if trial_count > 2*4*3.14*d^2 && k > 2
                    trial_count = 0;
                    blacklist(pick_NP,1) = pick_NP;
                    if pick_NP == k-1;
                        pick_NP = 1;
                    else pick_NP = pick_NP + 1;
                    end
                end
            end
        end
    end
end

%% post processing
assignin('base','np_center1',NP_center);
NP_center = NP_center(:);
NP_center=NP_center(NP_center~=0);
[y,x,z] = ind2sub([ly,lx,lz],NP_center);
NP_center_sub = [y,x,z];

if plot == 1
%     [linear_coord,~] = process_griddata(NP_center_sub,0,NP_radius,ly,lx,lz); % put the entire NP coord in
%     [x,y,z] = ind2sub([ly,lx,lz],linear_coord);
%     NP_center_sub1 = [x,y,z];
    %figure;
    %assignin('base','num_cluster',num_cluster);
    %plot([1:1:size(num_cluster,2)],num_cluster);
    
    figure;
    scatter3(x,y,z,5,'filled');
    
    I=find(NP_center_sub(:,2)<80);
    sect=NP_center_sub(I,:);
    figure;
    scatter(sect(:,1),sect(:,3),50,'filled');
end
   
toc       
end


