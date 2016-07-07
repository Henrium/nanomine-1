clear all;
close all;
load('results_april6.mat');
load('property.mat');
R_intph = (R_intph0+R_intph1)/2;

%% correlation based 
% P = [P_area', P_els', P_ncd', ...
%           P_ornang',  R_intph0', R_n', R_vfs'];
% 
%  descriptor = char('area1', 'area2','area3','area4',...
%                    'els1','els2','els3','els4',...
%                    'ncd1','ncd2','ncd3','ncd4',...
%                    'ornang1','ornang2','ornang3','ornang4',...
%                    'intph','n','vfs','I_2','I_3','I_4','I_5','I_6','I_7','I_8','I_9','I_11','I_12');

 P = [P_area', P_comp', P_eccen', P_els', P_locvf', P_nbd', P_ncd', ...
          P_ornang', P_pores', P_rc', P_rctan', P_rnds', P_ttst', R_intph0', R_n', R_vfs' ];
 descriptor = char('area1', 'area2','area3','area4','comp1','comp2','comp3','comp4',...
                   'eccen1','eccen2','eccen3','eccen4','els1','els2','els3','els4','locvf1','locvf2',...
                   'locvf3','locvf4','nbd1','nbd2','nbd3','nbd4','ncd1','ncd2','ncd3','ncd4',...
                   'ornang1','ornang2','ornang3','ornang4','pores1','pores2','pores3','pores4',...
                   'rc1','rc2','rc3','rc4','rctan1','rctan2','rctan3','rctan4','rnds1','rnds2','rnds3','rnds4',...
                   'ttst1','ttst2','ttst3','ttst4','intph0', 'n','vfs');
  
%  scale = ones(1,24);
%  scale(1:10) = scale(1:10)*0.464;
%  scale(11:20) = scale(11:20)*0.7123;
%  scale(21:22) = scale(21:22)*0.985;
%  scale(23:24) = scale(23:24)*1.2019;
scale = [0.464, 0.464, 0.464, 0.464, 0.464, 0.464, 0.464, 0.464, 0.7123, 0.7123, 0.7123, 0.7123, 0.7123,...
    0.464, 0.464, 0.464, 0.958, 0.958, 0.958, 0.958, 1.2019];
    

 K = 10;
 x0 = 0:1000;
 
 c1 = [];
 c2 = [];
 c3 = [];
 pts2 = [1:10:100, 100:100:1000];
 pts3 = 1:100;
 
 for i = 1:21
x1 = x0*scale(i);        
x2 = x1(pts2); 
x3 = x1(pts3);%rescale
 y1 = R_corrf(:,i);
 y2 = R_corrs(pts2,i);
 y3 = R_corrl(pts3,i);
 
 [xData1, yData1] = prepareCurveData(x1', y1);
 [xData2, yData2] = prepareCurveData(x2', y2);
 [xData3, yData3] = prepareCurveData(x3', y3);
 
 ft = fittype('exp2');
 opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
 opts.Display = 'Off';
 opts.StartPoint = [1 -0.1 0.1 -0.01];
 [fit1, gof1] = fit(xData1, yData1, ft, opts);
 [fit2, gof2] = fit(xData2, yData2, ft,opts);
 [fit3, gof3] = fit(xData3, yData3, ft, opts);
 c1 = [c1; coeffvalues(fit1)];
 c2 = [c2; coeffvalues(fit2)];
 c3 = [c3; coeffvalues(fit3)];
 end
 
 [r11, w11] = relieff(P, c1(:,1), K);
 [r12, w12] = relieff(P, c1(:,2), K);
 [r13, w13] = relieff(P, c1(:,3), K);
 
 [r21, w21] = relieff(P, c2(:,1), K);
 [r22, w22] = relieff(P, c2(:,2), K);
 [r23, w23] = relieff(P, c2(:,3), K);
 
 [r31, w31] = relieff(P, c3(:,1), K);
 [r32, w32] = relieff(P, c3(:,2), K);
 [r33, w33] = relieff(P, c3(:,3), K);
 
 w11 = w11-min(w11); w12 = w12-min(w12); w13 = w13-min(w13);
 w21 = w21-min(w21); w22 = w22-min(w22); w23 = w23-min(w23);
 w31 = w31-min(w31); w32 = w32-min(w32); w33 = w33-min(w33);
 
w_corrf = mean([w11'/sum(w11), w12'/sum(w12), w13'/sum(w13)],2);
w_corrs = mean([w21'/sum(w21), w22'/sum(w22), w23'/sum(w23)],2);
w_corrl = mean([w31'/sum(w31), w32'/sum(w32), w33'/sum(w33)],2);
w = (w_corrf + w_corrs + w_corrl)/3;

[w_corrf_sorted, rank_corrf] = sort(w_corrf, 'descend');
[w_corrs_sorted, rank_corrs] = sort(w_corrs, 'descend');
[w_corrl_sorted, rank_corrl] = sort(w_corrl, 'descend');
[w_sorted, rank] = sort(w, 'descend');

figure(1);
bar(w);
figure(2);
bar([w_corrf, w_corrs, w_corrl]);

%% property based
 PP = P([1:10,12:24],:);
[r_p1, w_p1] = relieff(PP, property1, K);% property1 is the maxmun value epsilon''/epsilon'
[r_p2, w_p2] = relieff(PP, property2, K);% property2 is the value at low frequency
w_p1 = (w_p1-min(w_p1))/sum(w_p1-min(w_p1));
w_p2 = (w_p2-min(w_p2))/sum(w_p2-min(w_p2));
w_p = (w_p1+w_p2)/2;
[w_p1_sorted, rank_p1] = sort(w_p1, 'descend');
[w_p2_sorted, rank_p2] = sort(w_p2, 'descend');
[w_p_sorted, rank_p] = sort(w_p, 'descend');
figure(3);
bar([w_p1', w_p2']);
figure(4);
bar(w_p);
 