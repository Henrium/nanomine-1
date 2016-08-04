% comsol_conf.m
% Configuration files for COMSOL model using API

clear all; close all; clc; warning('off', 'all')
% addpath('/usr/local/comsol52/multiphysics/mli','/usr/local/comsol52/multiphysics/mli/startup');
addpath('/home/NANOMINE/comsol52/mli', '/home/NANOMINE/comsol52/mli/startup') % 95
mphstart(2037);
%load('art_shifting.mat');
sample=importdata('small.txt'); 
n=length(sample)
global vf_expt ...          
    DomLength ...           
    dimension_to_pixel ...  
    CutSide ...             
    TauShift1 DeltaEpsilonShift1 TauShift2 DeltaEpsilonShift2 ConstEpsilonShift ...
    InterfaceThickness1 InterfaceThickness2 InterfaceThickness... 
    epmodel ...  			
    EpsDistribution ...     
    ReScale ... 			
    GetSolution  ... 		
    ManualMesh MeshLevel ...
    tau0 ...
    PortNum
	
	
	
% --------------user defined input ------------------------
for i=1:n
id=i;
structure=['./crop_anthracenePGMA_2wt%_2D_structure_output'];
    
GetSolution             = 1; 
PortNum 				= 2036; 

vf_expt                 = 1/100;   % labelled volume fraction
TauShift1 		        = sample(i,1);       % beta relaxation, s_beta, For tau <= 1, Shift multiplier along x direction. 1 is no shift
DeltaEpsilonShift1 	    = sample(i,2);  	% beta relaxation, M_beta, For tau <= 1, Shift multiplier along y direction. 1 is no shift
TauShift2 		        =sample(i,3); 	% Alpha relaxation, s_alpha, for tau > 1, Shift multiplier along x direction. 1 is no shift
DeltaEpsilonShift2		= sample(i,4)  	% Alpha relaxation, M_alpha, For tau > 1, Shift multiplier along y direction. 1 is no shift
ConstEpsilonShift		= sample(i,5); 	% Constant vertical shift for real permittivity
tau0                    = 0.01; 	% tau*freq_crit = 1. E.g, for freq_crit = 10 Hz, tau = 0.1 s. 

% Ratio of physical dimension to pixel 
dimension_to_pixel		= 1/1; % [nm]/[# of pixel]. 

% Add API source files to path
% microstructure		
%structure = './structure_output_N_30'; 
% experimental dielectric relaxation data 
%exptdata = '../expt_epoxy_DS/ferrocene_PGMA_2wt-TK.csv';  % no useful here, commond it

% neat polymer properties
PolymerPronySeries   = './RoomTempEpoxy.mat'; 

% -------------- end user defined input ------------------------

% -------------- model config parameters ------------------------
CutSide                 = 0.1;	                              % fractin of side to cut to remove edge effect
IP1                     = 10;                                % extrinsic interphase thickness [nm]
IP2                     = 40;                                % intrinsic interphase thickness[nm]
InterfaceThickness1     = IP1*1e-3;                          % [mm], physical length, Interficial region thickness with constant properties
InterfaceThickness2     = IP2*1e-3;                          % [mm], physical length, Interficial region thickness with freq dependent properties
InterfaceThickness      = InterfaceThickness2 + InterfaceThickness1;

ReScale 			= 1;            % '1' for re-scaling to match with vf_expt. '0' to use actual VF from binary image
EpsDistribution 	= 1;            % '1' for using dielectric relaxation distribution, rather than a fixed value
ManualMesh          = 0;    		% '1' for manual mesh. meshing parameters are defined in comsol_create_mesh.m
MeshLevel           = 5;            % Use when ManualMesh = 0. Range from 1 to 9 (finest to most coarse)

% No-relaxation polymer matrix (non-epoxy)
if EpsDistribution == 0; 
	% polymer permittivity
	epmodel.ep		= 2; 
	epmodel.epp 	= 1e-3;
	% fixed interphase permittivity shift 
	epintShift 		= 0;
	epmodel.epint 	= epmodel.ep + epintShift;5.
	eppintShift 	= 0;
	epmodel.eppint 	= epmodel.epp + eppintShift;
end
% -------------- end model config parameters ------------------------

% Run Model
savefile = ['DOE','_run_',num2str(id)]; % Output COMSOL project name
tic
model = comsol_build(PolymerPronySeries, structure, savefile);
disp('Job done. Output result to .mph file');

% Export API-created model to file
%mphsave(model, savefile);
toc
end

% Plot computed results and compare against expt data
%plot_results(savefile, exptdata)
