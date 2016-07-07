function SVE_assemble2()
clear all;
path1 ='./imgs_folder/PP SiO2-O new/195/';
load(strcat(path1,'ch_result.mat'));
L_area = []; Stat_area = [];
L_comp = []; Stat_comp = [];
L_eccen = []; Stat_eccen = [];
L_els = []; Stat_els = [];
L_locvf = []; Stat_locvf = [];
L_nbd = []; Stat_nbd = [];
L_ncd = []; Stat_ncd = [];
L_ornang = []; Stat_ornang = [];
L_pores = []; Stat_pores = [];
L_rc = []; Stat_rc = [];
L_rctan = []; Stat_rctan = [];
L_rnds = []; Stat_rnds = [];
L_ttst = []; Stat_ttst = [];
L_intph0 = R_intph0; Stat_intph0 =[];
L_n = R_n; Stat_n = [];
L_vfs = R_vfs; Stat_vfs = [];

for i=1:num_img
    temp_area = R_area(i);
    L_area=[L_area;temp_area{1}];
    
    temp_comp = R_comp(i);
    L_comp=[L_comp;temp_comp{1}];
    
    temp_eccen = R_eccen(i);
    L_eccen = [L_eccen; temp_eccen{1}];
    
    temp_els = R_els(i);
    L_els = [L_els; temp_els{1}];
    
    temp_locvf = R_locvf(i);
    L_locvf = [L_locvf; temp_locvf{1}];
    
    temp_nbd = R_nbd(i);
    L_nbd = [L_nbd; temp_nbd{1}];
    
    temp_ncd = R_ncd(i);
    L_ncd = [L_ncd; temp_ncd{1}];
    
    temp_ornang = R_ornang(i);
    L_ornang = [L_ornang; temp_ornang{1}];
    
    temp_pores = R_pores(i);
    L_pores = [L_pores; temp_pores{1}];
    
    temp_rc = R_rc(i);
    L_rc = [L_rc; temp_rc{1}];
    
    temp_rctan = R_rctan(i);
    L_rctan = [L_rctan; temp_rctan{1}];
    
    temp_rnds = R_rnds(i);
    L_rnds = [L_rnds;temp_rnds{1}];
    
    temp_ttst = R_ttst(i);
    L_ttst = [L_ttst;temp_ttst{1}];
  
end
Stat_area = [mean(L_area), var(L_area), skewness(L_area), kurtosis(L_area)];
Stat_comp = [mean(L_comp), var(L_comp), skewness(L_comp), kurtosis(L_comp)];
Stat_eccen = [mean(L_eccen), var(L_eccen), skewness(L_eccen), kurtosis(L_eccen)];
Stat_els = [mean(L_els), var(L_els), skewness(L_els), kurtosis(L_els)];
Stat_locvf = [mean(L_locvf), var(L_locvf), skewness(L_locvf), kurtosis(L_locvf)];
Stat_nbd = [mean(L_nbd), var(L_nbd), skewness(L_nbd), kurtosis(L_nbd)];
Stat_ncd = [mean(L_ncd), var(L_ncd), skewness(L_ncd), kurtosis(L_ncd)];
Stat_ornang = [mean(L_ornang), var(L_ornang), skewness(L_ornang), kurtosis(L_ornang)];
Stat_pores = [mean(L_pores), var(L_pores),skewness(L_pores),kurtosis(L_pores)];
Stat_rc = [mean(L_rc), var(L_rc),skewness(L_rc),kurtosis(L_rc)];
Stat_rctan = [mean(L_rctan), var(L_rctan), skewness(L_rctan), kurtosis(L_rctan)];
Stat_rnds = [mean(L_rnds), var(L_rnds), skewness(L_rnds), kurtosis(L_rnds)];
Stat_ttst = [mean(L_ttst), var(L_ttst), skewness(L_ttst), kurtosis(L_ttst)];
Stat_intph0 = mean(L_intph0);
Stat_n = mean(L_n);
Stat_vfs = mean(L_vfs);
save(strcat(path1,'histogram.mat'),'Stat_area','Stat_comp','Stat_eccen','Stat_els','Stat_locvf',...
    'Stat_nbd','Stat_ncd','Stat_ornang','Stat_pores','Stat_rc','Stat_rctan','Stat_rnds','Stat_ttst','Stat_intph0','Stat_n','Stat_vfs');
outpath = strcat(path1,'data_info.mat');
save(strcat(outpath),'L_area','L_comp','L_eccen','L_els','L_locvf','L_nbd','L_ncd',...
    'L_ornang','L_pores','L_rc','L_rctan','L_rnds','L_ttst','R_intph0','R_n','R_vfs');
end