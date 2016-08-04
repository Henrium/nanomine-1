% Assign entities with material properties
function model = myfun_comsol_create_material(model)
global epsilonr_filler epsilonr_matrix

% Define matrix material
model.material.create('mat2'); 
%model.material('mat2').selection.named('geom1_DiffMatrix_dom');
% set to be the entire domain and let the following to overide to avoid cases when some domain is left
% unassigned
model.material('mat2').selection.all;
model.material('mat2').propertyGroup('def').set('relpermittivity', epsilonr_matrix); 


% Define filler material
model.material.create('mat1');
model.material('mat1').selection.named('geom1_UnionFiller_dom');
model.material('mat1').propertyGroup('def').set('relpermittivity',epsilonr_filler);

disp('Created material');
end
