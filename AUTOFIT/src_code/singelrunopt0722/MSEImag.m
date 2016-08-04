%% Calculating the difference of imag permitivity between DOE and experiment using MSE 
ex=xlsread('monothiophene-PGMA_2wt%-YH.csv','C1:C46');
n=1
for i=51:100
filename = ['HZ_2D_comsolbuild_AC_binary_07-Dec-2015_IP10+50_run_',num2str(i),'_CompPermImag.csv'];
doe=xlsread(filename,'B1:B46');
e1=doe-ex;
e2=sum(e1.*e1)/length(e1);
MSE2(n)=e2;

n=n+1

end