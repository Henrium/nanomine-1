function [new_coord,change] = PBC(coord,size1)

% convert periodic condition
% coord: the coord of NP [x,y,z]
% size1:[lx,ly,lz]

coord0 = coord;
for i=1:length(coord)

        while coord(i) > size1(i)
            coord(i) = coord(i) - size1(i);
        end
        
        while coord(i) <= 0
            coord(i) = coord(i) + size1(i);
        end

end


if nargout == 2
    if isequal(coord0,coord)
        change = false;
    else change = true;
    end
end


new_coord = coord;

end

    