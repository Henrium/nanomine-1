%% The explanation of the function

% Note: this is different from generate_np_dist, which ensures each NP
% there is certain degree of overlapping

% This function is used to generate a distribution of NP with interface, the output is the
% core coordinates (sub) of NP. The algorithm is as follows
% 
% 1) divide total NP into several clusters, the number of NP per cluster is
% determined by a normal distribution with mu = mean_num_NP and sigma =
% dev;

% 2)Generate the core coordinates of each cluster center, a non-penetrating
% radius can be set to avoid overlap of clusters

% 3)Generate the coordiantes of each NP (center) within each cluster, the
% NP coordinates is generated successively. The newly added NP has to be
% touching one of the existing NP, but the overlapping is limited by setting a
% non-peneration radius min_r. The random sampling space increase with r^2.


% This code end is used to contruct structure only in comsol, not integrated with MC, and
% thus does not require the coordinates to be integers.


% NP_sub_center is a 3 by n matrix with coordinates in periodic condition, NP_cell is a cell structure, with each cell record the coordinates 
% of a cluster


function [NP_sub_center,NP_cell] = MC_generate_np_dist_nooverlap(VF,NP_radius,mean_num_NP,dev,dimensionX,dimensionY,dimensionZ,type)
tic


%% variables

% The input variable

% VF            volume fraction
% mean_num_NP   average number of NP per cluster
% tot_r         NP_radius + interface thickness        
% dev           deviation(sigma) of the normal distribution of how many particles per
% lx,ly,lz      simulation box, integer
% NP_radius (nm)

% The output variable
% NP_center_sub: the sub index

%% Initializing parameters

ly = dimensionX; % dimension(1) of a matrix, rows
lx = dimensionY; % dimension 2 of a mtrix, colums
lz = dimensionZ;



NP_vol          = 4/3*3.14*NP_radius^3;
d               = 2*NP_radius;                                      % distance between two NP core
N               = lx*ly*lz*VF/NP_vol;                           % total number of NP
disp(num2str(N));
min_d           = d;                                            % non-penerating radius (include the interface)
max_num_NP      = round(mean_num_NP + 4*dev);                   % maximum NP per cluster, ignore the portion away from 4 sigma
num_cluster     = zeros(max_num_NP,1);

% coefficient for different cut-off distance         
if strcmp(type,'string') || strcmp(type,'line') ||strcmp(type,'sheet') 
    coeff = 0;
else
    coeff = 1;
end


if strcmp(type,'round')
    coeff2 = 0.1;
else
    coeff2 = 1;
end


%% find the true average number of NP per cluster (used to estimiate how many clusters in total), accounting for the loss
% at normdist <0,
if dev > 0;
    ratio = 1-normcdf(0,mean_num_NP,dev);                           % account for the loss at cutoff zero compared to a true gaussian distribution
    true_mean=0;                                                    % record the average number of NP per cluster
    for i=1:1:max_num_NP                                            % a weighted average
        true_mean = i*normpdf(i,mean_num_NP,dev)/ratio + true_mean;
    end    

    % calculated the number of the cluster that contain i NPs
    for i=1:1:max_num_NP
        num_cluster(i) = round(N/true_mean*normpdf(i,mean_num_NP,dev)/ratio);  % as this is rounded, may yield some deviation from true vol% at low mean_NP
    end
else
                                                      % account for the case of delta distribution of cluster size
     num_cluster(mean_num_NP) = round(N/mean_num_NP);

end

tot_cluster = sum(num_cluster);


% if the num_cluster(i) is too small
if tot_cluster == 0 && N/mean_num_NP > 0.8
    for i=1:1:round(N/mean_num_NP)
        num_cluster(mean_num_NP+i-1) = 1;
    end
    tot_cluster = sum(num_cluster);
end

tot_N = dot(num_cluster,1:1:max_num_NP);
disp(['the total number of NP is ',num2str(tot_N)]);


NP_cell = cell(tot_cluster,max_num_NP); % assign the size the NP_center (redundant, will be some zeros if the num_NP<max_num_NP)
disp(['the total number of clusters is ',num2str(tot_cluster)])



%% find the nonpenerating radius of each cluster
% set to be the length of a straight line contain j NP
cluster_radius = zeros(tot_cluster,1);

for j=1:max_num_NP
    if j == 1
        for i = 1:num_cluster(1)
            cluster_radius(i) = d/2; 
        end
    else  
        for i = sum(num_cluster(1:j-1))+1:sum(num_cluster(1:j))
            cluster_radius(i) = (j*NP_vol/0.7/3.14/4*3)^(1/3);
        end
    end
end


%% find the center coordinates of one cluster
disp('now generating the center of each cluster')
cluster_center = zeros(tot_cluster,3);

for j=1:tot_cluster
    while 1
        cluster_center(j,:) = [randi([1,ly]),randi([1,lx]),randi([1,lz])];
        cluster_center(j,:) = PBC(cluster_center(j,:),[ly,lx,lz]);
        
        % Then a while loop is used to avoid overlapping of each cluster
        i = 1; % looping variable
        flg = 0; %boole varible in inner while loop
        
        while j > 1 && i < j && coeff > 0;
            if pdist([cluster_center(j,:);cluster_center(i,:)]) < max(min_d,coeff*(cluster_radius(i) + cluster_radius(j))) % this confinement does not impact significantly to overlap
                flg = 1; %conflict detected the loop is terminated
                break;
            end
            i=i+1;
        end
        
        if flg == 0  % stop loop
            NP_cell{j,1} =  cluster_center(j,:);
            break;
        end
    end
end

nonzero_index = find(~cellfun(@isempty,NP_cell));
NP_sub_center = zeros(length(nonzero_index),3);
for ij=1:1:length(nonzero_index) % loop round each nonzero domain
    kk = nonzero_index(ij); %original index of non_zero element in domain_index
    NP_sub_center(ij,:) = NP_cell{kk};
end

toc

%% find the NP_coordinates within each cluster

for j = 2:max_num_NP % every type of cluster (j NP in each cluster)
    for i=sum(num_cluster(1:j-1))+1:sum(num_cluster(1:j)) % every cluster within each type, total number num_cluster(j),ith cluster
        disp(['now assembling No.',num2str(i),' cluster'])
        
        center = zeros(j,3);                                % assigne the matrix to record the sub coordinates of each NP within this type of cluster
        center(1,:) = cluster_center(i,:);
        
        blacklist = zeros(j,1);                             % set up a blacklist in case the neigbors around a NP is all occupied
        
        % special cases for line and sheet like structures
        if strcmp(type,'line'),add = d*random_unit_vector'; end
            
        
        if strcmp(type,'sheet') && j >= 4
            ry = floor(sqrt(j));
            rz = floor(j/ry);
        end
        
        % find the coordinates of each NP
        for k=2:j % j NP in each cluste
            NotFind = true;
            %set a while loop to determine whether the picked NP (the one
            %that the new NP is touching) belongs to the blacklist
            
            switch type
                case 'round'
                    pick_NP = 1;
                    while ismember(pick_NP,blacklist),pick_NP = pick_NP + 1;end
                    if pick_NP == k, pick_NP = 1; end

                    
                case 'string'
                    pick_NP = k-1;
                    while ismember(pick_NP,blacklist)
                        if pick_NP == k-2, display('error'), pause,end
                        if pick_NP == k-1,pick_NP = 1; 
                        else pick_NP = pick_NP + 1;end
                    end
                    
                case 'random'
                    pick_NP = randi([1,k-1]);% this is randomly picked
                    while ismember(pick_NP,blacklist)
                        if pick_NP == k-1,pick_NP = 1;else pick_NP = pick_NP + 1;end
                    end
                    
                case 'line'
                    pick_NP = k-1;

                    while ismember(pick_NP,blacklist)
                        if pick_NP == k-2
                            disp('error')
                            pause
                        end
                        if pick_NP == k-1
                            pick_NP = 1;
                        else pick_NP = pick_NP + 1;
                        end
                    end
                    
                    trial_coord = center(pick_NP,:) + add;
                    trial_coord = PBC(trial_coord,[ly,lx,lz]); % PBC: periodic condition
                    NP_cell{i,k} = trial_coord;
                    NP_sub_center = [NP_sub_center;trial_coord];
                    center(k,:) = trial_coord;
                    NotFind = false;
                    
                    % will not enter the following loop
                    
                case 'sheet'
                    NotFind = false;
                    if j < 4
                        trial_coord = center(1,:) + [0,k-1,0]*d;
                        trial_coord = PBC(trial_coord,[ly,lx,lz]);
                        NP_cell{i,k} = trial_coord;
                        center(k,:) = trial_coord;
                    end
                    
                    if j>=4
                        if k <= ry*rz
                            [addy,addz] = ind2sub([ry,rz],k);addy=addy-1;addz=addz-1;                            
                            trial_coord = center(1,:) + [0,addy,addz]*d;
                        else
                            trial_coord = center(1,:) + [0,ry,k-ry*rz]*d;
                        end
                        
                        
                        trial_coord = PBC(trial_coord,[ly,lx,lz]);
                        NP_sub_center = [NP_sub_center;trial_coord];
                        NP_cell{i,k} = trial_coord; 
                        center(k,:) = trial_coord;
                    end
            end
            
            
            % set a while loop to determine if the generated NP coordinates
            % satisfy certain conditions

            trial_count = 0;
            tot_trial_count = 0;
            
            while NotFind

                % not very efficient when mean_num_NP is large, consider
                % change
                add = d*random_unit_vector';
                
%                 if isequal(center(pick_NP,:),[0,0,0])
%                     disp('error')
%                     
%                 end
                
                trial_coord = center(pick_NP,:) + add;

                trial_coord = PBC(trial_coord,[ly,lx,lz]);

                isConflict = false;
                for ii = 1:size(NP_sub_center,1)
                        if pdist([trial_coord;NP_sub_center(ii,:)]) < min_d %the distance to any existing NP coordiantes cannot be less than d-1
                            isConflict = true;
                        end
                end
                
                % set up a maximum trial number, when reached, switch
                % pick_NP, a tot_trial_count is also used to avoid endless
                % looping
                
                
                trial_count = trial_count + 1;
                tot_trial_count = tot_trial_count + 1;
                
                
                if trial_count > 2*4*3.14*d^2/100*coeff2 && k > 2  
                    blacklist(pick_NP,1) = pick_NP;
                    trial_count = 0;
                    if pick_NP <= k-2;
                        pick_NP = pick_NP + 1;
                    else pick_NP = 1;
                    end
                end
                
                
                if tot_trial_count > 2*4*3.14*d^2/100*(k-1)
                    isConflict = false;
                end

                % if no confict found, assigne the new coordiantes to
                % center
                
                if ~isConflict
                    NotFind = false;
                    NP_cell{i,k} = trial_coord; 
                    NP_sub_center = [NP_sub_center; trial_coord];
                    center(k,:) = trial_coord;
                end
            end
        end
    end
end


% % correct any NP_cluster coordinate not in periodic boundary condition
% box = [lx,ly,lz];
% for iR = 1:size(NP_cell,1)
%     for iC = 1:size(NP_cell,2)
%         center = NP_cell{iR,1};
%         
%         if ~isempty(NP_cell{iR,iC})
%             coord = NP_cell{iR,iC};
%             for k = 1:size(coord,2)
%                 if coord(k) - center(k) > 2/3*box(k)
%                     coord(k) = coord(k) - box(k);
%                 elseif center(k) - coord(k) > 2/3*box(k)
%                     coord(k) = coord(k) + box(k);
%                 end
%                 NP_cell{iR,iC} = coord;
%             end
%         end
%     end
% end
toc       
end


