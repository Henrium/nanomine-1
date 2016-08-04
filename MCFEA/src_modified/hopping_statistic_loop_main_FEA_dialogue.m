%% This is the main file

% This script is used to simulate the charge transport in dielectric
% polymers and their composites using a Monte Carlo method. User needs to define the density of states
% function and filler morphology. The electric field distribution is
% computed by a AC/DC module in COMSOL

% Tested on COMOSL 5.0, MATLAB R2013a, MAC OS X
% Jun 1, 2016

% Copyright, Yanhui Huang, Rensselaer Polytechnic Institute.


% To run on other systems, user need to change the fielp path, and the COMSOL
% call command.

%% define input parameters

%function [E,final_coord,final_coord_reduced,tot_x,t,ave_E,trap_record] = hopping_statistic_loop_main_FEA(type,mean_num_NP)

global lx ly lz F cutoff_n rec_t tot_e np_coord NP_radius cutoff_d

%=============== user controlled input ===============================
filepath = './MC_FEA/';
addpath('/home/NANOMINE/comsol52/mli', '/home/NANOMINE/comsol52/mli/startup');
addpath(genpath('./MC_FEA'));
addpath('./MC_3D_hopping/');
addpath('./MC_3D_hopping/support_function/');
mphstart(2036);



% nominal electric field, unit V/m
F = inputdlg('What is the nominal field? (in V/m)','Field',1,{'1e7'});
F = str2num(F{1});

DOS = questdlg('Define the shape of the density of states function','DOS','gaussian','exponential','arbitrary','gaussian');

% density of states function, select either 'gaussian' or 'exponential' or 'arbitrary'
%   showing the equaiton for gaussian and exponential
%   p(E) = 2/(sigma*sqrt(2pi))*exp(-E^2/sigma^2), gaussian
%   p(E) = sigma*exp(-E/sigma), exponential
%   sigma = k*T0;


switch DOS
    case 'gaussian'
        text = sprintf('p(E) = 2/(sigma*sqrt(2pi))*exp(-E^2/sigma^2) \nsigma = kT \nPlease input T (in K)');
        T0  = inputdlg(text,'DOS',1,{'2600'}); %2600;
        T0  = str2num(T0{1});
        
    case 'exponential'
        text = sprintf('p(E) = kT*exp(-E/kT) \nPlease input T (in K)');
        T0  = inputdlg(text,'DOS',1,{'1300'}); %2600;
        T0  = str2num(T0{1});
        
    case 'arbitrary'
        prompt = {'Please input the deepest energy with 0 as reference (in eV)','Please input the probability'};
        title  = 'Input';
        num_lines = 1;
        defAns    = {'0,2,3,4,5','-1.1'};
        Ans       = inputdlg(prompt,title,num_lines,defAns);
        probability = str2num(Ans{1});
        E_range     = str2num(Ans{2});
end
        

% whether to include NP, neat polymer or composites
include_NP = questdlg('Whether to include nanoparticles?');
if strcmp(include_NP,'Yes')
    include_NP = true;
else 
    include_NP = false;
end

if include_NP
    
    prompt = {'Please specify the NP energy in eV',...
        'Please specify the average size of the cluster (a Gaussain distribution)',...
        'Please specify the standard deviation of the distribution, uniform size if input 0',...
        'Please specify the particle radius',...
        'Please specfiy the volume fraction'};
    
    title = 'Input';
    num_lines = 1;
    defAns    = {'-1.1','30','5','2.5','0.004'};
    Ans       = inputdlg(prompt,title,num_lines,defAns);
    
    % the NP particle energy, unit eV
    NP_energy = str2num(Ans{1});

    % size of the cluster, mean value
    mean_num_NP = str2num(Ans{2});
    
    % standard deviation o the cluster size
    dev         = str2num(Ans{3});
    
    % NP radius, unit nm
    NP_radius = str2num(Ans{4});
    
    % volume fraction
    vf        = str2num(Ans{5});
    
    % type of the cluster shape, can be either, 'round', 'random', 'line',
    % or 'sheet'
    type = questdlg('Specify the agglomerates type','','round','line','sheet','round');
    
    % whether to couple finite element to calculate field distribution
    FEA = questdlg('Whether to couple with finite element?','','Yes','No','Yes');
    if strcmp(FEA,'Yes'),FEA= true;else FEA=false;end    
else
    NP_radius = 2.5; % by default value for neat polymer
end


prompt = {'Specify the data points of transport time to record','repeat times'};
def    = {'10.^[-5:0.2:3]','10'};

Ans   = inputdlg(prompt,'time',1,def);

% data points of transport time in the plot, in log scale
rec_t = str2num(Ans{1});

% simulation repeat number, increase this number to improve accurarcy
n  = str2num(Ans{2});



%==================== system default input=============================
trialNo      = '1';
tot_traptime = 0;

% stop simulation if the total traveling distance exceed cutoff_d
cutoff_d     = 1e4*NP_radius/2.5;



% simulation box, scale with NP_radius
lx = round(1000*NP_radius/2.5); %direction of the field (nm)
ly = round(100*NP_radius/2.5);
lz = round(100*NP_radius/2.5);

cutoff_n = round(5e5*NP_radius/2.5); %maxmum simulation step

plot_on = false;     %whether to plot figure

box = [lx,ly,lz];

potential = 0; % by default

%%  Main part


for ii=1:n
    
   % to avoid mesh error
   % while include_NP
       % try
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
            
          %  break;
            
       % catch ME
           % disp(ME);
       % end
   % end
    
    % generate energy grid
    disp('Now constructing the energy landscape...')
    switch DOS
        case 'gaussian'
            %E = generate_1_gaussian_numfit(2600,-1.0469,-1.0941,0.709,-1.1325,0.237,-1.1996,0.054,lx,ly,lz,plot_on);
            E = generate_1_gaussian(T0,lx,ly,lz);
        case 'exponential'
            E = generate_1_expdist(T0,lx,ly,lz);
        case 'arbitrary'
            E = generate_arbitrary_E(E_range,probability,lx,ly,lz);
    end
    
    if include_NP
        %define the NP energy
        E(np_coord) = NP_energy; 
    else NP_energy = 100; 
         FEA = false;
         clusterCell = [];
    end  
    
            
    
    
    cutoff_t = rec_t(end);
    tot_e = fix(8.85e-12*F*3*ly*lz*1e-18/1.6e-19); %total numbers of electrons calcualted by the surface density of charges
    
    if include_NP
        [E_dis,t,totchange_x,final_coord,final_coord_reduced,trap_record,ave_E,trap_time3,TrapInfo] = MC_FEA_3D(E,potential,NP_energy,cutoff_t,FEA,plot_on,clusterCell);% (E,potential,np_coord,energy,cut_off_t,FEA)
    else
        [E_dis,t,totchange_x,final_coord,final_coord_reduced,trap_record,ave_E,trap_time3,TrapInfo] = MC_FEA_3D(E,potential,NP_energy,cutoff_t,FEA,plot_on);
    end
    
    
    E_disCell{ii}       = E_dis;
    totchange_xCell{ii} = totchange_x;
    ave_ECell{ii}       = ave_E;
    tCell{ii}           = t;
    tot_traptime        = [tot_traptime;trap_time3'];
    trap_countCell{ii}  = TrapInfo;
    if include_NP
        save([filepath,...
        num2str(vf),'_',num2str(NP_radius),'_',num2str(mean_num_NP),'_',num2str(dev),'_',type,trialNo,'_data.mat'],...
        'rec_t','totchange_xCell','E_disCell','ave_ECell','trap_countCell','tCell')
    else
        save([filepath,...
        trialNo,'_data.mat'],...
        'rec_t','totchange_xCell','E_disCell','ave_ECell');
    end
end

%% post processing data


tot_x = cell2mat(totchange_xCell');
t     = cell2mat(tCell');

for ii = 1:size(tot_x,1)
A = tot_x(ii,:);
IND = find(A~=0);
if t(ii) >= rec_t(end)
    A(A==0)=A(IND(end));
else
    A(A==0) = NaN;
end
tot_x(ii,:) = A;
end

tot_x = tot_x(:,1:end-1);

figure;
plot(rec_t,nanmean(tot_x),'Marker','sq');
xlabel('time (sec)');
ylabel('traveling distance (nm)');
h = gcf;
saveas(h,['./travel distance.eps'],'psc2');


figure;
hist(E(:),20);
xlabel('energy (eV)');
ylable('histgram');
h = gcf;
saveas(h,['./energy hist.eps'],'psc2');

OUTPUT_DATA = {'time',rec_t;'data',tot_x};

%xlswrite('output.txt',time,'\n');
% first row is the time, and the rest of the row is the traveling distance
% of each elecron at the corresponding time
csvwrite('output.csv',[rec_t;tot_x]);



% tot_traptime = tot_traptime(tot_traptime > 0.001); % remove small time and zero

% assignin('base', 'tot_trap_time3', sort(tot_traptime));% the time for a charge to detrap

