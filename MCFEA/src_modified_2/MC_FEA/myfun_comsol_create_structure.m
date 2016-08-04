% Create geometry
function [model] = myfun_comsol_create_structure(model,np_coord)
global dimensionX e_coord FillerRadius dimensionY dimensionZ

corner = min(np_coord)-FillerRadius*1.1;
corner = min([corner;0,0,0]);
box = max(np_coord)+FillerRadius*2*1.1;
box = max([box;dimensionX,dimensionY,dimensionZ]);

% Define simulation box dimensions
%  
% X = dimensionX+5;
% Y = dimensionY+5;
% Z = dimensionZ+5;

% Create rectangular domain
% model.geom('geom1').feature.create('RectBlock', 'Block');

model.geom('geom1').feature('RectBlock').set('size', box);
model.geom('geom1').feature('RectBlock').set('pos', corner);
model.geom('geom1').feature('RectBlock').set('createselection', 'on');
model.geom('geom1').run('RectBlock');

disp('Create filler microstructure ...');
FeatureFiller={}; % List of filler circles
FeaturePoint={}; 

% Create fillers
v_np_size = size(np_coord); % get number of fillers from coordinate vector
for i = 1 : v_np_size(1)
    FeatureFiller{i}=['CircularFiller',num2str(i)];
    model.geom('geom1').feature().create(FeatureFiller{i},'Sphere');
    model.geom('geom1').feature(FeatureFiller{i}).set('pos',[np_coord(i,1) np_coord(i,2) np_coord(i,3)]);
    model.geom('geom1').feature(FeatureFiller{i}).set('r', FillerRadius);
    model.geom('geom1').feature(FeatureFiller{i}).set('createselection','on');
end
disp(['CircularFiller',num2str(i)]);
model.geom('geom1').runAll;

model.geom('geom1').feature.create('UnionFiller', 'Union');
model.geom('geom1').feature('UnionFiller').selection('input').set(FeatureFiller);
model.geom('geom1').feature('UnionFiller').set('createselection', 'on');
model.geom('geom1').feature('UnionFiller').set('intbnd', 'off');
model.geom('geom1').run('UnionFiller');

model.geom('geom1').feature.create('UnionFiller1', 'Intersection');
model.geom('geom1').feature('UnionFiller1').selection('input').set({'RectBlock','UnionFiller'});
model.geom('geom1').feature('UnionFiller1').set('keep', 'off');
model.geom('geom1').feature('UnionFiller1').set('intbnd', 'off');
model.geom('geom1').feature('UnionFiller1').set('createselection', 'on');
model.geom('geom1').run('UnionFiller1');


model.geom('geom1').create('RectBlock1', 'Block');
model.geom('geom1').feature('RectBlock1').set('size', box);
model.geom('geom1').feature('RectBlock1').set('pos', corner);
model.geom('geom1').feature('RectBlock1').set('createselection', 'on');
model.geom('geom1').run('RectBlock1');



model.geom('geom1').feature.create('DiffMatrix', 'Difference');
model.geom('geom1').feature('DiffMatrix').selection('input').set('RectBlock1');
model.geom('geom1').feature('DiffMatrix').selection('input2').set('UnionFiller1');
model.geom('geom1').feature('DiffMatrix').set('keep', 'on');
model.geom('geom1').feature('DiffMatrix').set('createselection', 'on');
model.geom('geom1').run('DiffMatrix');


% Create point charges
v_e_size = size(e_coord); % get number of fillers from coordinate vector
for i = 1 : v_e_size(1)
    FeaturePoint{i}=['PointCharge',num2str(i)];
    model.geom('geom1').feature().create(FeaturePoint{i}, 'Point');
    model.geom('geom1').feature(FeaturePoint{i}).set('p', e_coord); % y coordinate of point charges
    model.geom('geom1').feature(FeaturePoint{i}).set('createselection', 'on');
    disp(['PointCharge',num2str(i)])
end

model.geom('geom1').runAll;
model.geom('geom1').feature.create('UnionCharge', 'Union');
model.geom('geom1').feature('UnionCharge').selection('input').set(FeaturePoint);
model.geom('geom1').feature('UnionCharge').set('createselection', 'on');
model.geom('geom1').feature('UnionCharge').set('keep', 'on');



model.geom('geom1').create('Xface', 'ExplicitSelection');
model.geom('geom1').feature('Xface').selection('selection').init(2);
model.geom('geom1').feature('Xface').selection('selection').set('RectBlock1', [2]);

model.geom('geom1').create('Xface1', 'ExplicitSelection');
model.geom('geom1').feature('Xface1').selection('selection').init(2);
model.geom('geom1').feature('Xface1').selection('selection').set('RectBlock1', [5]);

model.geom('geom1').runAll;

%% create selection to remove the extra edge on the intersected spheres

% find NP with center coordinates close to the boundary
% any NP with center-to-block boudnary distance smaller than
% 0.1*FillerRadius will be found
% 
% j = 1;
% Cylsel={};
% axis={};
% for i=1:v_np_size(1)
%     if (np_coord(i,1) < dimensionX && np_coord(i,1) > 0)&& (np_coord(i,1)-dimensionX > -0.1*FillerRadius || np_coord(i,1) < 0.1*FillerRadius)
%         Cylsel{j}=['cylsel',num2str(j)];        
%         cy_coord(j,:) = np_coord(i,:);
%         axis{j} = 'x';
%         j=j+1;
%     end
%     
%     if  (np_coord(i,2) < dimensionY && np_coord(i,2) > 0) && (np_coord(i,2)-dimensionY > -0.1*FillerRadius || np_coord(i,2) < 0.1*FillerRadius)
%         Cylsel{j}=['cylsel',num2str(j)];
%         cy_coord(j,:) = np_coord(i,:);
%         axis{j} = 'y';
%         j=j+1;
%     end
%     
%     if  (np_coord(i,3) < dimensionZ && np_coord(i,3) > 0) && (np_coord(i,3)-dimensionZ > -0.1*FillerRadius ||np_coord(i,3) < 0.1*FillerRadius)
%         Cylsel{j}=['cylsel',num2str(j)];
%         cy_coord(j,:) = np_coord(i,:);
%         axis{j} = 'z';
%         j=j+1;
%     end    
% end
% 
% 
% % creat a cylinder selection to include the edges on the NP
% 
% if ~isempty(Cylsel)
%     for k = 1:length(Cylsel)
%         model.geom('geom1').create(Cylsel{k}, 'CylinderSelection');
%         model.geom('geom1').feature(Cylsel{k}).set('entitydim', '1');
%         model.geom('geom1').feature(Cylsel{k}).set('top', '0.1');       % the height of the cylinder is 1;
%         model.geom('geom1').feature(Cylsel{k}).set('bottom', '-0.1');
%         model.geom('geom1').feature(Cylsel{k}).set('r', FillerRadius*1.01);  % the radius of the cylinder is 1 larger than sphere 
%         model.geom('geom1').feature(Cylsel{k}).set('axistype', axis{k});
%         model.geom('geom1').feature(Cylsel{k}).set('pos', [cy_coord(k,1), cy_coord(k,2) cy_coord(k,3)]);
%         model.geom('geom1').feature(Cylsel{k}).set('condition', 'inside');
%         model.geom('geom1').run(Cylsel{k});
%         disp(['edge ',num2str(k),' removed']);
%     end
% 
%     model.geom('geom1').create('UnionEdge', 'UnionSelection');
%     model.geom('geom1').feature('UnionEdge').set('entitydim', '1');
%     model.geom('geom1').feature('UnionEdge').set('input', Cylsel);
%     model.geom('geom1').run('UnionEdge');
% 
%     % ingore these edges during meshing
%     model.geom('geom1').create('ige1', 'IgnoreEdges');
%     model.geom('geom1').feature('ige1').selection('input').named('UnionEdge');
%     %mphsave(model, 'DEBUG_structure');
%     model.geom('geom1').run('ige1');
% end






disp('Finished building geometry.');
end
