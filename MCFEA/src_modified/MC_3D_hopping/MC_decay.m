function [t,totchange_x]=MC_decay(E,final_coord,final_coord_reduced,potential,energy,cutoff_t,FEA,plot_on)
% no double occuplation; x direction periodic condition, delta_V needs to
% be changed accordingly, TBD

% potential = 0;
% coord = 0; energy = 0; cutoff_t = 10; FEA = 0;
%================================================
%global lx ly lz F cutoff_n rec_t tot_e
lx =1000;
ly = 100;
lz = 100;
F = -1e7;
cutoff_n = 5e5;
rec_t = [0.01,0.03,0.1,0.3,1,2,3,4,5];
tot_e = 16;

%===========================================

%rec_t = [0.01,0.03,0.1,0.3,1,2,3,4,5]; % record time

tic

%field direction is along x direction
%===============simulation cell size======================

cut_d = 10;
threshold_t = cutoff_t/100; %seconds

blacklist = zeros(tot_e*fix(cutoff_t/threshold_t),5);
list_index = 1;
totchange_x = zeros(tot_e,10);

% %initialize the field and potential matrix when NP is not present
% field=repmat(1e7,[ly,lx,lz]);
% potential = 0.01*lx:-0.01:0.01;
% potential = repmat(potential,[ly,1,lz]);

%===============physical constants==========================


k=1.38e-23; % boltzmann constant
T=300; % romm temperature
e=1.6e-19; %unit charge
gamma=(1/0.5e-9);% decay length of 0.5 nm
unit_length=1e-9; %nm


%====================construct energy states distribution======== 
%E = generate_1_gaussian_2_linear(2600,-1,-1-0.035,-1-0.115,0.6,lx,ly,lz);

%R=rand(ly,lx,lz); %generate a uniform distribution from 0 to 1.
%E=k*T0*log(R)/1.6e-19;% generate a exponential distribution of energy in the unite of eV, each site lattice is 1 nm

%E = generate_1_expdist_2_lineartail(840,-1.5,-1.5-0.035,-1.5-0.115,0.6,lx,ly,lz);
%E = generate_1_gaussian(2600,lx,ly,lz);

%% ====================initialize variables======================


t=zeros(tot_e,1); %dwell time of electron
position_x=zeros(tot_e,1);
position_y=zeros(tot_e,1);
position_z=zeros(tot_e,1);
real_p_x=zeros(tot_e,cutoff_n);
real_p_y=zeros(tot_e,cutoff_n);
real_p_z=zeros(tot_e,cutoff_n);
Ecount=zeros(tot_e,cutoff_n);
ref_index=1; %variable for update_F
Delta_F_tot=0;%variable for update_F
p=potential; % dynamic potential map
m=11;       %loop number of neighbors, m by m by m matrix
a=(m+1)/2;  %median number

for i=1:1:tot_e %define the initial position (x,y) of all electrons, 50 nm distance in y axis
    
    position_x(i)=final_coord_reduced(i,1);
    real_p_x(i,1)=final_coord(i,1);
  
    
        
    position_y(i)=final_coord_reduced(i,2);
    real_p_y(i,1)=final_coord(i,2);
    
    position_z(i)=final_coord_reduced(i,3);
    real_p_z(i,1)=final_coord(i,3);    
    
    % make the initial E to zero
    E(final_coord_reduced(i,2),final_coord_reduced(i,1),final_coord_reduced(i,3)) = 0;
    
end


%% ======================start MC loop===============================

n=1;
record = zeros(tot_e,1);
while min(t) < cutoff_t && n < cutoff_n && max(real_p_x(:,n)) > 2  %loop only operature while the dwell time is smaller than cutoff_t and cutoff_n

    
    for i=1:1:tot_e % electrons total
        change_x=0; change_y=0;change_z=0;delta_t = 0;
        if t(i)<cutoff_t || position_x(i) > 1
            hop_rate = zeros(m,m,m);
            for addx=1:1:m  %define the 5 nearest neighbor in the x direction
                neighbor_x = position_x(i) + addx - a;% x coordinates of the neigbor site of ith electron
                for addy=1:1:m
                    neighbor_y=position_y(i)+addy-a; %y coordinates of the neigbor site of ith electron
                    for addz=1:1:m
                        neighbor_z=position_z(i)+addz-a;
                        
                        r = unit_length*sqrt((addx-a)^2+(addy-a)^2+(addz-a)^2);% calculate the hopping distance d
                        
                        % the real neighbor position
                        
                        real_nei_x = real_p_x(i,n)+addx-a;
                        real_nei_y = real_p_y(i,n)+addy-a;
                        real_nei_z = real_p_z(i,n)+addz-a;
                               
                            
                        if real_nei_x < 1   %||neighbor_x>lx %cannot leave sample, cannot jump back, once in the NP, can only hop foward
                            hop_rate(addy,addx,addz) = 0;                                                                            
                            
                        elseif (n > 1 && real_nei_x == real_p_x(i,n-1) && real_nei_y == real_p_y(i,n-1) && real_nei_z == real_p_z(i,n-1))||(n > 2 && real_nei_x == real_p_x(i,n-2) && real_nei_y == real_p_y(i,n-2) && real_nei_z == real_p_z(i,n-2))||(n > 3 && real_nei_x == real_p_x(i,n-3) && real_nei_y == real_p_y(i,n-3) && real_nei_z == real_p_z(i,n-3))%cannot jump back, once in the NP, can only hop foward
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
                            
                            if (E(position_y(i),position_x(i),position_z(i)) == energy && E(neighbor_y,neighbor_x,neighbor_z) == energy && neighbor_x <= position_x(i)) %cannot jump back, once in the NP, can only hop foward
                                hop_rate(addy,addx,addz)=0;
                            else
                                if FEA==1 %boole variable to include or not include the local field distortion
                                    neighbor_x_n = fix(real_nei_x/lx); real_p_x_n = fix(real_p_x(i,n)/lx);% to consider the potential drop at
                                    delta_V=(p(neighbor_y, neighbor_x, neighbor_z)-neighbor_x_n*lx*F/1e9)-(p(position_y(i),position_x(i),position_z(i))-real_p_x_n*lx*F/1e9);%delta_V < 0 for jump forward
                                else
                                    delta_V=(real_nei_x - real_p_x(i,n))*-F/1e9;
                                end
                                
                                
                                delta_E = E(neighbor_y,neighbor_x,neighbor_z)-E(position_y(i), position_x(i), position_z(i)) + delta_V;% in the unite of eV
                                
                                
                                if delta_E>0
                                    hop_rate(addy,addx,addz)=1e12*exp(-2*gamma*r)*exp(-delta_E*e/k/T);% hop_rate is a m by m matrix.
                                else
                                    hop_rate(addy,addx,addz)=1e12*exp(-2*gamma*r);
                                end
                                
%                                 if real_p_x(i,n)==lx && real_nei_x>lx&&r<5e-9;
%                                     [real_p_x(i,n),log(hop_rate(addy,addx,addz)),r*1e9,delta_E,delta_V]
%                                     
%                                 end
%                                 
                                
                                
                            end
                         
                        end
                        
                    end
                end
            end
        
           execute = 1; repeat = 1; %boole variable
           
           while execute     
               double_occupation = 0;%reinitialize boole variable
               hop_rate(a,a,a)=0;%set hopping to itself probability to 0
               tot_hop_rate=sum(hop_rate(:));
               
               
               hop_prob=hop_rate/tot_hop_rate;% giving the normalized hoping probability to each neighboring site.
               
               INDEX_prob = find(hop_prob > 1e-5); %only record small elments, use sparse matrix
               
               sparse_hop_prob = hop_prob(INDEX_prob);
               
               SS=size(sparse_hop_prob,1);
               
               col_dis=zeros(SS,1);% define the size of col_dis
               
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
               
               position_x(i) = position_x(i) + change_x;% the new position of ith electron
               position_y(i) = position_y(i) + change_y;
               position_z(i) = position_z(i) + change_z;
               
%================compare with the blacklist to reject jump that will causes double occupation==================           
               ii = 1;
             
               while repeat==1 && blacklist(ii,1)~=0 && ii < size(blacklist,1)+1;
                   if  t(i) > blacklist(ii,4) && t(i) < blacklist(ii,5) && pdist([blacklist(ii,1:3);[real_p_x(i,n) + change_x, position_y(i), position_z(i)]]) < 5
                       destination = [real_p_x(i,n) + change_x, position_y(i), position_z(i)];
                       original_p = destination - [change_x,change_y,change_z];
                       
                       double_occupation = 1;
                       disp('double occupation detected')
                       disp(original_p);
                      
                       repeat = 0;%stop repeat this while loop, then double_occupation in the next higher level while loop will remain as 0, then excute = 0;
                       
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
               
          
               
               if double_occupation == 0; %if not found double occupation, stop execute while loop
                   execute = 0;
               end         
           end
%================loop END=========================================          
           

           
          delta_t = exprnd(1)/tot_hop_rate;
           t(i) = t(i) + delta_t; % increase of time
           
           if position_x(i) <= 0                    % periodic condition in x
               position_x(i) = lx + position_x(i);
           elseif position_x(i) > lx
               position_x(i) = position_x(i) - lx;
           end
           
           if position_y(i)<=0                    % periodic condition in y
               position_y(i)=ly + position_y(i);
           elseif position_y(i) > ly
               position_y(i) = position_y(i) - ly;
           end
           
           if position_z(i) <= 0                    %periodic condition in z
               position_z(i) = lz + position_z(i);
           elseif position_z(i) > lz
               position_z(i) = position_z(i)-lz;
           end
           Ecount(i,n)=E(position_y(i),position_x(i),position_z(i));% record the change of energy levels
        end
        

        
        
        real_p_x(i,n+1) = real_p_x(i,n) + change_x; %record the real position of electron
        real_p_y(i,n+1) = real_p_y(i,n) + change_y;
        real_p_z(i,n+1) = real_p_z(i,n) + change_z;
        
        if  real_p_x(i,n+1) < 2 % regard it is now extracted
            t(i) = rec_t(end);
        end
        

                
        if delta_t > threshold_t
            blacklist(list_index,:) = [real_p_x(i,n),position_y(i),position_z(i),t(i)-delta_t,t(i)];%[x,y,z,t_start,t_end]
            list_index = list_index + 1;
        end
        
        
        % record the position of electron at each given time
        
        if record(i) == 0 && t(i) > rec_t(1)
            totchange_x(i,1) = real_p_x(i,n);
            record(i) = 1;
        elseif record(i) == 1 && t(i) > rec_t(2)
            totchange_x(i,2) = real_p_x(i,n);
            record(i) = 2;
        elseif record(i) == 2 && t(i) > rec_t(3);
            totchange_x(i,3) = real_p_x(i,n);
            record(i) = 3;
        elseif record(i) == 3 && t(i) > rec_t(4);
            totchange_x(i,4) = real_p_x(i,n);
            record(i) = 4;
        elseif record(i) == 4 && t(i) > rec_t(5);
            totchange_x(i,5) = real_p_x(i,n);
            record(i) = 5;
        elseif record(i) == 5 && t(i) > rec_t(6);
            totchange_x(i,6) = real_p_x(i,n);
            record(i) = 6;
        elseif record(i) == 6 && t(i) > rec_t(7);
            totchange_x(i,7) = real_p_x(i,n);
            record(i) = 7;
        elseif record(i) == 7 && t(i) > rec_t(8);
            totchange_x(i,8) = real_p_x(i,n);
            record(i) = 8;
        elseif record(i) == 8 && t(i) > rec_t(9);
            totchange_x(i,9) = real_p_x(i,n);
            record(i) = 9;
        end
    
        
    end
    
    %======update the field distribution====================
    
%         distance = pdist([real_p_x(:,n+1),real_p_x(:,ref_index)]','euclidean'); %
%         if distance > cut_d %ecludiean distance between the x coordinates vector
%             
%            [Delta_F,p]=update_F_continj_3D(field,potential,position_x,lx,ly,lz);
%             ref_index=n+1;
%             
%             Delta_F_tot = Delta_F_tot + Delta_F;
%             num_new_e = fix(Delta_F_tot*8.85e-12*3*ly*1e-9*lz*1e-9/1.6e-19); %number of newly inejcted electrons, round towards zero
%             
%             if num_new_e > 0
%                 Delta_F_tot = 0; % reset delta_F
%                 tot_e = tot_e + fix(q);
%                 
%  
%             end   
%                 
%         end
    
    n=n+1;
    
    if n>=10000 && mod(n,10000)==0;
        toc
        aa = mean(real_p_x(:,n));
        bb = min(t);
        TEXT = ['the average traveling distance now is ',num2str(aa),'; the minimum traveling time is ',num2str(bb)];
        disp(TEXT)
    end 
end


%% post data processing and plotting

real_p_x( :, ~any(real_p_x,1) ) = [];  %trim zero columns
real_p_y( :, ~any(real_p_y,1) ) = [];
real_p_z( :, ~any(real_p_z,1) ) = [];

totchange_x(:,10) = real_p_x(:,end);%record the net change of x coordinates


if plot_on == 1;
    color=hsv(tot_e);
    
    figure;
    hold on;
    for i=1:1:tot_e
        plot3(real_p_x(i,:),real_p_y(i,:),real_p_z(i,:),'color',color(i,:));
    end
    
    
    figure;
    hold on;
    for i=1:1:tot_e
        plot(1:cutoff_n,Ecount(i,:),'color',color(i,:));
    end
    
    figure;
    hist(totchange_x(:,10));
    
    figure;
    hist(Ecount(:),20);  
end
E_dis = hist(Ecount(:),20)';
end








