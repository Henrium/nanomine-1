%%%objective normalization
function [f]=normalization(C1,C2)
real=0;
Imag=0;
f1=(C1-real)/(max(C1)-real);
f2=(C2-Imag)/(max(C2)-Imag);
%% Consider the fitting of Imag part more essential 
w1=0.7;
w2=0.3;
f=w1*f1+w2*f2;
end