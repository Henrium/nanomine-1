load('B_aggregated.mat');

% ------------------- The list of characteristics -------------------------
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
% -------------------------------------------------------------------------


% _m means the mean of the descriptor values
% VF = ones(1, 34);
% VF(1:30) = VF(1:30) * 0.01; % Volume fraction
% VF(31:34) = VF(31:34) * 0.005;

% VF = [0.007, 0.01, 0.01, 0.005, 0.005, 0.01, 0.01, 0.009, 0.01, 0.01, 0.005, 0.005];

% Scaling factor: from pixel size to physical size
% scf = ones( 1, 12 );
% scf(1:5)   = scf(1:5)   * 0.464;
% scf(6:10)  = scf(6:10)  * 0.7123;
% %scf(14:23) = scf(14:23) * 0.464;
% scf(11) = scf(11) * 0.958;
% scf(12)    = scf(12)    * 1.2019;
scf = [0.464, 0.464, 0.464, 0.464, 0.464, 0.464, 0.464, 0.464, 0.7123, 0.7123, 0.7123, 0.7123, 0.7123,...
    0.464, 0.464, 0.464, 0.958, 0.958, 0.958, 0.958, 1.2019];

% _v means the variance of the descriptor values
count = 1;
cs = 2000;
for ii = 1
    name = num2str(ii);
        disp(['image' name])
        scfactor = scf(ii);
        Bimg1 = B{ii};            
            % Get colored image, avoiding using bwlabel in each subfunction
            Cimg1 = bwlabel(Bimg1);
            
            
            % (1) VF
            vfs1 = sum(Bimg1(:))/cs^2;
            
            
            % (2) interphase
            temp = find_edge_1(Bimg1);
            intph1_1 = size(temp,1);
            intph1_1 = intph1_1 / cs^2;
            temp = find_edge_0(Bimg1);
            intph0_1 = size(temp,1);
            intph0_1 = intph0_1 / cs^2;
            
            
            
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
            
            
            
            clear kk p1  STAT timg
            
            disp('Finish step 3')
            
            % (4) roundness, tortousity
            [rnds1, ttst1] = rnd_tort(Cimg1);
            rnds1 = rnds1(:);   ttst1 = ttst1(:);
            
           
            
            % (5) Elongation ratio, orintation angles, rectangularity
            [~, els1, ornang1, rctan1]=faster_elongation_II(Cimg1);
            els1 = els1(:);   ornang1 = ornang1(:);   rctan1 = rctan1(:);
            
           
            
            disp('Finish step 5')
            
            % (6) Cluster number, compactness, area, radius
            [n1, comp1, area1, rc1] = faster_nh_ch(Cimg1);
            comp1 = comp1(:);   area1 = area1(:) .* scfactor^2;   rc1 = rc1(:) .* scfactor;
            
           
            
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
            
          
            
            clear STAT  timg
            
            disp('Finish step 7')
            
            % (8) Morisita's Index, nearest boundary distances, nearest center distances
            [mori1] = Morishita_E(Bimg1);  mori1 = mori1(:);
           
            
            nbd1 = nearest_distance(Bimg1);
           
            
            [~, ~, ncd1] = nearest_center_distance(Bimg1);
           
            
            % (9) 2-point correlation
            corrf1 = evaluate_2D(Bimg1);  corrf1 = corrf1(:);
            
            
            disp('Finish step 9')
            
            % (10) Surface correlation function
            corrs1 = surfcorr(Bimg1);  corrs1 = corrs1(:);
          
            
            % (11) Linear path correlation
            corrl1 = linearpath(Bimg1);  corrl1 = corrl1(:);
            
            
            % (12) Radius distance function
            radif1 = radius_dist(tx1, ty1, cs);  radif1 = radif1(:);
            
            
            disp('Finish step 12')
            
            % Write into the Record_matrix
            R_vfs = [ R_vfs  vfs1  ];
            R_intph1 = [ R_intph1  intph1_1   ];
            R_intph0 = [ R_intph0  intph0_1  ];
            
            R_eccen{count} = eccen1;    
            R_pores{count} = pores1;   
            R_rnds{count} = rnds1;    
            R_ttst{count} = ttst1;      
            R_els{count} = els1;        
            R_ornang{count} = ornang1;  
            R_rctan{count} = rctan1;    
            
            R_n = [ R_n  n1  ];
            
            R_comp{count} = comp1;      
            R_area{count} = area1;      
            R_rc{count} = rc1;         
            R_locvf{count} = locvf1;    
            
            R_mori = [ R_mori  mori1  ];
            
            R_nbd{count} = nbd1;      
            R_ncd{count} = ncd1;       
                      
            R_corrf = [ R_corrf  corrf1   ];
            R_corrs = [ R_corrs  corrs1 ];
            R_corrl = [ R_corrl  corrl1   ];
            R_radif = [ R_radif  radif1  ];
            
            corrx = [ corrx ( (1:1:length(corrf1)) * scfactor )' ];
            corrlx = [ corrlx ( (1:1:length(corrl1)) * scfactor )' ];
            corrrx = [ corrrx ( (1:1:length(radif1)) * scfactor )' ];
            
            allimg{count} = Bimg1;
         
            count = count + 1;
            
            % Parameterization: [ mean, variance, skewness, kurtosis ]
            P_eccen = [ P_eccen ; mean(eccen1) var(eccen1) skewness(eccen1) kurtosis(eccen1) ];
          
            P_pores = [ P_pores ; mean(pores1) var(pores1) skewness(pores1) kurtosis(pores1) ];

            P_rnds = [ P_rnds ; mean(rnds1) var(rnds1) skewness(rnds1) kurtosis(rnds1) ];
       
            P_ttst = [ P_ttst ; mean(ttst1) var(ttst1) skewness(ttst1) kurtosis(ttst1) ];
        
            P_els = [ P_els ; mean(els1) var(els1) skewness(els1) kurtosis(els1) ];
         
            P_ornang = [ P_ornang ; mean(ornang1) var(ornang1) skewness(ornang1) kurtosis(ornang1) ];
             
            P_rctan = [ P_rctan ; mean(rctan1) var(rctan1) skewness(rctan1) kurtosis(rctan1) ];
            
            
            P_comp = [ P_comp ; mean(comp1) var(comp1) skewness(comp1) kurtosis(comp1) ];
            
            P_area = [ P_area ; mean(area1) var(area1) skewness(area1) kurtosis(area1) ];
               
            P_rc = [ P_rc ; mean(rc1) var(rc1) skewness(rc1) kurtosis(rc1) ];
           
            P_locvf = [ P_locvf ; mean(locvf1) var(locvf1) skewness(locvf1) kurtosis(locvf1) ];
           
            
            P_nbd = [ P_nbd ; mean(nbd1) var(nbd1) skewness(nbd1) kurtosis(nbd1) ];
           
            P_ncd = [ P_ncd ; mean(ncd1) var(ncd1) skewness(ncd1) kurtosis(ncd1) ];
           
            
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
save('raw_results_100.mat')

