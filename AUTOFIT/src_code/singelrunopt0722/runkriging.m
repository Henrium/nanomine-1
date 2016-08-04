function [model1]=runkriging(f)
% if range==1
x=importdata('small.txt');
%     a1=0.4;
%     a2=1;
%     b1=1.5;
%     b2=3;
%     c1=0;
%     c2=0.2;
%     d1=0.7;
%     d2=2;
%     e1=0.3;
%     e2=2.5;
% elseif range==2
%     x=importdata('big.txt');
%     a1=0;
%     a2=2;
%     b1=0.5;
%     b2=3.5;
%     c1=0;
%     c2=2;
%     d1=0.5;
%     d2=3.5;
%     e1=0.3;
%     e2=2.5;
% end
x_range=[0.4 1;1.5 3;0 0.2;0.7 2;0.3 2.5];
f=f';
model1 = krigms(x,f,x_range);
save('fit1.mat','model1');


% [x1,x2,x3,x4,x5]=ndgrid(0.4:0.1:1,1.5:0.1:3,0:0.1:0.2,0.7:0.1:2,0.3:0.1:2.5);
% [a,b,c,d,e]=size(x1);
% for i=1:a
%     for j=1:b
%         for k=1:c
%             for m=1:d
%                 for n=1:e
%                  [yp(i, j,k,m,n), varp(i, j,k,m,n)] = krigpred(model1, [x1(i, j,k,m,n) x2(i, j,k,m,n) x3(i, j,k,m,n) x4(i, j,k,m,n) x5(i, j,k,m,n)]); 
%                      end;end;end;end;end;
%  [m1,m2]=min(yp(:));
%  d5=ceil(m2/(a*b*c*d));
%  d4=ceil((m2-(d5-1)*a*b*c*d)/(a*b*c));
%  d3=ceil((m2-(d5-1)*a*b*c*d-(d4-1)*a*b*c)/(a*b));
%  d2=ceil((m2-(d5-1)*a*b*c*d-(d4-1)*a*b*c-(d3-1)*a*b)/a);    
%  d1=m2-(d5-1)*a*b*c*d-(d4-1)*a*b*c-(d3-1)*a*b-(d2-1)*a;


% x10=x1(d1,d2,d3,d4,d5);
% x20=x2(d1,d2,d3,d4,d5);
% x30=x3(d1,d2,d3,d4,d5); 
% x40=x4(d1,d2,d3,d4,d5);
% x50=x5(d1,d2,d3,d4,d5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% yp0=100;
% for x1=0.4:0.1:1
%     for x2=1.5:0.1:3
%         for x3=0:0.1:0.2
%             for x4=0.7:0.1:2
%                 for x5=0.3:0.1:2.5
%                     yp1=krigpred(model1,[x1 x2 x3 x4 x5]);
%                     if yp1<yp0
%                         yp0=yp1;
%                         x10=x1; x20=x2; x30=x3; x40=x4; x50=x5;
%                     end
%                 end
%             end
%         end
%     end
% end
end
