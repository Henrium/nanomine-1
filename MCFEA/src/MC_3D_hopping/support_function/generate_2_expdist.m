%R=exp(E/kT_1), E>cut_E, R=[exp(E_cut/kT_1),1]
%R=exp(E_cut/kT1)*exp((E-E_cut)/kT_2), E<cut_E, R=[0,exp(E_cut/kT_1)]

%T_1>T_2
function E = generate_2_expdist(T_1,T_2,cut_E)

tic
% T_1=3060;
% T_2=375;
k=1.38e-23;
e=1.6e-19;
% cut_E=-1.33;% E>cut_E, exp; E<cut_E, linear



cut_R=T_2/T_1*exp(cut_E*e/k/T_1);

F=1-exp(cut_E*e/k/T_1)+cut_R;

E=zeros(500,500,100);
for i=1:1:500*500*100
    R=rand*(1-exp(cut_E*e/k/T_1)+cut_R);
    if R < cut_R
        E(i)=k*T_2*log(R/cut_R)/e + cut_E;       
    else
        E(i)=k*T_1*log(R+exp(cut_E*e/k/T_1)-cut_R)/e;
    end
    
end

% E1=E(:,:,1);
% E1=E1(:);
% figure;hist(E1,20);
toc
end

%==================================================================


   