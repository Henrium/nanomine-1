% funciton used to perform Monte Carlo Simulation of charge transport in
% nanocomposites

% Yanhui Huang, May 23, 2016, @RPI


% E_dist: the histgram of energy of all occupied states through entire
% simulation
% ave_E: the average energy of each electron
% totchange_x: the final x position of each electron at each record time,
%               tot_e by rec_t matrix
% final_coord: the final coordinates of all electron, tot_e by 3 matrix
% final_coord_reduced: the reduced coorindates in the reduced simulation box
% trap_record: record the first and 2nd time when electron encounter a NP,
%               tot_2 by 2 matrix;
% trap_time3: record the total residence time in NP

% field direction is along x direction
% no double occuplation; x direction periodic condition, delta_V needs to
% be changed accordingly, TBD


% Note1, when the charge carrier is inside the np, it can only jump foward,
% with the destination x > previous x. This can prevent charges wandering
% around inside NP and not jumping out. Once the charge leave the NP, it
% may jump back or be trapped again in the same cluster (e.g if the cluster
% has multiple branches). This also prevented by setting the jump back rate
% to zero and recording the leaving point of the charge, and not record the
% second detrap time to t

% Note2, subindex is in the form of [y,x,z], i.e. to access lattice point energy, use E(y,x,z)

function [E_dis,t,totchange_x,final_coord,final_coord_reduced,trap_record,ave_E,trap_time3,trapInfoAll]=MC_FEA_3D(E,potential,energy,cutoff_t,FEA,plot_on,clusterCell)


narginchk(6,7);

global lx ly lz F cutoff_n rec_t tot_e np_coord NP_radius cutoff_d


tic
disp('Start the Monte Carlo Hopping...');


%===============simulation cell size======================
trapInfoAll = [];
trap_time3 = [];
trap_record = [];
cluster_radius = 50;
threshold_t = 0.001; % if the residence time exceeds this value, it records the point into the blacklist

blacklist = zeros(tot_e*fix(cutoff_t/threshold_t),5);
list_index = 1;
totchange_x = zeros(tot_e,length(rec_t)+1);

%===============physical constants==========================


k           = 1.38e-23; % boltzmann constant
T           = 300; % romm temperature
e           = 1.6e-19; %unit charge
gamma       = (1/0.5e-9);% decay length of 0.5 nm
unit_length = 1e-9; %nm



%% ====================initialize variables======================
trap_count = 0;
box = [ly,lx,lz];
%dwell time of electron
t               =   zeros(tot_e,1);

%reduced position in a one box
position_x      =   zeros(tot_e,1);
position_y      =   zeros(tot_e,1);
position_z      =   zeros(tot_e,1);

%real position in extended box
real_p_x        =   zeros(tot_e,cutoff_n);
real_p_y        =   zeros(tot_e,cutoff_n);
real_p_z        =   zeros(tot_e,cutoff_n);

%record the energy of each jump
Ecount          =   zeros(tot_e,cutoff_n);

%record the time of each jump
tcount          =   zeros(tot_e,cutoff_n);

%record the stopwatch sequence, rec_t
record          =   zeros(tot_e,1);

trap_time3      = 0;

trap_record     = zeros(tot_e,2);
ave_E           = zeros(tot_e,length(rec_t));
p               = potential;    % dynamic potential map
m               = 11;           % loop number of neighbors, m by m by m matrix
a               = (m+1)/2;      % median number



%define the initial position (x,y) of all electrons
for ie=1:tot_e
    position_x(ie) = 1;
    real_p_x(ie,1) = 1;% x coordinate is 1
    
    % initial position is randomlized
    
    position_y(ie) = randi([1,100]);
    real_p_y(ie,1) = position_y(ie);
    
    position_z(ie) = randi([1,100]);
    real_p_z(ie,1) = position_z(ie);
end

leave_point =  zeros(tot_e,3);
cluster_record = zeros(tot_e,1);

%% ======================start MC loop===============================

% looping variable
n=1;

while min(t) < cutoff_t && n < cutoff_n   %loop only operature while the dwell time is smaller than cutoff_t and cutoff_n
    
    
    for ie = 1:tot_e % electrons total
        
        change_x=0; change_y=0; change_z=0;
        
        if t(ie) < cutoff_t
            hop_rate = zeros(m,m,m);
            
            coord = sub2ind([ly,lx,lz],position_y(ie),position_x(ie),position_z(ie));
            sub_coord0 = [position_y(ie),position_x(ie),position_z(ie)];
            coord0 = coord;
            
            for addx = 1 : m  %define the 5 nearest neighbor in the x direction
                neighbor_x = position_x(ie) + addx - a;% x coordinates of the neigbor site of ith electron
                for addy = 1 : m
                    neighbor_y = position_y(ie) + addy - a; %y coordinates of the neigbor site of ith electron
                    for addz = 1 : m
                        neighbor_z = position_z(ie) + addz - a;
                        
                        
                        r = unit_length*sqrt((addx-a)^2+(addy-a)^2+(addz-a)^2);% calculate the hopping distance d
                        
                        
                        % the real neighbor position
                        
                        real_nei_x = real_p_x(ie,n) + addx - a;
                        real_nei_y = real_p_y(ie,n) + addy - a;
                        real_nei_z = real_p_z(ie,n) + addz - a;
                        
                        
                        if real_nei_x < 1    %cannot leave sample, cannot jump back, once in the NP, can only hop foward
                            hop_rate(addy,addx,addz) = 0;
                            
                        elseif (n > 1 && real_nei_x == real_p_x(ie,n-1) ...
                                && real_nei_y == real_p_y(ie,n-1) ...
                                && real_nei_z == real_p_z(ie,n-1)) ...
                                ||(n > 2 && real_nei_x == real_p_x(ie,n-2) ...
                                && real_nei_y == real_p_y(ie,n-2) ...
                                && real_nei_z == real_p_z(ie,n-2)) ...
                                ||(n > 3 && real_nei_x == real_p_x(ie,n-3) ...
                                && real_nei_y == real_p_y(ie,n-3) ...
                                && real_nei_z == real_p_z(ie,n-3))%cannot jump back, once in the NP, can only hop foward
                            
                            hop_rate(addy,addx,addz) = 0;
                            
                            
                        else
                            %periodic condtion in y and z direction
                            
                            if neighbor_x <= 0
                                neighbor_x = lx + neighbor_x;
                            elseif neighbor_x > lx
                                neighbor_x = neighbor_x - lx;
                            end
                            
                            if neighbor_y <= 0
                                neighbor_y = ly + neighbor_y;
                            elseif neighbor_y > ly
                                neighbor_y = neighbor_y - ly;
                            end
                            
                            if neighbor_z<=0
                                neighbor_z = lz + neighbor_z;
                            elseif neighbor_z > lz
                                neighbor_z = neighbor_z - lz;
                            end
                            
                            % cannot jump back, once in the NP, can only hop foward
                            if E(position_y(ie),position_x(ie),position_z(ie)) == energy ...
                                    && E(neighbor_y,neighbor_x,neighbor_z) == energy ...
                                    && real_nei_x <= real_p_x(ie,n) 
                                hop_rate(addy,addx,addz)=0;
                            % once left, cannot jump back to the same cluser immediately
                            elseif leave_point(ie,2) ... 
                                    && real_nei_x - leave_point(ie,2) <= 0 ...
                                    && pdist([real_nei_y,real_nei_x,real_nei_z;leave_point(ie,:)]) <= 10*NP_radius 
                                hop_rate(addy,addx,addz)=0;
                            else
                                if FEA %boole variable to include or not include the local field distortion
                                    neighbor_x_n = fix(real_nei_x/lx);
                                    real_p_x_n = fix(real_p_x(ie,n)/lx);% to consider the potential drop at
                                    delta_V=(p(neighbor_y, neighbor_x, neighbor_z)-neighbor_x_n*lx*F/1e9)...
                                        -(p(position_y(ie),position_x(ie),position_z(ie))-real_p_x_n*lx*F/1e9);%delta_V < 0 for jump forward
                                    if delta_V > 1
                                        delta_V = delta_V-(lx-1)*F/1e9;
                                    end
                                else
                                    delta_V = (real_nei_x - real_p_x(ie,n))*-F/1e9;
                                end
                                
                                
                                delta_E = E(neighbor_y,neighbor_x,neighbor_z)...
                                    -E(position_y(ie), position_x(ie), position_z(ie)) + delta_V;% in the unite of eV
                                
                                
                                if delta_E>0
                                    hop_rate(addy,addx,addz) = 1e12*exp(-2*gamma*r)*exp(-delta_E*e/k/T);% hop_rate is a m by m matrix.
                                else
                                    hop_rate(addy,addx,addz) = 1e12*exp(-2*gamma*r);
                                end
                                
                            end
                            
                        end
                        
                    end
                    
                end
            end
            
            execute = true; repeat = true; %boole variable
            
            while execute
                double_occupation = false;%reinitialize boole variable
                hop_rate(a,a,a)   = 0;%set hopping to itself probability to 0
                tot_hop_rate      = sum(hop_rate(:));
                hop_prob          = hop_rate/tot_hop_rate;% giving the normalized hoping probability to each neighboring site.
                INDEX_prob        = find(hop_prob > 1e-5); %only record small elments, use sparse matrix
                
                sparse_hop_prob   = hop_prob(INDEX_prob);
                
                if isempty(sparse_hop_prob)
                    sparse_hop_prob = hop_prob;
                    INDEX_prob      = 1:length(hop_prob);
                end
                
                
                SS = size(sparse_hop_prob,1);
                
                col_dis = zeros(SS,1);% define the size of col_dis
                
                col_dis(1) = sparse_hop_prob(1);
                
                for j=2:1:SS           %define col_dis as accumulated probabilty
                    col_dis(j)=col_dis(j-1)+sparse_hop_prob(j);
                end
                
                index_col=sum(col_dis < rand)+1; %find the index in the the single array col
                
                if index_col > size(INDEX_prob,1)
                    index_col = size(INDEX_prob,1);
                end
                
                
                INDEX_dest = INDEX_prob(index_col);
                
                [change_y,change_x,change_z]=ind2sub([m,m,m],INDEX_dest);
                
                change_x = change_x - a;
                change_y = change_y - a;
                change_z = change_z - a;
                
                position_x(ie) = sub_coord0(2) + change_x;% the new position of ith electron
                position_y(ie) = sub_coord0(1) + change_y;
                position_z(ie) = sub_coord0(3) + change_z;
                
                
                %================compare with the blacklist to reject jump that will causes double occupation==================
                ii = 1;
                
                while repeat && ii < size(blacklist,1)+1 && blacklist(ii,1)~=0
                    if  t(ie) > blacklist(ii,4) && t(ie) < blacklist(ii,5) && pdist([blacklist(ii,1:3);[real_p_x(ie,n) + change_x, position_y(ie), position_z(ie)]]) < 5
                        destination = [real_p_x(ie,n) + change_x, position_y(ie), position_z(ie)];
                        original_p = destination - [change_x,change_y,change_z];
                        
                        double_occupation = true;
                        %                         disp('double occupation detected')
                        
                        repeat = false;
                        %stop repeat this while loop, then double_occupation in the next higher level while loop will remain as 0, then excute = 0;
                        
                        %=============update hopping rate=========================
                        for kk=1:1:m^3
                            change = ind2sub([m,m,m],kk);%change = [addy,addx,addz]
                            nei_p = original_p - (change - [a,a,a]); % neighbor position
                            dist_nei_b = pdist([blacklist(ii,1:3);nei_p]);
                            if dist_nei_b < 10 %cutoff distance 10 nm
                                dE = 1.6e-19/4/3.14/8.85e-12/3/dist_nei_b/1e-9;
                                hop_rate(change) = hop_rate(change)*exp(-dE*1.6e-19/1.38e-23/300);
                            end
                        end
                        %========================================================
                    else
                        ii = ii + 1;
                    end
                end
                %if not found double occupation, stop execute while loop
                if ~double_occupation,execute = false;end
            end
            
            %================loop END=========================================
            delta_t = exprnd(1)/tot_hop_rate;
            t(ie) = t(ie) + delta_t; % increase of time
            
            if position_x(ie) <= 0                    % periodic condition in x
                position_x(ie) = lx + position_x(ie);
            elseif position_x(ie) > lx
                position_x(ie) = position_x(ie) - lx;
            end
            
            if position_y(ie)<=0                    % periodic condition in y
                position_y(ie)=ly + position_y(ie);
            elseif position_y(ie) > ly
                position_y(ie) = position_y(ie) - ly;
            end
            
            if position_z(ie) <= 0                    %periodic condition in z
                position_z(ie) = lz + position_z(ie);
            elseif position_z(ie) > lz
                position_z(ie) = position_z(ie)-lz;
            end
            
            
            
            
            Ecount(ie,n) = E(position_y(ie),position_x(ie),position_z(ie));% record the change of energy levels, destination energy
            tcount(ie,n) = delta_t; % record the time duration
            
            
            % this is to record the trapping time on NP
            if nargin == 7 && ismember(coord,np_coord) 
                was_in_NP = true;
                if n>1 && Ecount(ie,n-1) == energy && Ecount(ie,n) > -0.6 % has to jump to Et
                    trap_time3(end+1) = delta_t;
                end
            else
                was_in_NP = false;
            end
            
            coord = sub2ind([ly,lx,lz],position_y(ie),position_x(ie),position_z(ie));
            
            
            
            if E(coord) ~= energy,out_of_NP = true;else out_of_NP = false;end
            
            
            if nargin == 7 && ismember(coord,np_coord) && Ecount(ie,n) == energy
                % this is to record the time when electron first encounter NP
                if trap_record(ie,1) == 0 ; % only record the first time
                    trap_record(ie,1) = t(ie);
                    p_record(ie) = coord;
                end
                
                
                % this is to record the 2nd time when electron encounter NP
                if trap_record(ie,2) == 0 && trap_record(ie,1) ~=0
                    
                    [y1,x1,z1] =  ind2sub([ly,lx,lz],p_record(ie));
                    [y2,x2,z2] =  ind2sub([ly,lx,lz],coord);
                    
                    if pdist([y1,x1,z1;y2,x2,z2]) > cluster_radius && t(ie) - trap_record(ie,1) > 0.01 % avoiding recording when charges traveling within one cluster
                        trap_record(ie,2) = t(ie);
                    end
                end
            end
            
            
            
            real_p_x(ie,n+1) = real_p_x(ie,n) + change_x; %record the real position of electron
            real_p_y(ie,n+1) = real_p_y(ie,n) + change_y;
            real_p_z(ie,n+1) = real_p_z(ie,n) + change_z;
            
            
            if delta_t > threshold_t
                blacklist(list_index,:) = [real_p_x(ie,n),position_y(ie),position_z(ie),t(ie)-delta_t,t(ie)];%[x,y,z,t_start,t_end]
                list_index = list_index + 1;
            end
            
            
            % record the position of electron at each given time
            if record(ie) < length(rec_t)
                irt = record(ie) + 1;
                if t(ie) > rec_t(irt)
                    totchange_x(ie,irt) = real_p_x(ie,n);
                    ave_E(ie,irt) = Ecount(ie,1:n-1)*tcount(ie,2:n)'/sum(tcount(ie,2:n));
                    record(ie) = record(ie) + 1;
                end
            end
            
            % set the condition that charge cannot jump back to NP once left,
            % will be overwrite
            
            if nargin == 7 && was_in_NP && out_of_NP && t(ie)
                
                temp_leave_point = [real_p_y(ie,n),real_p_x(ie,n),real_p_z(ie,n)]; % the last point in NP
                for iCl = 1:length(clusterCell)
                    cluster = clusterCell{iCl};
                    if ismember(temp_leave_point,cluster,'rows')
                        tempClusterRecord = iCl;
                        break
                    else
                        tempClusterRecord = 'A';
                    end
                end
                
                % avoid double couting trapping in the same cluster, not adding
                % delta_t to t
                if tempClusterRecord == cluster_record(ie) && temp_leave_point(2)-leave_point(ie,2) <= 0.7*lx
                    t(ie) = t(ie) - delta_t;
                    leave_point(ie,:) = temp_leave_point;
                    disp('double trap prevented');
                else
                    cluster_record(ie) = iCl;
                    trap_count = trap_count + 1;
                    leave_point(ie,:) = temp_leave_point;
                    trapInfo = [t(ie),delta_t,E(coord)-E(coord0),ie,leave_point(ie,:)];
                    %disp(num2str(TIME));
                    trapInfoAll = [trapInfoAll;trapInfo];
                end
            end
            
            
            
        else % if t > cut_off_t
            
            real_p_x(ie,n+1) = real_p_x(ie,n) + change_x; %record the real position of electron
            real_p_y(ie,n+1) = real_p_y(ie,n) + change_y;
            real_p_z(ie,n+1) = real_p_z(ie,n) + change_z;
            
        end
    end
    
    % looping variables
    n = n + 1;
    
    % showing the process
    if n>=10000 && mod(n,10000)==0;
        toc
        aa = mean(real_p_x(:,n));
        
        if aa > cutoff_d
            break
        end
            
        %disp(num2str(totchange_x));
        bb = min(t);
        fprintf('the average traveling distance now is %.0f',aa)
        text = [sprintf('\nthe minimum traveling time now is %.3g',bb),'\n'];
        disp(sprintf(text));
    end
end


%% post data processing and plotting

real_p_x( :, ~any(real_p_x,1) ) = [];  %trim zero columns
real_p_y( :, ~any(real_p_y,1) ) = [];
real_p_z( :, ~any(real_p_z,1) ) = [];

totchange_x(:,end) = real_p_x(:,end);%record the net change of x coordinates

final_coord_reduced = [position_x,position_y,position_z];
final_coord = [totchange_x(:,end),real_p_y(:,end),real_p_z(:,end)];


if plot_on
    color=hsv(tot_e);
    
    figure;
    hold on;
    for ie=1:1:tot_e
        plot3(real_p_x(ie,:),real_p_y(ie,:),real_p_z(ie,:),'color',color(ie,:));
    end
    
    
    figure;
    hold on;
    for ie=1:1:tot_e
        plot(1:cutoff_n,Ecount(ie,:),'color',color(ie,:));
    end
    
    figure;
    hist(totchange_x(:,end));
    
    
    figure;
    Ecount = Ecount(:);
    Ecount = Ecount(Ecount~=0);
    hist(Ecount,20);
end

Ecount = Ecount(:);
Ecount = Ecount(Ecount~=0);

[E_dis(1,:),E_dis(2,:)] = hist(Ecount,20);

E_dis = E_dis';


disp(['trap_count = ',num2str(trap_count)]);
assignin('base','TOTAL_TIME',trapInfoAll);
end








