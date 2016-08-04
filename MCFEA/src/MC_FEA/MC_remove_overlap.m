function new_np_coord = MC_remove_overlap(np_coord,min_d)
%input: np_coord = n*3 matrix, sub_coordinates, min_d: minimum distance
m = size(np_coord,1); %number of rows
d = pdist(np_coord); % m(m-1)/2 array; m-1,m-2, m-3,.....1;
index_d = find(d < (min_d-0.001)); %find the index of the element in d < min_d;

% now we need to correlated teh index_d with index_np

% construct a reference table record the sum of all integers from 1 to i
table = zeros(m-1,1);
table(m-1) = m-1;
for i= m-2:-1:1;
    table(i) = table(i+1) + i;
end
table = sort(table);

index_np = zeros(length(np_coord),1);

for i=1:1:length(index_d)
    index_np(i) = find(table >= index_d(i),1);% index of the table elements that are greater than index_x(i);locate the position of the NP
end

index_np(~any(index_np,2), : ) = [];%rows

new_np_coord = np_coord;

if ~isempty(index_np)
    new_np_coord(index_np,:)=[];%remove the overlap NP
    disp([num2str(length(index_np)),' NP overlap removed']);
end 

end


    