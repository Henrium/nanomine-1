% Create mesh
function model = myfun_comsol_create_mesh(model)
global MeshLevel
model.mesh.create('mesh1', 'geom1');

%% User-defined meshing
%%% Define meshing parameters
%hmax       = 0.08;                 % max element size
%hmin       = 0.01;                 % min element size
%hgrad      = 1.5;                  % max element growth rate
%hcurve     = 5;                    % resolution of curvature
%hnarrow    = 0.2;                  % resolution of narrow regions
%model.mesh('mesh1').automatic(false);
%model.mesh('mesh1').feature('size').set('custom', 'on');    % user-defined mesh
%model.mesh('mesh1').feature('size').set('hmax', hmax);
%model.mesh('mesh1').feature('size').set('hmin', hmin);
%model.mesh('mesh1').feature('size').set('hgrad', hgrad);
%model.mesh('mesh1').feature('size').set('hcurve', hcurve);
%model.mesh('mesh1').feature('size').set('hnarrow', hnarrow);
%model.mesh('mesh1').run;

% Automatic meshing
 model.mesh('mesh1').autoMeshSize(MeshLevel); 
 model.mesh('mesh1').run;
disp('Finished meshing');
end
