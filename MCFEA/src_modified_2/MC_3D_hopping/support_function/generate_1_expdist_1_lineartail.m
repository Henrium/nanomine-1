%R=exp(E/kT_1), E>cut_E, R=[exp(E_cut/kT_1),1]
%R=exp(E_cut/kT1)*(E-E_min)/(E_cut-E_min), E<cut_E, R=[0,exp(E_cut/kT_1)]


%==================================================================
function E = generate_1_expdist_1_lineartail(T_1,E_cut,E_min,lx,ly,lz)

tic
% T_1=3060;
% T_2=375;
k=1.38e-23;
e=1.6e-19;
% cut_E=-1.33;% E>cut_E, T=T_1; E<cut_E, T=T_2;



cut_R=exp(E_cut*e/k/T_1);


E=zeros(ly,lx,lz);
for i=1:1:lx*ly*lz
    R=rand;
    if R < cut_R
        E(i)=R/cut_R*(E_cut-E_min)+E_min;   
    else
        E(i)=k*T_1*log(R)/e;
    end
    
end

E1=E(:,:,1);
E1=E1(:);
figure;hist(E1,20);
toc
end



   