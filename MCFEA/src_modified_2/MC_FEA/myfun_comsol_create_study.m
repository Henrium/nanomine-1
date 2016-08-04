% Create study
function model = myfun_comsol_create_study(model)
% Define study type
model.study.create('std1');
model.study('std1').feature.create('stat', 'Stationary');
model.study('std1').feature('stat').activate('es', true);
disp('Created study');
end
