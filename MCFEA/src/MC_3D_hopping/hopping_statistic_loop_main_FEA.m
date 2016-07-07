%% This is the main file


%% define input parameters

%function [E,final_coord,final_coord_reduced,tot_x,t,ave_E,trap_record] = hopping_statistic_loop_main_FEA(type,mean_num_NP)

global lx ly lz F cutoff_n rec_t tot_e np_coord NP_radius cutoff_d

%=============== user controlled input ===============================


% nominal electric field, unit V/m
F = 1e7;

% density of states function, select either 'gaussian' or 'exponential' or 'arbitrary'
%   showing the equaiton for gaussian and exponential
%   p(E) = 2/(sigma*sqrt(2pi))*exp(-E^2/sigma^2), gaussian
%   p(E) = sigma*exp(-E/sigma), exponential
%   sigma = k*T0;


DOS = 'gaussian';

switch DOS
    case 'gaussian'
        T0  = 2600;  % unit Kelvin,
    case 'exponential'
        T0  = 2600;
    case 'arbitrary'
        probability = [0,1,2,3,3]; %user define
        E_range     = -1.1;        %unit: eV
end
    

% whether to include NP, neat polymer or composites
include_NP  = false;

if include_NP
    % the NP particle energy, unit eV
    NP_energy   = -1.1;
    
    % size of the cluster, mean value
    mean_num_NP = 30;
    
    % standard deviation o the cluster size
    dev         = 5;
    
    % type of the cluster shape, can be either, 'round', 'random', 'line',
    % or 'sheet'
    type        = 'round'; % type of NP distribution
    
    % NP radius, unit nm
    NP_radius = 2.5;
    
    % volume fraction
    vf        = 4e-3;
    
    % whether to couple finite element to calculate field distribution
    FEA       = false;
    
else
    NP_radius = 2.5; % by default value for neat polymer
end

% data points of transport time in the plot, in log scale
rec_t = 10.^[-5:0.5:3];


% simulation repeat number, increase this number to improve accurarcy
n  = 10;



%==================== system default input=============================
trialNo      = '1';
tot_traptime = 0;

% stop simulation if the total traveling distance exceed cutoff_d
cutoff_d     = 1e4*NP_radius/2.5;



% simulation box, scale with NP_radius
lx = 1000*NP_radius/2.5; %direction of the field (nm)
ly = 100*NP_radius/2.5;
lz = 100*NP_radius/2.5;

cutoff_n = 5e5*NP_radius/2.5; %maxmum simulation step

plot_on = false;     %whether to plot figure

box = [lx,ly,lz];

potential = 0; % by default

%%  Main part


for ii=1:n
    
   % to avoid mesh error
    while include_NP
        try
            disp(type);
            [core_coord,NP_cell] = MC_generate_np_dist_nooverlap(vf,NP_radius,mean_num_NP,dev,lx,ly,lz,type);
            % remove the overlap NP
            core_coord = MC_remove_overlap(core_coord,2*NP_radius);
            [~,I] = sort(core_coord(:,1));
            core_coord = core_coord(I,:);
            
            % post-process the griddata from comsol
            [np_coord,clusterCell] = process_griddata(core_coord,NP_radius,lx,ly,lz,NP_cell);%np_coord is linear index
            
            % core_coord distributed into [lx,ly,lz];
            if FEA
                potential = FEA_potential(vf,NP_radius,core_coord,box);
                potential = F/1e6*potential;
            end
            
            break;
            
        catch ME
            disp(ME);
        end
    end
    
    % generate energy grid
    disp('Now constructing the energy landscape...')
    switch DOS
        case 'gaussian'
            %E = generate_1_gaussian_numfit(2600,-1.0469,-1.0941,0.709,-1.1325,0.237,-1.1996,0.054,lx,ly,lz,plot_on);
            E = generate_1_gaussian(T0,lx,ly,lz);
        case 'exponetial'
            E = generate_1_expdist(T0,lx,ly,lz);
        case 'arbitrary'
            E = generate_arbitrary_E(E_range,probability,lx,ly,lz);
    end
    
    if include_NP, E(np_coord) = NP_energy; end  %define the NP energy
            
    
    
    cutoff_t = rec_t(end);
    tot_e = fix(8.85e-12*F*3*ly*lz*1e-18/1.6e-19); %total numbers of electrons calcualted by the surface density of charges
    
    
    [E_dis,t,totchange_x,final_coord,final_coord_reduced,trap_record,ave_E,trap_time3,TOTAL_TIME] = MC_FEA_3D(E,potential,NP_energy,cutoff_t,FEA,plot_on,clusterCell);% (E,potential,np_coord,energy,cut_off_t,FEA)
    
    E_disCell{ii}       = E_dis;
    totchange_xCell{ii} = totchange_x;
    ave_ECell{ii}       = ave_E;
    tCell{ii}           = t;
    tot_traptime        = [tot_traptime;trap_time3'];
    trap_countCell{ii}  = TOTAL_TIME;
    save(['/Users/yanhui/Google Drive/MC results/FEA_',num2str(vf),'_',num2str(NP_radius),'_',num2str(mean_num_NP),'_',num2str(dev),'_',type,trialNo,'_data.mat'],'rec_t','totchange_xCell','E_disCell','ave_ECell','trap_countCell')
end

%% post processing data


tot_x = cell2mat(totchange_xCell');

tot_traptime = tot_traptime(tot_traptime > 0.001); % remove small time and zero

% assignin('base', 'tot_trap_time3', sort(tot_traptime));% the time for a charge to detrap




