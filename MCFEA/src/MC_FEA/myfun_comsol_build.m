% Build COMSOL model for each step
function model = myfun_comsol_build(np_coord)

global COMSOL_PORT savefile
% Add COMSOL API command folders to MATLAB path
%addpath('/usr/local/comsol43b/mli','/usr/local/comsol43b/mli/startup');
%addpath('/usr/local/comsol50/mli', '/usr/local/comsol50/mli/startup'); 
%addpath('d:/matlabcode');addpath('d:/program files/comsol/comsol44/mli');
addpath('/Applications/COMSOL50/Multiphysics/mli/');
% Step One: Initialize model and geometry
%mphstart(COMSOL_PORT);
import com.comsol.model.*
import com.comsol.model.util.*

% model = ModelUtil.create('Model');
% model.modelNode.create('mod1');
% model.geom.create('geom1', 3); % 3D geometry
% model.geom('geom1').lengthUnit('nm'); 

model = mphload('electron_hopping_base_3D_3pbc.mph');

model.hist().disable()
% Step Two: Create statistically re-generated microstructure
model       = myfun_comsol_create_structure(model,np_coord);

% % Step Four: Create boundary selection indices
% indBoundary = myfun_comsol_create_boundary_selection(model);
% 
% Step Five: Assign entities with material properties
model       = myfun_comsol_create_material(model);

% Step Six: Create physics
model       = myfun_comsol_create_physics(model);
 
% Debug mode:
mphsave(model, 'DEBUG_before_mesh');

% Step Seven: Create mesh
model       = myfun_comsol_create_mesh(model);

% Step Eight: Create Physics-based Study
model       = myfun_comsol_create_study(model);

mphsave(model, 'DEBUG_before_solution');

% Step Nine: Compute solution and export electric field data
model   = myfun_comsol_create_solution(model);   
end
