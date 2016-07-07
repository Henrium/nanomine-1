function E = generate_1_expdist_2_lineartail(T_1,E_cut,E_min_1,E_min_2,ratio,lx,ly,lz)

tic
% T_1=3060;
% T_2=375;
k=1.38e-23;
e=1.6e-19;
% cut_E=-1.33;% E>cut_E, T=T_1; E<cut_E, T=T_2;

%ratio of two linear, ratio=#(E_min_1-E_min_2)/#(E_min_cut-E_min_1)

cut_R=exp(E_cut*e/k/T_1);


E=zeros(ly,lx,lz);
for i=1:1:lx*ly*lz
    R=rand;
    if R <= ratio*cut_R
        E(i)=R/(ratio*cut_R)*(E_min_1-E_min_2)+E_min_2;   
    elseif R > ratio*cut_R && R <= cut_R
            E(i)= (R-ratio*cut_R)/((1-ratio)*cut_R)*(E_cut-E_min_1)+E_min_1;
    else
        E(i)=k*T_1*log(R)/e;
    end
    
end
size(E)
E1=E(:);
figure;hist(E1,20);
toc
end