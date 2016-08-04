%% main.m: calls COMSOL model builder using Java API
% Yanhui Huang
% May 24, 2016. Electron Hopping model generator. To be integrated with
% Monte Carlo

% Uncomment to make this script a modular function
function [potential,field] = FEA_potential(vf,NP_radius,np_coord,box)

global dimensionX dimensionY dimensionZ e_coord FillerRadius epsilonr_filler epsilonr_matrix savefile ...
    PtCharge InitialVoltage AppliedVoltage MeshLevel COMSOL_PORT dist


% e_coord =  electron_coord; % Uncomment for modular function
COMSOL_PORT = 2036;
TrialNo = 1; % User defined
tic
% Geometry
%=========Edit this part to change electron positions after each MC run
e_z             = 1;
e_y             = 1;
e_x             = 1;
e_coord         = [e_y;e_x;e_z;]'; % coordinates of point charges (Z-direction line charges in this model)
field = 1e7;
%=========

FillerRadius    = NP_radius; % The radius used in COMSOL;
min_d           = round(2*FillerRadius);



dimensionX      = box(1); % assuming 2D square projection simulation window
dimensionY      = box(2);  % direction of the field
dimensionZ      = box(3);  


dist            = 0;

disp(['Volume fraction of fillers is ',num2str(100*vf),'%'])

% Materials
epsilonr_filler = 80; % relative permittivity
epsilonr_matrix = 3;

% Input parameters for physics model
PtCharge = 1e-30; % amount of charge for each point
InitialVoltage = 1e-6; % Initial voltage across all domains. Usually a small number
AppliedVoltage = field*dimensionY/1e9; % Applied voltage on bottom surface

% Meshing parameter (automatic meshing only)
MeshLevel = 5; % Range from 1 to 9 (finest to most coarse)

savefile = ['HZ_YH_electron_hopping_3D_',num2str(TrialNo)]; % Output COMSOL project name
% Run Model

model = myfun_comsol_build(np_coord);

disp('Job done. Output result to .mph file');
mphsave(model, savefile);

isInterpolate = 1;
if isInterpolate
    % Interpolate electric field values from mesh points to grid
    efield = csvread([savefile,'_Efield_output.csv']);
    p = csvread([savefile,'_Potential_output.csv']);
    % Output
    % GRID: K by 3 matrix. K: number of grids in X or Y direction. E.g, 100 by 100 grid, K = 100 for a total of 10000 grid points.
    % Column 1: x coordinate in grid
    % Column 2: y coordinate in grid
    % Column 3: z coordinate in grid
    % Column 4: electric field or potential value (V/m or V)
    
    [xq, yq, zq]=meshgrid(1:1:dimensionX,1:1:dimensionY,1:1:dimensionZ);
    if nargout == 2
        field=griddata(efield(:,1),efield(:,2),efield(:,3),efield(:,4),xq,yq,zq);
    end

    potential=griddata(p(:,1),p(:,2),p(:,3),p(:,4),xq,yq,zq);
    
    save([savefile,'_grid_data.mat'],'field','potential','np_coord')
    

end
toc
%end