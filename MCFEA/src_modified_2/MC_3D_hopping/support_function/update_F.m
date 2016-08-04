function new_potential=update_F(field,potential,e_x,L)

e_x=[1;sort(e_x);1000*L];
new_field=field;
new_potential=zeros(1000,1000*L);
s=size(e_x,1);

for i=1:1:s-1
    new_field(:,e_x(i):e_x(i+1))=field(:,e_x(i):e_x(i+1))/(s-2)*(i-1);
end

Delta_V=sum(new_field(1,:))/1e9-potential(1,1);
Delta_F=-Delta_V/(1e-6*L);
new_field=new_field+Delta_F;

for j=1:1:1000*L-1
    
    new_potential(:,1000*L-j)=new_potential(:,1000*L-j+1)+new_field(:,1000*L-j+1)/1e9;

end
end
