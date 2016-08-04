%%genrate artificial shifting factors 
n=20; %%define the sets of shifting factors supposed to generate
lb=[0.4 1.5 0 0.7 0.3];
ub=[1 3 0.2 2 2.5];
sample=rand(n,5);
for i=1:5
    sample(:,i)=(ub(i)-lb(i))*sample(:,i)+lb(i);
end
save('art_shifting','sample')