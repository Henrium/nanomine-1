x0=[0.5 1.6 0.1 0.9 1.0];
A=[];
b=[];
beq = [];
Aeq=[];
lb=[0.4 1.5 0 0.7 0.3];
ub=[1 3 0.2 2 2.5];
[x,fval] = fmincon(@myfun,x0,A,b,Aeq,beq,lb,ub);
