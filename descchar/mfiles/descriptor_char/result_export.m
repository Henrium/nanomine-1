clear all;
load('./1119/results_Nov19.mat');
all_rank = descriptor(rank_corrf,:);
output={};
for i = 1 : 55
    w='';
    for j = 1 : 7
        w=strcat(w,all_rank(i,j));
    end
    output{i}=w;
end
fid = fopen('./1119/rank.csv','w');
for row=1:55
    fprintf(fid,'%s%d\n',strcat(output{row},','),w_corrf_sorted(row));
end
fclose(fid);

