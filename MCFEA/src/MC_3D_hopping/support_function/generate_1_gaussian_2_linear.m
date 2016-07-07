function E = generate_1_gaussian_2_linear(T,E_cut,E_min_1,E_min_2,ratio,lx,ly,lz,plot_on)

tic

k=1.38e-23;
e=1.6e-19;
cut_R=(1+erf(E_cut/k/sqrt(2)*e/T));

E=zeros(ly,lx,lz);
for i=1:1:lx*ly*lz
    R=rand;

    if R <= ratio*cut_R
            E(i)= R/(ratio*cut_R)*(E_min_1-E_min_2)+E_min_2;   
    elseif R > ratio*cut_R && R <= cut_R
            E(i)= (R-ratio*cut_R)/((1-ratio)*cut_R)*(E_cut-E_min_1)+E_min_1;
    else 
    %R = 1-(1-R)/(1-cut_R)*(1-cut_R/10);
    E(i) = erfinv(R-1)*k*T*sqrt(2)/e;
    end
    
end

if plot_on == 1
E1=E(:);

figure;hist(E1,20);
end

toc
end