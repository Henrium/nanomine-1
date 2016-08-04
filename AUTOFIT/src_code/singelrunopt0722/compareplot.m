clear 
close all
%% compare the predicted shifting factors with real experimental data 
n=20; %% sets of data to compare 
realmatch=[];
Imagmatch=[];

path=['../DOE50/']; % path need to change
realfile=['_CompPermReal.csv'];
Imagfile=['_CompPermImag.csv'];
expsample1=[path,'sample_run_1',realfile];
expsample2=[path,'sample_run_1',Imagfile];
valisample1=[path,'DOE_run_10',realfile];
valisample2=[path,'DOE_run_10',Imagfile];
ex1=csvread(expsample1);
ex2=csvread(expsample2);
vali1=csvread(valisample1);
vali2=csvread(valisample2);
figure
semilogx(ex1(:,1),ex1(:,2));
hold on
h1=semilogx(vali1(:,1),vali1(:,2));
legend('experiement','predicted');
filename1=[path,'comparereal',num2str(i),'.png'];
saveas(h1,filename1);
figure
semilogx(ex2(:,1),ex2(:,2));
hold on
h2=semilogx(vali2(:,1),vali2(:,2));
legend('experiement','predicted');
filename2=[path,'compareImag',num2str(i),'.png'];
saveas(h2,filename2);

%% characterize the error for each test
%characterize the real error 
e1=vali1(:,2)-ex1(:,2);  
e1sum=sum(e1.*e1)/length(e1);
C1(i)=e1sum;
if C1(i)<=0.005
    realmatch=[realmatch,i];
end

e2=vali2(:,2)-ex2(:,2);  
e2sum=sum(e2.*e2)/length(e2);
C2(i)=e2sum;
if C2(i)<=2e-4
    Imagmatch=[Imagmatch,i];
end
n1=length(realmatch);
n2=length(Imagmatch);



    