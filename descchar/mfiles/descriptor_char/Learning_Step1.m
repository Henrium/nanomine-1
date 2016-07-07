% Statistical Learning Step 1: the relation between characteristics
load Reorganized_Cdata_all

ALLDATA = [ P_area; P_comp; P_eccen; P_els; P_intph0; P_intph1; P_locvf; P_n; P_ornang; P_pores; P_rc; P_rctan; P_rnds; P_ttst; P_vfs; R_mori(2:12, :); P_nbd; P_ncd ];

Names = { 'area1' 'area2' 'area3' 'area4' ...
    'comp1' 'comp2' 'comp3' 'comp4' ...
    'eccen1' 'eccen2' 'eccen3' 'eccen4' ...
    'els1' 'els2' 'els3' 'els4' ...
    'inph0' ...
    'inph1' ...
    'locvf1' 'locvf2' 'locvf3' 'locvf4' ...
    'n' ...
    'ornang1' 'ornang2' 'ornang3' 'ornang4' ...
    'pores1' 'pores2' 'pores3' 'pores4' ...
    'rc1' 'rc2' 'rc3' 'rc4' ...
    'rctan1' 'rctan2' 'rctan3' 'rctan4' ...
    'rnds1' 'rnds2' 'rnds3' 'rnds4' ...
    'ttst1' 'ttst2' 'ttst3' 'ttst4' ...
    'vfs' ...
    'mori1' 'mori2' 'mori3' 'mori4' 'mori5' 'mori6' 'mori7' 'mori8' 'mori9' 'mori10' 'mori11' ...
    'nbd1' 'nbd2' 'nbd3' 'nbd4' ...
    'ncd1' 'ncd2' 'ncd3' 'ncd4' ...
    };

inside_size = [ 4; 4; 4; 4; 1; 1; 4; 1; 4; 4; 4; 4; 4; 4; 1; 11; 4; 4 ];
NO = [];
for ii = 1:1:18
    NO = [ NO, sum( inside_size(1:ii) ) ];
end

L = size(ALLDATA,1);

RHOs = zeros(L,5);  % Each row is one pair. Colume 1~3: corr, Kendall's tau, Spearman's rank

% List
cnt = 1;
for ii = 1:1:(L-1)
    
    for jj = (ii+1):1:L
        
        d1 = ALLDATA(ii,:);  d1 = d1(:);
        d2 = ALLDATA(jj,:);  d2 = d2(:);
        
        RHOs(cnt, 1) = ii;
        RHOs(cnt, 2) = jj;
        
        RHOs(cnt, 3) = corr(d1, d2, 'type', 'Pearson');
        RHOs(cnt, 4) = corr(d1, d2, 'type', 'Kendall');
        RHOs(cnt, 5) = corr(d1, d2, 'type', 'Spearman');
        cnt = cnt + 1;
        
    end
    
end

% LxL matrix of correlations
RCM = [];  % Rank correlation matrix
for ii = 1:1:L
    for jj = 1:1:L
        d1 = ALLDATA(ii,:);  d1 = d1(:);
        d2 = ALLDATA(jj,:);  d2 = d2(:);
        RCM(ii,jj) = corr(d1, d2, 'type', 'Kendall');
    end
end
order1 = symrcm(RCM);  % the rearranged order. Using Cuthill-McKee algorithm
order2 = symrcm( abs(RCM) );
RCMn1 = RCM(order1, order1);  % It is the diagnal block matrix
RCMn2 = RCM(order2, order2);

reorder_names = {};
for ii = 1:1:length(Names)
    cnt = order1(ii);
    reorder_names{ii} = Names{cnt}; 
end

% Post 1: Using threshold for identifying correlated blocks
CBh = ( RCMn1 >= 0.90 | RCMn1 <= -0.90 );
CBl = ( RCMn1 <= 0.20 & RCMn1 >= -0.20 );
map = ones(L,L);
map = map + CBh;
map = map - CBl;
figure('color',[1,1,1]);
surf(map);
axis equal
view([0,0,-1])


% Post 2: Using threshold for identifying correlated pairs
indi1 = find( RHOs(:,3) >= 0.90 | RHOs(:,3) <= -0.90 );
indi2 = find( RHOs(:,4) >= 0.90 | RHOs(:,4) <= -0.90 );
indi3 = find( RHOs(:,5) >= 0.90 | RHOs(:,5) <= -0.90 );

RHO_nolist = [];
name_list = [];
for ii = 1:1:length(indi2)
    
    no = indi2(ii);
    
    no1 = RHOs(no,1);
    no2 = RHOs(no,2);
    
    name_list = [ name_list, Names{no1} '_' Names{no2} '|||'  ];
    RHO_nolist = [ RHO_nolist; no1, no2 ];
    
%     figure('color',[1,1,1])
%     plot( ALLDATA(no1,:), ALLDATA(no2,:) ,'.')
    
end


% plot( ALLDATA(1,:), ALLDATA(2,:) ,'.')