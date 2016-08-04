
%% Calculating the difference of imag permitivity between DOE and experiment 
ex=xlsread('monothiophene-PGMA_2wt%-YH.csv','B1:B46');

filename = ['CompPermReal.csv'];
doe=xlsread(filename,'B1:B46');
exsum=sum(ex.*ex);
doesum=sum(doe.*doe);
b=sum(doe.*ex);
M=sqrt(doesum/exsum)-1;     %% magnitude of the error
P=1-b/sqrt(doesum*exsum);   %% phase error
C=sqrt((M)^2+(P)^2); %% comprehensive error


