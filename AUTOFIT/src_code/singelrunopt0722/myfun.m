function f = myfun(x)
load fit1.mat
f=krigpred(model1,[x(1) x(2) x(3) x(4) x(5)]);
end