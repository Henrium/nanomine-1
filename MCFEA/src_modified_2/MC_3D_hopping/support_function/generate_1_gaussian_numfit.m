function E = generate_1_gaussian_numfit(T,E_cut,E_1,a_1,E_2,a_2,E_3,a_3,lx,ly,lz,plot_on)

tic

k=1.38e-23;
e=1.6e-19;
cut_R=(1+erf(E_cut/k/sqrt(2)*e/T));

E=zeros(ly,lx,lz);
for i=1:1:lx*ly*lz
    R=rand;

    if R <= a_3*cut_R
            E(i)= E_3;
    elseif R > a_3*cut_R && R <= (a_3+a_2)*cut_R
            E(i)= E_2;
    elseif R > (a_3+a_2)*cut_R && R <= (a_3+a_2+a_1)*cut_R
            E(i)= E_1;
    else 
    E(i) = erfinv(R-1)*k*T*sqrt(2)/e;
    end
    
end

if plot_on == 1
E1=E(:);

figure;hist(E1,20);
end

toc
end