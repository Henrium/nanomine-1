%R=exp(E/kT_1), E>cut_E, R=[exp(E_cut/kT_1),1]
%R=exp(E_cut/kT1)*(E-E_min)/(E_cut-E_min), E<cut_E, R=[0,exp(E_cut/kT_1)]


%==================================================================
function E = generate_1_expdist(T_1,lx,ly,lz)

tic

k=1.38e-23;
e=1.6e-19;


E = zeros(ly,lx,lz);

for i=1:1:lx*ly*lz
    R=rand;
    E(i)=k*T_1*log(R)/e;
end

toc
end
