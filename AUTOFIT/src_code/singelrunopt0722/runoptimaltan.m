%% Characterize the error between the optimization and experiment and run kriging to output the
%%optimimal shiftign factors 
%%For my windows machine 
clear all
close all
%%Input all the experiemental data
expath='C:\Users\WYX\Google Drive\reserach\dielectric project\sfoptimization\2D_permittivity_Aug6_2015\expt_epoxy_DS\';
samplename='anthracene_PGMA_2wt%-YH.csv';
exfilename=[expath,samplename];
ex=xlsread(exfilename,'D1:D46');

%% choose the error characterization method 1-Geers   2-MSE
cat=1;

% %%characterize the error 
% Imagerr=Imagdif(eximag,cat);   %%calculate the Iamg err 
% fprintf('Finishing calculating the error from Imag part\n')
% realerr=realdiffernece(exreal,cat); %%calculate the real err
% fprintf('Finishing calculating the error from real part\n')
tanerr=tandif(ex,cat);

%%Objective norm
%f=normalization(realerr,Imagerr);
f=tanerr;
%% fit kriging model and predict the optimal shifting factors  
fprintf('Start to fit kriging model and predict the optimal shifting factos\n')
range=1;    %% select the domain of shifting factors 1-small 2-big
[x1,x2,x3,x4,x5,model1]=runkriging(f);
% x0=[0.8 1.95 0.18 2 0.74];
A=[];
b=[];
beq = [];
Aeq=[];
if range==1
lb=[0.4 1.5 0 0.7 0.3];
ub=[1 3 0.2 2 2.5];
else
lb=[0 0.5 0 0.5 0.3];
ub=[2 3.5 2 3.5 2.5];
end
options = optimset('Display','iter', ...
    'MaxFunEvals', 2000 , ...
    'LargeScale', 'off', ...
   'TolCon', .0001, ...
   'TolX', .0001);

for i=1:100
x0= unifrnd(lb,ub);
[xout,fval] = fmincon(@myfun,x0,A,b,Aeq,beq,lb,ub,[],options);
if i == 1
    x_record = xout;
    f_record = fval;
else
    if fval<f_record
        x_record = xout;
        f_record = fval;
    end
end
end