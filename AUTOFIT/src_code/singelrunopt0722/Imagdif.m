
%% Calculating the difference of imag permitivity between DOE and experiment 
function [C2]=Imagdif(ex,cat) 
[M,n1]=min(ex);
ex0=ex(n1:length(ex),1);
[M,n2]=max(ex0);
n2=n1+n2;
r1=n1-4;
r2=n1+4;
r3=n2-4;
r4=n2+4;
for i=1:50
    %if i<37
filename = ['../DOE50/DOE_run_',num2str(i),'_CompPermImag.csv'];
   % else 
      %  filename = ['../HZ_2D_comsolbuild_AC_binary_12-Jan-2016_IP10+50_run_',num2str(i),'_CompPermImag.csv'];
   % end
doe=csvread(filename,0,1,[0,1,45,1]);
if cat==1
%     exsum=sum(ex.*ex);
%     doesum=sum(doe.*doe);
%     b=sum(doe.*ex);
%     M2(n)=sqrt(doesum/exsum)-1;     %% magnitude of the error
%     P2(n)=1-b/sqrt(doesum*exsum);   %% phase error
%     C2(n)=sqrt((M2(n))^2+(P2(n))^2); %% comprehensive errorcwd=pwd;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

doe1=[doe(r1:r2);doe(r3:r4)];
doe21=doe(1:(r1-1));
doe22=doe((r2+1):(r3-1));
doe23=doe((r4+1):length(ex));
doe2 =[doe21;doe22;doe23];
exsum=sum(ex.*ex);
doesum=1.95*sum(doe1.*doe1)+0.4*sum(doe2.*doe2);
b=sum(doe.*ex);
M2(i)=sqrt(doesum/exsum)-1;     %% magnitude of the error
P2(i)=1-b/sqrt(doesum*exsum);   %% phase error
C2(i)=sqrt((M2(i))^2+(P2(i))^2); %% comprehensive errorcwd=pwd;




elseif cat==2
%      e1=doe-ex;
%     e2=sum(e1.*e1)/length(e1);
%     C2(n)=e2;
doe1=[doe(r1:r2);doe(r3:r4)];
doe21=doe(1:(r1-1));
doe22=doe((r2+1):(r3-1));
doe23=doe((r4+1):length(ex));
doe2 =[doe21;doe22;doe23];
ex1=[ex(r1:r2);ex(r3:r4)];
ex21=ex(1:(r1-1));
ex22=ex((r2+1):(r3-1));
ex23=ex((r4+1):length(ex));
ex2=[ex21;ex22;ex23];
e1=doe1-ex1;
e2=doe2-ex2;
n1=length(e1);
n2=length(e2);
weight=2;
a1=length(ex)/(weight*n1+n2);
e2=(2*a1*sum(e1.*e1)+a1*sum(e2.*e2))/length(e1);
C2(i)=e2;



end

end
end