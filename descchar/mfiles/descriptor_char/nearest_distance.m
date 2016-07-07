function nd = nearest_distance(image)
%--------------------------------------------------------------------------
% Hongyi Xu, IDEAL Lab, Mechanical Engineering, Northwestern University
% This function is to calculate the nearest boundary distance. 

% INPUT: 
% 2D image, any binary image, background should be 0;
% OUTPUT: 
% nd: the list of nearest boundary distance
%
% It used "convex hull" previously. Now it is changed to boundary.
% Modified by H. Xu, Dec 3, 2013
%--------------------------------------------------------------------------
image = double(image); % Binary image! Background is 0!
image = ceil(image./1000);
img = bwlabel(image);
% clear image
ClusterNo = max(max(img));

if ClusterNo > 1
    nd = [];
    Hull_list = [];   % List all the hull (boundary) coordinates in a N*2 matrix
    Hull_Len = [];    % record the length of the hull for each cluster
    Hull_start = [1]; % mark the start point for each cluster

    % Obtain the convex hull of each cluster
    for ii = 1:1:ClusterNo
        
        timg = double(img == ii);
        timg = find_edge_1_img(timg);
        [x,y] = find( timg ~= 0 );
        coo = [x,y];

        convex_H{ii} = coo;
        Hull_list = [Hull_list; coo];

        Hull_Len = [ Hull_Len ; size(coo,1) ];

        Hull_start = [ Hull_start ; length(Hull_list) + 1 ]; % Note that the last element in Hull_start should be discarded or never used

    end
    Hull_start = Hull_start(1:ClusterNo);
    clear ii ll ch

    LL = length(Hull_list); % LL is the length of the Hull_list

    for ii = 1:1:ClusterNo

        % Calculate the location of the chosen Hull in the Hull_list
        L = Hull_Len(ii); % L is the length of the chosen Hull
        start_p = Hull_start(ii);
        end_p = start_p + Hull_Len(ii) - 1;

        % Generate a list contains all the other hull coordinates except the
        % chosen one.
        if start_p == 1
            other_hulls = Hull_list( (L+1):LL, : );
        end
        if end_p == LL
            other_hulls = Hull_list( 1:(LL-L),: );
        end    
        if ( start_p ~= 1 ) && ( end_p ~= LL )
            other_hulls = [ Hull_list( 1:(start_p-1),: ) ; Hull_list( (end_p+1):LL,: )   ];     % "other_hulls" is also a N*2 matrix
        end
        LLL = length(other_hulls); % LLL is the length of "other_hulls"

        % Distance calculation between the points on the chosen hull and all the other hulls
        DIS = [];
        for jj = 1:1:L

            er = convex_H{ii}(jj,:); % er: each row
            expand_er = repmat(er,LLL,1);
            distances = (other_hulls - expand_er).^2;
            distances = sum( distances , 2);
            distances = distances.^0.5;
            DIS = [DIS; distances];

        end

        nd = [nd; min(DIS)];

    end

%     % Calculate nda
%     nda = mean(nd);
% 
%     % Calculate ndf
%     nd_L = length(nd);
%     [ num , bin_centers ] = hist(nd);
%     bin_width = bin_centers(2) - bin_centers(1);
%     [~,loc] = find( num == max(num) );
%     bin_num = length(num);
% 
%     while length(loc) ~= 1
%         bin_num = bin_num - 1;
%         [ num , bin_centers ] = hist(nd , bin_num);
%         bin_width = bin_centers(2) - bin_centers(1);
%         [~,loc] = find( num == max(num) );
%     end
% 
% 
%     temp_sum = 0;
%     temp_cnt = 0;
%     for ii = 1:1:nd_L
%         if ( nd(ii) >= bin_centers(loc) - bin_width/2 ) && ( nd(ii) <= bin_centers(loc) + bin_width/2 )
%             temp_sum = temp_sum + nd(ii);
%         end
%     end
%     ndf = temp_sum/num(loc);
end

if ClusterNo <= 1
    
    nd = length(image);
%     nda = NaN;
%     ndf = NaN;
end