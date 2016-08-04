clear 
close all
%% Characterize the error between the optimization and experiment and run kriging to output the
%%optimimal shiftign factors 
%%For my windows machine 

output=[];
fcord=[];

%%Input all the experiemental data
expath='../DOE50/';
Imagsample=['sample_run_1_CompPermImag.csv'];

Realsample=['sample_run_1_CompPermReal.csv'];

Imagfile=[expath,Imagsample];
Realfile=[expath,Realsample];
exreal=csvread(Realfile,0,1,[0,1,45,1]);
eximag=csvread(Imagfile,0,1,[0,1,45,1]);

%% choose the error characterization method 1-Geers   2-MSE
 cat=2;

%%characterize the error 
Imagerr=Imagdif(eximag,cat);   %%calculate the Iamg err 
fprintf('Finishing calculating the error from Imag part\n')
realerr=realdiffernece(exreal,cat); %%calculate the real err
fprintf('Finishing calculating the error from real part\n')

%%Objective norm
f=normalization(realerr,Imagerr);
fcord=[fcord;f];

%% fit kriging model and predict the optimal shifting factors  
fprintf('Start to fit kriging model and predict the optimal shifting factos\n')
range=1;    %% select the domain of shifting factors 1-small 2-big
[model1]=runkriging(f);
x0=[0.5 1.6 0.1 0.9 1.0];
A=[];
b=[];
beq = [];
Aeq=[];
lb=[0.4 1.5 0 0.7 0.3];
ub=[1 3 0.2 2 2.5];
options = optimset('Display','none', ...
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
output=[output;xout];

savefile=[expath,'validation'];
save(savefile,'output')
csvwrite('validation.csv', output)
% x=importdata('small.txt');
% x_range=[0.4 1;1.5 3;0 0.2;0.7 2;0.3 2.5];
% f=f';
% model1 = krigms(x,f,x_range);

