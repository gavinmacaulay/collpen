% close all;
% clear;
%
% source_folder = '/Volumes/Datos/collpen/methods_paper_sources/';
% cartesian_video = '2013-07-17_085620_Raw_1825_1920_raw_cartesian.avi';
% polar_video = '2013-07-17_085620_Raw_1825_1920_raw_polar.avi';
% map_scan = '2013-07-17_085620_Raw_1825_1920_map_scan.mat';
%
% load([source_folder map_scan]);
%
% video_reader_cartesian = VideoReader([source_folder cartesian_video]);
% I = read(video_reader_cartesian,1);
% [r1 c1 n] = size(I);
%
% video_reader_polar = VideoReader([source_folder polar_video]);
% J = read(video_reader_polar,1);
% [r2 c2 n] = size(J);
%
% n = video_reader_cartesian.NumberOfFrames;
% disp(n);
%
% for i=1:n
%     I = read(video_reader_cartesian,i);
%
%
%     J = read(video_reader_polar,i);
%     subplot(1,2,2);
%     imagesc(J); axis equal; axis tight;
%     subplot(1,2,1);
%     imagesc(I); axis equal; axis tight;
%     hold on;
%     cart_point = round(ginput);
%     %cart_point = [216 744];
%     plot(cart_point(1),cart_point(2),'or');
% %     pos =c1 * round(cart_point(2)-1) + round(cart_point(1));
% %
% %     pol_pos = map.svector(pos);
% %
% %     pol_point = [mod(pol_pos,c2) round(pol_pos/c2)+1]
%
%     [pol_point_x pol_point_y] = cartesian2Polar(cart_point(1),cart_point(2));
%     subplot(1,2,2);
%     hold on;
%     plot(round(pol_point_x),round(pol_point_y),'or');
%     hold off;
%     disp(i);
%     ginput
% end
%
%
% %%
% close all
%
% % pos =c1 * round(cart_point(2)) + round(cart_point(1));
% %
% % pol_pos = map.svector(pos)
% %
% % pol_point = [round(pol_pos/c2) mod(pol_pos,c2)];
% % subplot(1,2,2);
% % hold on;
% % plot(pol_point(1),pol_point(2),'or');
%
% pcimg = imagecartesian2polar(I, 83, 1090 ,26,0); figure;imagesc(pcimg);colormap gray;axis equal; axis tight;


%%



close all;
clear;

source_folder       = '/Volumes/Datos/collpen/methods_paper_sources/';
cartesian_video     = '2013-07-17_085620_Raw_1825_1920_raw_cartesian.avi';
polar_video         = '2013-07-17_085620_Raw_1825_1920_raw_polar.avi';
aris_cartesian_video = '2013-07-17_085620_1825_1920_aris_cartesian.avi';
aris_polar_video    = '2013-07-17_085620_1825_1920_aris_polar.avi';
polar_video_wide    = '2013-07-17_085620_Raw_1825_1920_raw_polarwide.avi';

image_h = 800;


video_reader_cartesian = VideoReader([source_folder cartesian_video]);
I = read(video_reader_cartesian,1);
[r1 c1 n1] = size(I);

video_reader_polar = VideoReader([source_folder polar_video]);
J = read(video_reader_polar,1);
[r2 c2 n2] = size(J);

video_reader_aris_cartesian = VideoReader([source_folder aris_cartesian_video]);
K = read(video_reader_aris_cartesian,1);
[r3,c3, n3] = size(K);

video_reader_aris_polar = VideoReader([source_folder aris_polar_video]);
L = read(video_reader_aris_polar,1);
[r4, c4, n4] = size(L);

video_reader_polarwide = VideoReader([source_folder polar_video_wide]);
M = read(video_reader_polarwide,1);
[r5, c5, n5] = size(M);

n = video_reader_cartesian.NumberOfFrames;

%   video_reader_cartesian.NumberOfFrames
%    video_reader_polar.NumberOfFrames
%    video_reader_aris_cartesian.NumberOfFrames
%   video_reader_aris_polar.NumberOfFrames
%   video_reader_polarwide.NumberOfFrames

disp(n);

pin  = [ 3,25;200,1 ;400,25;186,744 ;216,744 ;150,281;245,443;221,558;228,425; 92,190;378,108;232,221;127,510;175,179];
pout = [81,55;341,22;605,54;323,1044;364,1044;284,407;403,603;366,790;380,597;203,282;577,168;391,323;247,721;316,266];



v1 = homography_solve(pin',pout');

v2 = vgg_H_from_x_lin(pin',pout');

pin2 = [pin' ; ones(1,length(pin))];
pout2 = [pout' ; ones(1,length(pout))];
v3 = vgg_H_from_x_nonlin(v2,(pin2),(pout2));

for i=1:n
    
    I = read(video_reader_cartesian,i);
    J = read(video_reader_polar,i);
    K = read(video_reader_aris_cartesian,i);
    L = read(video_reader_aris_polar,i);
    M = read(video_reader_polarwide,i);
    
    subplot(1,5,4);
    imagesc(M); axis equal;axis tight;
    subplot(1,5,5);
    imagesc(L); axis equal; axis tight;
    subplot(1,5,2);
    imagesc(K); axis equal; axis tight;
    subplot(1,5,3);
    imagesc(J); axis equal; axis tight;
    subplot(1,5,1);
    imagesc(I); axis equal; axis tight;
    hold on;
    
    
    cart_point = round(ginput);
    
    %  cart_point = [200 100];
    plot(cart_point(1),cart_point(2),'or');
    
    
    % ARIS Cartesian
   % aris_cart_point = homography_transform(cart_point',v1);
    subplot(1,5,2);
    hold on;
%     plot(round(aris_cart_point(1)),round(aris_cart_point(2)),'or');
%     
%     aris_cart_point = homography_transform(cart_point',v2);
%     plot(round(aris_cart_point(1)),round(aris_cart_point(2)),'xg');
%  
%     aris_cart_point = homography_transform(cart_point',v3);
%     plot(round(aris_cart_point(1)),round(aris_cart_point(2)),'+b');
    
    aris_cart_point = raw_cart_didson_to_cart_arissfw_point(cart_point);
    plot(round(aris_cart_point(1)),round(aris_cart_point(2)),'xg');

    hold off;
    
    % Raw Polar
    a = cart_point(1) - c1/2;
    b = image_h - cart_point(2);
    
%     [theta rho] = cart2pol(b,a);
%     
%     theta_corrected = round(1.012 * (0.0023*(theta^3) - 0.0085 * (theta^2) + 3.003*theta + 47.73));
    
    c = sqrt(a^2 + b^2);
    
    ang = atan(a/b);
    
    alpha = round(radtodeg(atan(a/b)));
    
    alpha_corrected = round(1.012 * (0.0023*(alpha^3) - 0.0085 * (alpha^2) + 3.003*alpha + 47.73));
    
    
    %    alpha = -alpha;
    
%     alpha = 13 + alpha + 1;
%     angle = alpha * c2/28;
    range = round(r2 - (c*r2/r1) + r2*(image_h-r1)/r1);
    
    %%%%%%%%%%%%%%%%
    %[alpha_corrected angle];
    subplot(1,5,3);
    hold on;
    %plot(round(angle),round(range),'or');
    plot(round(alpha_corrected),round(range),'xg');
    hold off
    % Raw wide polar
  
    subplot(1,5,4);
    hold on;
   % plot(round(angle*6),round(range),'or');
    plot(round(alpha_corrected*6),round(range),'xg');
    hold off;
    
    subplot(1,5,5);
    hold on;
    %aris_polar = raw_polar_didson_to_polar_arissfw_point([angle,range]);
    %plot(round(aris_polar(1)),round(aris_polar(2)),'or');
    aris_polar = raw_polar_didson_to_polar_arissfw_point([alpha_corrected,range]);
    plot(round(aris_polar(1)),round(aris_polar(2)),'xg');
    hold off;
    
    disp(i);
    ginput
end

