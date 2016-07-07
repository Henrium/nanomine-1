dir = '/home/ideal/matlab_work/Statistical Learning/';

% ------------------- The list of characteristics -------------------------
R_nbd = {};         P_nbd = [];
R_ncd = {};         P_ncd = [];
% -------------------------------------------------------------------------

% _v means the variance of the descriptor values

for count = 1:2:56 % 1:1:19     1:1:1 FOR DEBUG, 1:11 for Goodyear sample
        
        disp(count)
    
        load(['sampleno' num2str(count) '.mat']);
        Bimg1 = image;
        clear image

        load(['sampleno' num2str(count+1) '.mat']);
        Bimg2 = image;
        clear image

        nbd1 = nearest_distance(Bimg1);
        nbd2 = nearest_distance(Bimg2);

        [~, ~, ncd1] = nearest_center_distance(Bimg1);
        [~, ~, ncd2] = nearest_center_distance(Bimg2);

        % Write into the Record_matrix

        R_nbd{count} = nbd1;        R_nbd{count+1} = nbd2;
        R_ncd{count} = ncd1;        R_ncd{count+1} = ncd2;

        % Parameterization: [ mean, variance, skewness, kurtosis ]
        P_nbd = [ P_nbd ; mean(nbd1) var(nbd1) skewness(nbd1) kurtosis(nbd1) ];
        P_nbd = [ P_nbd ; mean(nbd2) var(nbd2) skewness(nbd2) kurtosis(nbd2) ];

        P_ncd = [ P_ncd ; mean(ncd1) var(ncd1) skewness(ncd1) kurtosis(ncd1) ];
        P_ncd = [ P_ncd ; mean(ncd2) var(ncd2) skewness(ncd2) kurtosis(ncd2) ];

    
end
P_nbd = P_nbd';
P_ncd = P_ncd';



%%
upp = [];

low = [];

for ii = 1:1:56
    
    data = R_els{ii};
    upp = [ upp; max(data) ];
    low = [ low; min(data) ];
    
end





