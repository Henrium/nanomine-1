clear all;
B = {};
VF = [0.007, 0.01, 0.01, 0.005, 0.005, 0.01, 0.01, 0.009, 0.01, 0.01, 0.005, 0.005];
for ii = 1:1:12
    name = [ num2str(100+ii) ];
    img = imread( [name '.TIF'] );
              img = img( 251:2250, 251:4008-250 );  
             tic; img = medfilt2(img, [10 10]); toc;
            disp('Finish filtering process 1');
                    
            [~, Bimg] = Transform(img, VF(ii)); 
             cs = 2000;
            Bimg1 = Bimg( :, 1:cs );
            Bimg2 = Bimg( :, length(Bimg)-cs+1 : length(Bimg) ); 
            B{2*ii-1} = Bimg1;
            B{2*ii} = Bimg2;
end