% Create physics
function model = myfun_comsol_create_physics(model)
global PtCharge InitialVoltage AppliedVoltage

disp('Create physics model ...')
% Initial voltage
model.physics('es').feature('init1').set('V', 1, InitialVoltage);


model.physics('es').feature('pot1').selection.named('geom1_Xface');
model.physics('es').feature('gnd1').selection.named('geom1_Xface1');
model.physics('es').feature('pot1').set('V0', 1, AppliedVoltage);

% Point Charges
model.physics('es').feature.create('pcg1', 'PointCharge', 0);
model.physics('es').feature('pcg1').selection.named('geom1_UnionCharge_pnt');
model.physics('es').feature('pcg1').set('Qp', 1, PtCharge);

disp('Created electrostatics physics');        
        