%% Calculating the error from the tandelta 
function [C2]=tandif(ex,cat)

n=1;
for i=1:50
    if i<37
filename1 = ['../HZ_2D_comsolbuild_AC_binary_11-Jan-2016_IP10+50_run_',num2str(i),'_CompPermImag.csv'];
filename2 = ['../HZ_2D_comsolbuild_AC_binary_11-Jan-2016_IP10+50_run_',num2str(i),'_CompPermReal.csv'];
    else 
        filename1 = ['../HZ_2D_comsolbuild_AC_binary_12-Jan-2016_IP10+50_run_',num2str(i),'_CompPermImag.csv'];
        filename2 = ['../HZ_2D_comsolbuild_AC_binary_12-Jan-2016_IP10+50_run_',num2str(i),'_CompPermReal.csv'];
    end
doeimag=xlsread(filename1,'B1:B46');
doereal=xlsread(filename2,'B1:B46');
doe=doeimag./doereal;


if cat==1
%     exsum=sum(ex.*ex);
%     doesum=sum(doe.*doe);
%     b=sum(doe.*ex);
%     M2(n)=sqrt(doesum/exsum)-1;     %% magnitude of the error
%     P2(n)=1-b/sqrt(doesum*exsum);   %% phase error
%     C2(n)=sqrt((M2(n))^2+(P2(n))^2); %% comprehensive errorcwd=pwd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if i==1
[M,n1]=min(ex);
ex1=ex(n1:length(ex),1);
[M,n2]=max(ex1);
n2=n1+n2
r1=n1-4
r2=n1+4
r3=n2-4
r4=n2+4
end
%%adding additional weights for two parts (2nd peak and plato)
doe1=[doe(r1:r2);doe(r3:r4)];
doe21=doe(1:(r1-1));
doe22=doe((r2+1):(r3-1));
doe23=doe((r4+1):length(ex));
doe2 =[doe21;doe22;doe23];
exsum=sum(ex.*ex);
doesum=1.95*sum(doe1.*doe1)+0.39*sum(doe2.*doe2);
b=sum(doe.*ex);
M2(n)=sqrt(doesum/exsum)-1;     %% magnitude of the error
P2(n)=1-b/sqrt(doesum*exsum);   %% phase error
C2(n)=sqrt((M2(n))^2+(P2(n))^2); %% comprehensive errorcwd=pwd;

%%adding weights only to the 2nd peak 




elseif cat==2
    e1=doe-ex;
    e2=sum(e1.*e1)/length(e1);
    C2(n)=e2;
end
n=n+1;

end
end