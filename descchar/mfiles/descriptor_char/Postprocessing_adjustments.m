% % P_comp = [];
P_area = [];
% % P_rc = [];
% % P_locvf = [];
% 
for ii = 1:1:56
    
%     comp1 = R_comp{ii};
    area1 = R_area{ii};
%     rc1 = R_rc{ii};
%     locvf1 = R_locvf{ii};
    
%     P_comp = [ P_comp ; mean(comp1) var(comp1) skewness(comp1) kurtosis(comp1) ];

    P_area = [ P_area ; mean(area1) var(area1) skewness(area1) kurtosis(area1) ];

%     P_rc = [ P_rc ; mean(rc1) var(rc1) skewness(rc1) kurtosis(rc1) ];

%     P_locvf = [ P_locvf ; mean(locvf1) var(locvf1) skewness(locvf1) kurtosis(locvf1) ];
    
end
% 
% 
% 
% 
% 
% 
% 
% 
% P_area = [];
% 
% for ii = 1:1:56
%     
%     area1 = R_area{ii};
% 
%     P_area = [ P_area ; mean(area1) var(area1) skewness(area1) kurtosis(area1) ];
%     
% end
% 
% 
% 
% load C_results_Goodyear_samples
% % The characterization results (but no image)
% 
sampletype = [];
for ii = 1:1:11 % 1:1:19     1:1:1 FOR DEBUG, 1:11 for Goodyear sample
    
    for jj = 1:1:5 % should be 1:1:5
        
        name = [num2str(ii) '_' num2str(jj)];
        flag = exist( [ name '.tif' ] );
        if flag ~= 0
            sampletype = [ sampletype, ii, ii];
        end
        
    end
end
%         

%%

dir = '/home/ideal/matlab_work/Statistical Learning/';

% _m means the mean of the descriptor values
VF = [ 0.092  0.092  0.168  0.233  0.233  0.233 ...
    0.092  0.092  0.168  0.233  0.233 ...
    0.015  0.015  0.04  0.04 ...
    0.015  0.015  0.04  0.04 ];  % Volume fraction

allimg = {};

% _v means the variance of the descriptor values
count = 1;

for ii = 1:1:11 % 1:1:19     1:1:1 FOR DEBUG, 1:11 for Goodyear sample
    
    for jj = 1:1:5 % should be 1:1:5
        
        name = [num2str(ii) '_' num2str(jj)];
        flag = exist( [ dir name '.tif' ] );
%         flags = [flags flag];
        
        if flag ~= 0
            
            disp('=======================================================')
            disp( [ 'Now processing image ' name ])
            disp('=======================================================')
            
            img = imread( [name '.tif'] );
            
            % cut the image
            if ii<=11  % The Goodyear 1886x2048 pixel size image
                img = img(1:1767, :);
            else  % The RPI 1030x1300 pixel size image
                img = img(1:939, :);
            end
            img = double(img);
            
            tic; image = medfilt2(img, [10 10]); toc;
            disp('Finish filtering process 1');
            tic; image_f = medfilt2(img, [50 50]); toc;
            disp('Finish filtering process 2');
            
%             img = image - image_f;
            
            img = image;
            
            [~, Bimg] = Transform(img, 1-VF(ii)); 
            
            if ii <= 11
                cs = 1000;
            else
                cs = 802;
            end
            
            Bimg1 = Bimg( 1:cs, 1:cs );
            Bimg2 = Bimg( 1767-cs+1 : 1767 , 2048-cs+1 : 2048 );
            
            Bimg1 = 1 - ceil(Bimg1/1000);
            Bimg2 = 1 - ceil(Bimg2/1000);
            
            image = Bimg1;
            save( ['sampleno' num2str(count)], 'image' );
            allimg{count} = image;
            
            image = Bimg2;
            save( ['sampleno' num2str(count+1)], 'image' );
            allimg{count+1} = image;
            
            
            count = count+2;
            
        end
        
    end
end


%% Save the images to the sim_package folder
cd sim_package
for ii = 1:1:56
    image = allimg{ii};
    save(['img' num2str(ii) '.mat' ],'image');
end

vars = [];
for ii = 1:1:56
    
    area = R_area{ii};
    area = sort(area);
    area = area(1: length(area) - 15 );
    vars = [ vars; var(area) ];
end

%% Check the upper/lower bound for each variable from R_data
lower = [];
upper = [];
for ii = 1:1:56
    
    data = R_rnds{ii};
    lower = [ lower; min(data) ];
    upper = [ upper; max(data) ];
    
end




lower = [];
upper = [];
for ii = 1:1:56
    
    data = R_els{ii};
    lower = [ lower; min(data) ];
    upper = [ upper; max(data) ];
    
end


lower = [];
upper = [];
for ii = 1:1:56
    
    data = R_rctan{ii};
    lower = [ lower; min(data) ];
    upper = [ upper; max(data) ];
    
end


