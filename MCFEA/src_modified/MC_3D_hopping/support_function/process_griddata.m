% function is used to map out all coorindates within one NP from the center
% position, with the grid lattic as 1 nm. 

% input
% core_coord: sub coord of NP center, with dimension as [lx, ly, lz]
% r: radius of np
% lx, ly, lz : box size
% NP_cell:  the cell struture recording the cluster information

% output
% linear_coord: the linear index of the coord to the matrix of [ly,lx,lz]
% clusterCell: the cell structure with completed cluster coordinates along
% each boundaries. Each cell contain one cluser.



function [linear_coord,clusterCell] = process_griddata(core_coord,r,lx,ly,lz,NP_cell)

narginchk(5,6);


tic

r_0 = fix(r)+1;


volume = round(3.3*2.5^3*3/4); % how many point of NP occupy

np_coord = zeros(volume,3);
kk=1;

for ii=1:1:size(core_coord,1)
    for dx = -r_0:1:r_0;
        for dy = -r_0:1:r_0;
            for dz = -r_0:1:r_0;
                if dx^2 + dy^2 + dz^2 <= r^2
                    
                    coord = core_coord(ii,1:3) + [dx,dy,dz];
                    
                    coord = PBC(coord,[lx,ly,lz]);
                    
                    np_coord(kk,1:3) = coord;
                    kk = kk + 1;
                end
            end
        end
    end
end



np_coord(~any(np_coord,2),:) = []; %trim zero row
np_coord = unique(np_coord,'rows');

np_coord = round(np_coord);

np_coord(np_coord(:,1)>lx | np_coord(:,1)<1,:)=[];
np_coord(np_coord(:,2)>ly | np_coord(:,2)<1,:)=[];
np_coord(np_coord(:,3)>lz | np_coord(:,3)<1,:)=[];


linear_coord = zeros(size(np_coord,1),1);

% set x dimension in the middle volume
for pp = 1:1:size(np_coord,1)
    linear_coord(pp) = sub2ind([ly,lx,lz],np_coord(pp,2),np_coord(pp,1),np_coord(pp,3));
end



%% calculate the clusterized np_coord (only when requested
% the coord is not in periodic condition, the
% coordinates can exceed the box

if nargin == 6 && nargout == 2
    CellSize =  size(NP_cell);
    for iR = 1:CellSize(1)
        cluster_coord = [];
        for iC = 1:CellSize(2)
            if ~isempty(NP_cell{iR,iC})    
                for dx = -r_0:1:r_0,for dy = -r_0:1:r_0, for dz = -r_0:1:r_0,
                            if dx^2 + dy^2 + dz^2 <= r^2
                                coord = NP_cell{iR,iC} + [dx,dy,dz];
                                coord = PBC(coord,[lx,ly,lz]);
                                cluster_coord = [cluster_coord;coord];
                                cluster_coord = round(cluster_coord);
                            end
                end,end,end
            end
        end
        
        np_coord = cluster_coord;
        
        np_coord(np_coord(:,1)>lx | np_coord(:,1)<1,:)=[];
        np_coord(np_coord(:,2)>ly | np_coord(:,2)<1,:)=[];
        np_coord(np_coord(:,3)>lz | np_coord(:,3)<1,:)=[];
        
        np_coord = np_coord(:,[2,1 3]);
        box  = [ly,lx,lz];
        
        % add the complementary part adjacent to each boundary
        for k=1:3
            if any(box(k) - np_coord(:,k) <= 1) || any(np_coord(:,k) <= 1)
                np_coord_adj = [np_coord(:,k) + box(k);np_coord(:,k)-box(k)];
                
                dnp_coord = [np_coord;np_coord];
                if k==1, np_coord_adj = [np_coord_adj,dnp_coord(:,2),dnp_coord(:,3)];
                elseif k==2, np_coord_adj = [dnp_coord(:,1),np_coord_adj,dnp_coord(:,3)];
                elseif k==3, np_coord_adj = [dnp_coord(:,1),dnp_coord(:,2),np_coord_adj];
                end
                
                np_coord_adj(np_coord_adj(:,k) > 1.5*box(k) | np_coord_adj(:,k) < -0.5*box(k),:) = [];
                
                np_coord  = [np_coord;np_coord_adj];
            end
        end

        clusterCell{iR} = np_coord;
    end
end
        
   

disp(['finished generating NP grid coordinates, ','take ',num2str(toc),' secs']);


end








