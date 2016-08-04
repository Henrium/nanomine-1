% Create solution and export electric field data
% 3D electron hopping model 

function model = myfun_comsol_create_solution(model)
disp('Begin solving for solution. This may take a few minutes...')
global savefile

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').feature.create('st1', 'StudyStep');
model.sol('sol1').feature('st1').set('study', 'std1');
model.sol('sol1').feature('st1').set('studystep', 'stat');
model.sol('sol1').feature.create('v1', 'Variables');
model.sol('sol1').feature.create('s1', 'Stationary');
model.sol('sol1').feature('s1').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').feature.create('i1', 'Iterative');
model.sol('sol1').feature('s1').feature('i1').set('linsolver', 'cg');
model.sol('sol1').feature('s1').feature('fc1').set('linsolver', 'i1');
model.sol('sol1').feature('s1').feature('i1').feature.create('mg1', 'Multigrid');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('prefun', 'amg');
model.sol('sol1').feature('s1').feature.remove('fcDef');
model.sol('sol1').attach('std1');

model.result.create('pg1', 3);
model.result('pg1').set('data', 'dset1');
model.result('pg1').feature.create('slc1', 'Slice');
model.result('pg1').feature('slc1').set('expr', {'V'});
model.result('pg1').feature('slc1').set('quickplane', 'xy');
model.result('pg1').feature('slc1').set('quickznumber', '1');
model.result('pg1').feature.create('slc2', 'Slice');
model.result('pg1').feature('slc2').set('expr', {'V'});
model.result('pg1').feature('slc2').set('quickplane', 'yz');
model.result('pg1').feature('slc2').set('quickxnumber', '1');
model.result('pg1').feature('slc2').set('inheritplot', 'slc1');
model.result('pg1').feature.create('slc3', 'Slice');
model.result('pg1').feature('slc3').set('expr', {'V'});
model.result('pg1').feature('slc3').set('quickplane', 'zx');
model.result('pg1').feature('slc3').set('quickynumber', '1');
model.result('pg1').feature('slc3').set('inheritplot', 'slc1');
model.result('pg1').name('Electric Potential (es)');
model.sol('sol1').runAll;
model.result('pg1').run;

% Export efield and potential to files
model.result.export.create('data1', 'Data');
model.result.export('data1').setIndex('expr', 'V', 0);
model.result.export('data1').set('filename', [savefile,'_Potential_output.csv']);
model.result.export('data1').set('header', 'off');
model.result.export('data1').run;

model.result.export.create('data2', 'Data');
model.result.export('data2').setIndex('expr', 'es.normE', 0);
model.result.export('data2').setIndex('descr', 'Electric Field', 0);
model.result.export('data2').set('header', 'off');
model.result.export('data2').set('filename',  [savefile,'_Efield_output.csv']);
model.result.export('data2').run;



disp('Finished computing solution. Electric field data has been exported to CSV file.');
end
