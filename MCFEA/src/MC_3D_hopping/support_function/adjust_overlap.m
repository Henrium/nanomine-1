function new_np_coord = adjust_overlap(np_coord,min_d,matrix_size)
global FillerRadius D_int1 D_int2
% change addy, addz sequence
% adjust overlap degree

tic
%input: np_coord = n*3 matrix, sub_coordinates, min_d: minimum distance
m = size(np_coord,1); %number of rows
D = pdist(np_coord); % m(m-1)/2 array; m-1,m-2, m-3,.....1;
difference = 0; %10 is good for 100 filler
index_d = find(D<min_d|abs(D-2*(FillerRadius+D_int1+D_int2))<difference); %find the index of the element in d < min_d;
r = 0.01;
% now we need to correlated teh index_d with index_np

% construct a reference table record the sum of all integers from 1 to i
table = zeros(m-1,1);
table(m-1) = m-1;
for i= m-2:-1:1;
    table(i) = table(i+1) + i;
end
table = sort(table);


disp(['need to adjust ',num2str(length(index_d)),' coordinates']);

for i=1:1:length(index_d)
    index_np = find(table >= index_d(i),1);% index of the table elements that are greater than index_x(i);locate the position of the NP
    if ~isempty(index_np)
        conflict = 1;
        while conflict == 1
            for addx = [0:-r*min_d:-min_d,1:r*min_d:min_d]
                if conflict == 0
                    break
                end
                for addy = [0:-r*min_d:-min_d,1:r*min_d:min_d]
                    if conflict == 0
                        break
                    end
                    for addz = [0:-r*min_d:-min_d,1:r*min_d:min_d]
                        rand_index = randperm(3);
                        add = [addy,addx,addz];
                        np_coord(index_np,:) = np_coord(index_np,:)+[add(rand_index(1)),add(rand_index(2)),add(rand_index(3))];
                        np_coord(index_np,:) = PBC(np_coord(index_np,:),matrix_size);
                        for j = 1:m
                            dd(j) = pdist([np_coord(index_np,:);np_coord(j,:)]);
                        end 
                        dd(index_np) = [];% remove the pdist with itself
                        %assignin('base','dd',dd);
                        %disp(num2str(min(dd)));
                        if min(dd) >= min_d && ~any(abs(dd-2*(FillerRadius+D_int1+D_int2))<difference)
                            conflict = 0;
                            disp(['position adjusted',num2str(i)])
                            break
                        end
                    end
                end
            end
        end
    end
end
                            
new_np_coord = np_coord;                       
disp(['minimum distance is ',num2str(min(pdist(new_np_coord)))]);                    
toc                   

end

