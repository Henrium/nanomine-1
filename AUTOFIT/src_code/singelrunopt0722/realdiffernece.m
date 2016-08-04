%% Calculating the difference of real permitivity between DOE and experiment 
function [C1]=realdiffernece(ex,cat) 

n=1;
for i=1:50
   % if i<37
filename = ['../DOE50/DOE_run_',num2str(i),'_CompPermReal.csv'];
   % else --/    
       % filename = ['../HZ_2D_comsolbuild_AC_binary_12-Jan-2016_IP10+50_run_',num2str(i),'_CompPermReal.csv'];
   % end
doe=csvread(filename,0,1,[0,1,45,1]);
if cat==1
    exsum=sum(ex.*ex);
    doesum=sum(doe.*doe);
    b=sum(doe.*ex);
    M1(n)=sqrt(doesum/exsum)-1;     %% magnitude of the error
    P1(n)=1-b/sqrt(doesum*exsum);   %% phase error
    C1(n)=sqrt((M1(n))^2+(P1(n))^2); %% comprehensive error
elseif cat==2
    e1=doe-ex;
    e2=sum(e1.*e1)/length(e1);
    C1(n)=e2;
end
n=n+1;

end
end


