function [Delta_F,new_potential]=update_F_continj_3D(field,potential,e_x,lx,ly,lz)

% combine into 1D poisson's equaiton

e_x=[1;sort(e_x);lx];
new_field=field;
new_potential=zeros(ly,lx,lz);
s=size(e_x,1);

for i=1:1:s-1
    new_field(:,e_x(i):e_x(i+1),:)=field(:,e_x(i):e_x(i+1),:)/(s-2)*(i-1);
end

Delta_V=sum(new_field(1,:,1))/1e9-potential(1,1,1);
Delta_F=-Delta_V/(lx*1e-9);
new_field=new_field+Delta_F;

for j=1:1:lx
    
    new_potential(:,lx-j,:)=new_potential(:,lx-j+1,:)+new_field(:,lx-j+1,:)/1e9;

end
end
