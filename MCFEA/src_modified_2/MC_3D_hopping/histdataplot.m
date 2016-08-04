function histdataplot(data,xcenter)

%xcenter=[100:100:1500];
%x3 = [t1....;t2.....]

for i=1:1:size(data,2)
    histdata(i,:)=hist(data(:,i),xcenter)/size(data,1);
end

histdata(histdata==0)=NaN;
figure;

color=hsv(size(data,2));

hold on;

for i=1:1:9
    plot(xcenter,histdata(i,:),'color',color(i,:))
    xlabel('nm')
    ylabel('count');
end
end
