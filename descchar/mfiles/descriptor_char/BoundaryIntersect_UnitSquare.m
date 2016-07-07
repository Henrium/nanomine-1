function [xc, yc] = BoundaryIntersect_UnitSquare(P1, P2, Mode)

global LeftEdge RightEdge BtmEdge TopEdge

x1 = P1(:,1);
y1 = P1(:,2);
x2 = P2(:,1);
y2 = P2(:,2);

dx = x1 - x2;
dy = y1 - y2;

bNonsingular = (dx~=0);
bSingular    = ~bNonsingular;

switch Mode
    
    case 1
        % One point outside of square while the other inside
        
        % Non-singular case
        if (bNonsingular)    % Regular equation of line
            
            m = dy./dx;
            
            % Calculate square intersect
            yc1 = m.*(LeftEdge-x1) + y1;
            yc2 = m.*(RightEdge-x1) + y1;
            xc1 = 1./m.*(BtmEdge-y1) + x1;
            xc2 = 1./m.*(TopEdge-y1) + x1;
            
            ptIntersect = [];
            
            % Check for valid intersects
            if (yc1 >= BtmEdge && yc1 <= TopEdge)    ptIntersect = [ptIntersect; [LeftEdge, yc1]]; end
            if (yc2 >= BtmEdge && yc2 <= TopEdge)    ptIntersect = [ptIntersect; [RightEdge, yc2]]; end
            if (xc1 >= LeftEdge && xc1 <= RightEdge) ptIntersect = [ptIntersect; [xc1, BtmEdge]]; end
            if (xc2 >= LeftEdge && xc2 <= RightEdge) ptIntersect = [ptIntersect; [xc2, TopEdge]]; end
            
            intersect1 = ptIntersect(1,:);
            intersect2 = ptIntersect(2,:);
            
        end
        
        % Singular case
        if (bSingular)   % vertical line
            % Calculate square intersect
            intersect1 = [x1, TopEdge];
            intersect2 = [x1, BtmEdge];
        end
        
        % The dot product of (p1-intersect).(p2-intersect) is negative if the intersection point
        % lie between two points, as the two vectors take on different direction
        % Due to the point configuration, only one "intersect" test is
        % needed (the other one is logial compliment)
        v1 = sum((P1-intersect1).*(P2-intersect1),2);
        % v2 = sum((P1-intersect2).*(P2-intersect2),2);
        
        v1neg = v1<0;
        v2neg = ~v1neg;
        
        xc(v1neg) = intersect1(v1neg,1);
        xc(v2neg) = intersect2(v2neg,1);
        yc(v1neg) = intersect1(v1neg,2);
        yc(v2neg) = intersect2(v2neg,2);
        
        
    case 2
        % Both points are outside of unit circle
        
        if (bNonsingular)    % Regular equation of line
            
            m = dy./dx;
            
            % Calculate square intersect
            yc1 = m.*(LeftEdge-x1) + y1;
            yc2 = m.*(RightEdge-x1) + y1;
            xc1 = 1./m.*(BtmEdge-y1) + x1;
            xc2 = 1./m.*(TopEdge-y1) + x1;
            
            ptIntersect = [];
            
            % Check for valid intersects
            if (yc1 >= BtmEdge && yc1 <= TopEdge)    ptIntersect = [ptIntersect; [LeftEdge, yc1]]; end
            if (yc2 >= BtmEdge && yc2 <= TopEdge)    ptIntersect = [ptIntersect; [RightEdge, yc2]]; end
            if (xc1 >= LeftEdge && xc1 <= RightEdge) ptIntersect = [ptIntersect; [xc1, BtmEdge]]; end
            if (xc2 >= LeftEdge && xc2 <= RightEdge) ptIntersect = [ptIntersect; [xc2, TopEdge]]; end
            
            if (isempty(ptIntersect))
                intersect1 = nan(1,2);
                intersect2 = nan(1,2);
            else
                intersect1 = ptIntersect(1,:);
                intersect2 = ptIntersect(2,:);
            end
            
            % Ensures that [xc,yc] is between the two voronoi vertices.
            v1 = sum((P1-intersect1).*(P2-intersect1),2);
            v2 = sum((P1-intersect2).*(P2-intersect2),2);
            
            % Check that the line connecting two voronoi vertices intersects the square
            if (v1<0 && v2<0) 
                xc = [intersect1(1),intersect2(1)];
                yc = [intersect1(2),intersect2(2)];
            else
                xc = nan(2,1);
                yc = nan(2,1);
            end
            
        end
        
        if (bSingular)   % vertical line
            if (x1>=LeftEdge && x1<= RightEdge)
                xc = [x1; x1];
                % yc = [LeftEdge; RightEdge]; 
                yc = [BtmEdge; TopEdge];
            else
                xc = nan(2,1);
                yc = nan(2,1);
            end
        end    
end