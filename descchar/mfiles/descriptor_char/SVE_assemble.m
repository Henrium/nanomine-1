function SVE_assemble()
% Image assembly starts here
clear all;
ImgSize=1430;
img_list = dir('./imgs/*.mat');
num_img = length(img_list);



% The characterization starts here
scfactor = 200/146;

disp('Welcome to the world of characterization');

R_vfs = [];
R_intph1 = [];
R_intph0 = [];

R_eccen = {};       P_eccen = [];
R_pores = {};       P_pores = [];
R_rnds = {};        P_rnds = [];
R_ttst = {};        P_ttst = [];
R_els = {};         P_els = [];
R_ornang = {};      P_ornang = [];
R_rctan = {};       P_rctan = [];

R_n = [];

R_comp = {};        P_comp = [];  % Weibull
R_area = {};        P_area = [];  % Exp
R_rc = {};          P_rc = [];    % Weibull
R_locvf = {};       P_locvf = [];  % Exp

R_mori = [];

R_nbd = {};         P_nbd = [];
R_ncd = {};         P_ncd = [];

R_corrf = [];
R_corrs = [];
R_corrl = [];
R_radif = [];

corrx = [];   % x axis for plotting correlation functions
corrlx = [];  % x axis for plotting lineal correlation functions
corrrx = [];  % x axis for plotting radial correlation functions

allimg = {};
count = 1;
cs=1430;
for ii = 1:1:num_img

    
            current_img = img_list(ii).name;
            disp(strcat('========',current_img,'========'));
            file_path = strcat('./imgs/',current_img);
            load(file_path);
            Bimg=img_out(1:1430,1:1430);

%             Bimg = img_out(1:1430,1:1430);
            % choose the cut size
%             cs = 1430;
            Bimg1 = Bimg;
%             Bimg1 = Bimg( :, 1:cs );
%             Bimg2 = Bimg( :, length(Bimg)-cs+1 : length(Bimg) ); 
            
            Bimg1 = ceil(Bimg1/1000);
%             Bimg2 = ceil(Bimg2/1000);
            
            % Get colored image, avoiding using bwlabel in each subfunction
            Cimg1 = bwlabel(Bimg1);
%             Cimg2 = bwlabel(Bimg2); 
            
            % (1) VF
            vfs1 = sum(Bimg1(:))/cs^2;
%             vfs2 = sum(Bimg2(:))/cs^2;
            
            % (2) interphase
            temp = find_edge_1(Bimg1);
            intph1_1 = size(temp,1);
            intph1_1 = intph1_1 / cs^2;
            temp = find_edge_0(Bimg1);
            intph0_1 = size(temp,1);
            intph0_1 = intph0_1 / cs^2;
            
%             temp = find_edge_1(Bimg2);
%             intph1_2 = size(temp,1);
%             intph1_2 = intph1_2 / cs^2;
%             temp = find_edge_0(Bimg2);
%             intph0_2 = size(temp,1);
%             intph0_2 = intph0_2 / cs^2;
%             
            clear temp
            
            % (3) max inscribe circle (pore size)  &&  Eccentricity
            M1 = max(Cimg1(:));
            eccen1 = zeros(M1, 1);
            pores1 = zeros(M1, 1);
            for kk = 1:1:M1
                
                if mod(kk,50) == 0; disp(M1-kk); end
                % Get a single cluster
                timg = double(Cimg1 == kk);
                
                % Eccentricity
                STAT = regionprops(timg, 'Eccentricity');
                eccen1(kk) = STAT.Eccentricity;
                
                % Pore size
                timg = find_edge_1_img(timg);
                [p1, ~, ~] = max_inscribed_circle(timg,0);
                if p1 == 0
                    p1 = 0.5;
                end
                pores1(kk) = p1 * scfactor;
                
            end
            
%             M2 = max(Cimg2(:));
%             eccen2 = zeros(M2, 1);
%             pores2 = zeros(M2, 1);
%             for kk = 1:1:M2
%                 
%                 if mod(kk,50) == 0; disp(M2-kk); end
%                 % Get a single cluster
%                 timg = double(Cimg2 == kk);
%                 
%                 % Eccentricity
%                 STAT = regionprops(timg, 'Eccentricity');
%                 eccen2(kk) = STAT.Eccentricity;
%                 
%                 % Pore size
%                 timg = find_edge_1_img(timg);
%                 [p2, ~, ~] = max_inscribed_circle(timg,0);
%                 if p2 == 0
%                     p2 = 0.5;
%                 end
%                 pores2(kk) = p2 * scfactor;
%             end
%             
            clear kk p1 p2 STAT timg
            
            disp('Finish step 3')
            
            % (4) roundness, tortousity
            [rnds1, ttst1] = rnd_tort(Cimg1);
            rnds1 = rnds1(:);   ttst1 = ttst1(:);
            
%             [rnds2, ttst2] = rnd_tort(Cimg2);
%             rnds2 = rnds2(:);   ttst2 = ttst2(:);
%             
            % (5) Elongation ratio, orintation angles, rectangularity
            [~, els1, ornang1, rctan1]=faster_elongation_II(Cimg1);
            els1 = els1(:);   ornang1 = ornang1(:);   rctan1 = rctan1(:);
            
%             [~, els2, ornang2, rctan2]=faster_elongation_II(Cimg2);
%             els2 = els2(:);   ornang2 = ornang2(:);   rctan2 = rctan2(:);
%             
            disp('Finish step 5')
            
            % (6) Cluster number, compactness, area, radius
            [n1, comp1, area1, rc1] = faster_nh_ch(Cimg1);
            comp1 = comp1(:);   area1 = area1(:) .* scfactor^2;   rc1 = rc1(:) .* scfactor;
            
%             [n2, comp2, area2, rc2] = faster_nh_ch(Cimg2);
%             comp2 = comp2(:);   area2 = area2(:)  .* scfactor^2;   rc2 = rc2(:) .* scfactor;
            
            % parmhat = wblfit(rc1); % Evaluate the Weibull dist parameters a, b for rc
            
            % (7) Local Voronoi VF
            tx1 = zeros(M1,1);
            ty1 = zeros(M1,1);
            for kk = 1:1:M1
                timg = double(Cimg1 == kk);
                STAT = regionprops(timg, 'Centroid');
                tx1(kk) = max( [ 1 , round( STAT.Centroid(2) ) ] );
                ty1(kk) = max( [ 1 , round( STAT.Centroid(1) ) ] );
            end
            [locvf1, ~] = localVoronoiVF(Bimg1, tx1, ty1);
            locvf1 = locvf1(:);
            
%             % Plot validation
%             BBimg1 = Bimg1;
%             for kk = 1:1:M1
%                 BBimg1( tx(kk), ty(kk) ) = 5;
%             end
            
%             tx2 = zeros(M2,1);
%             ty2 = zeros(M2,1);
%             for kk = 1:1:M2
%                 timg = double(Cimg2 == kk);
%                 STAT = regionprops(timg, 'Centroid');
%                 tx2(kk) = max( [ 1 , round( STAT.Centroid(2) ) ] );
%                 ty2(kk) = max( [ 1 , round( STAT.Centroid(1) ) ] );
%             end
%             [locvf2, ~] = localVoronoiVF(Bimg2, tx2, ty2);
%             locvf2 = locvf2(:);
%             
            clear STAT  timg
            
            disp('Finish step 7')
            
            % (8) Morisita's Index, nearest boundary distances, nearest center distances
            [mori1] = Morishita_E(Bimg1);  mori1 = mori1(:);
%             [mori2] = Morishita_E(Bimg2);  mori2 = mori2(:);
            
            nbd1 = nearest_distance(Bimg1).*scfactor;
%             nbd2 = nearest_distance(Bimg2);
            
            [~, ~, ncd1] = nearest_center_distance(Bimg1);
            ncd1 = ncd1.*scfactor;
%             [~, ~, ncd2] = nearest_center_distance(Bimg2);
            
            % (9) 2-point correlation
            corrf1 = evaluate_2D(Bimg1);  corrf1 = corrf1(:);
%             corrf2 = evaluate_2D(Bimg2);  corrf2 = corrf2(:);
%             
            disp('Finish step 9')
            
            % (10) Surface correlation function
            corrs1 = surfcorr(Bimg1);  corrs1 = corrs1(:);
%             corrs2 = surfcorr(Bimg2);  corrs2 = corrs2(:);
            
            % (11) Linear path correlation
            corrl1 = linearpath(Bimg1);  corrl1 = corrl1(:);
%             corrl2 = linearpath(Bimg1);  corrl2 = corrl2(:);
            
            % (12) Radius distance function
            radif1 = radius_dist(tx1, ty1, cs);  radif1 = radif1(:);
%             radif2 = radius_dist(tx1, ty1, cs);  radif2 = radif2(:);
            
            disp('Finish step 12')
            
            % Write into the Record_matrix
            R_vfs = [ R_vfs  vfs1 ];
            R_intph1 = [ R_intph1  intph1_1];
            R_intph0 = [ R_intph0  intph0_1];
            
            R_eccen{count} = eccen1;    
%             R_eccen{count+1} = eccen2;
            R_pores{count} = pores1;    
%             R_pores{count+1} = pores2;
            R_rnds{count} = rnds1;      
%             R_rnds{count+1} = rnds2;
            R_ttst{count} = ttst1;      
%             R_ttst{count+1} = ttst2;
            R_els{count} = els1;        
%             R_els{count+1} = els2;
            R_ornang{count} = ornang1;  
%             R_ornang{count+1} = ornang2;
            R_rctan{count} = rctan1;    
%             R_rctan{count+1} = rctan2;
            
            R_n = [ R_n  n1];
            
            R_comp{count} = comp1;      
%             R_comp{count+1} = comp2;
            R_area{count} = area1;      
%             R_area{count+1} = area2;
            R_rc{count} = rc1;          
%             R_rc{count+1} = rc2;
            R_locvf{count} = locvf1;    
%             R_locvf{count+1} = locvf2;
            
            R_mori = [ R_mori  mori1 ];
            
            R_nbd{count} = nbd1;       
%             R_nbd{count+1} = nbd2;
            R_ncd{count} = ncd1;        
%             R_ncd{count+1} = ncd2;
                      
            R_corrf = [ R_corrf  corrf1];
            R_corrs = [ R_corrs  corrs1];
            R_corrl = [ R_corrl  corrl1];
            R_radif = [ R_radif  radif1];
            
            corrx = [ corrx ( (1:1:length(corrf1)) * scfactor )' ];
            corrlx = [ corrlx ( (1:1:length(corrl1)) * scfactor )' ];
            corrrx = [ corrrx ( (1:1:length(radif1)) * scfactor )' ];
            
            allimg{count} = Bimg1;
%             allimg{count+1} = Bimg2;
            
            count = count + 1;
            
            % Parameterization: [ mean, variance, skewness, kurtosis ]
            P_eccen = [ P_eccen ; mean(eccen1) var(eccen1) skewness(eccen1) kurtosis(eccen1) ];
%             P_eccen = [ P_eccen ; mean(eccen2) var(eccen2) skewness(eccen2) kurtosis(eccen2) ];
            
            P_pores = [ P_pores ; mean(pores1) var(pores1) skewness(pores1) kurtosis(pores1) ];
%             P_pores = [ P_pores ; mean(pores2) var(pores2) skewness(pores2) kurtosis(pores2) ];

            P_rnds = [ P_rnds ; mean(rnds1) var(rnds1) skewness(rnds1) kurtosis(rnds1) ];
%             P_rnds = [ P_rnds ; mean(rnds2) var(rnds2) skewness(rnds2) kurtosis(rnds2) ];
            
            P_ttst = [ P_ttst ; mean(ttst1) var(ttst1) skewness(ttst1) kurtosis(ttst1) ];
%             P_ttst = [ P_ttst ; mean(ttst2) var(ttst2) skewness(ttst2) kurtosis(ttst2) ];
            
            P_els = [ P_els ; mean(els1) var(els1) skewness(els1) kurtosis(els1) ];
%             P_els = [ P_els ; mean(els2) var(els2) skewness(els2) kurtosis(els2) ];
            
            P_ornang = [ P_ornang ; mean(ornang1) var(ornang1) skewness(ornang1) kurtosis(ornang1) ];
%             P_ornang = [ P_ornang ; mean(ornang2) var(ornang2) skewness(ornang2) kurtosis(ornang2) ];
            
            P_rctan = [ P_rctan ; mean(rctan1) var(rctan1) skewness(rctan1) kurtosis(rctan1) ];
%             P_rctan = [ P_rctan ; mean(rctan2) var(rctan2) skewness(rctan2) kurtosis(rctan2) ];
            
            P_comp = [ P_comp ; mean(comp1) var(comp1) skewness(comp1) kurtosis(comp1) ];
%             P_comp = [ P_comp ; mean(comp2) var(comp2) skewness(comp2) kurtosis(comp2) ];
            
            P_area = [ P_area ; mean(area1) var(area1) skewness(area1) kurtosis(area1) ];
%             P_area = [ P_area ; mean(area2) var(area2) skewness(area2) kurtosis(area2) ];
            
            P_rc = [ P_rc ; mean(rc1) var(rc1) skewness(rc1) kurtosis(rc1) ];
%             P_rc = [ P_rc ; mean(rc2) var(rc2) skewness(rc2) kurtosis(rc2) ];
            
            P_locvf = [ P_locvf ; mean(locvf1) var(locvf1) skewness(locvf1) kurtosis(locvf1) ];
%             P_locvf = [ P_locvf ; mean(locvf2) var(locvf2) skewness(locvf2) kurtosis(locvf2) ];
            
            P_nbd = [ P_nbd ; mean(nbd1) var(nbd1) skewness(nbd1) kurtosis(nbd1) ];
%             P_nbd = [ P_nbd ; mean(nbd2) var(nbd2) skewness(nbd2) kurtosis(nbd2) ];
            
            P_ncd = [ P_ncd ; mean(ncd1) var(ncd1) skewness(ncd1) kurtosis(ncd1) ];
%             P_ncd = [ P_ncd ; mean(ncd2) var(ncd2) skewness(ncd2) kurtosis(ncd2) ];
            
            
%         end
        
%     end
end    

P_eccen = P_eccen';
P_pores = P_pores';
P_rnds = P_rnds';
P_ttst = P_ttst';
P_els = P_els';
P_ornang = P_ornang';
P_rctan = P_rctan';
P_area = P_area';
P_comp = P_comp';
P_locvf = P_locvf';
P_rc = P_rc';
P_nbd = P_nbd';
P_ncd = P_ncd';
save_path = strcat('./imgs/','ch_result.mat');
save(save_path);

end
