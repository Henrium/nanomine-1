% Generate a density of states (DOS) function with a Gaussinan shape
% generate_1_gaussian E = generate_1_gaussian(T,lx,ly,lz)
% P = 2/(sigma*sqrt(2pi))*exp(-E^2/sigam^2)
% E has the size of [ly, lx, lz].
% sigma = kT

function E = generate_1_gaussian(T,lx,ly,lz)

tic
% T_1=3060;
% T_2=375;
k=1.38e-23;
e=1.6e-19;
% cut_E=-1.33;% E>cut_E, T=T_1; E<cut_E, T=T_2;

E=zeros(ly,lx,lz);
for i=1:1:lx*ly*lz
    R=rand;
    E(i) = erfinv(R-1)*k*T*sqrt(2)/e;
end

toc
end