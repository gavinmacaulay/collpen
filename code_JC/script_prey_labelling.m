%% Script to generate ground truth from video for testing denoising
% techniques


% Along the video, each prey sample consists of 3 position detections. 
% The labeled detection will be 3 value tuples: frames, pred_x and pred_y

clear
close all

% Videos for the tests
% 2013-07-17_085620_Raw_1825_1920_raw_cartesian.avi 
% 2013-07-19_105504_Raw_1758_1821_raw_cartesian.avi
% 2013-07-17_171402_Raw_1844_1947_raw_cartesian.avi 
% block10_1_Raw_395_476_raw_cartesian.avi
% 2013-07-18_090802_Raw_1735_1810_raw_cartesian.avi 
% block5_1_Raw_396_514_raw_cartesian.avi
% 2013-07-18_120502_Raw_1450_1520_raw_cartesian.avi 
% block9_1_Raw_730_830_raw_cartesian.avi
% 2013-07-18_161457_Raw_726_804_raw_cartesian.avi

filepath = '/Volumes/Datos/collpen/methods_paper_sources/';
filename = '2013-07-18_161457_Raw_726_804_raw_cartesian.avi';



end_frame = 150;
start_frame = 5;
interpolate = 1;
debug = 1;
save_data = 1;
prey = 1;

[frames pred_x pred_y frames_interp interp_x interp_y]  = ...
    labelPredatorPosition(filepath, filename, prey, start_frame, ...
    end_frame, interpolate, save_data, debug);

[frames pred_x pred_y]
[frames_interp interp_x interp_y]

%% Plot ground truth
close all
clear 

load('/Volumes/Datos/collpen/test_remember/prey_position/predmodel2013_TREAT_Brown net_didson_block45_sub1_prey_positions.mat');

% Split prey positions
close all
figure; axis equal; 
hold on
preys = [];
for i = 3:3:length(frames)
  fr = frames(i-2:i);
  px = predator_x(i-2:i);
  py = predator_y(i-2:i);
  [x y u v] = averagePreyMovement(fr,px,py);
  preys = [preys ; [fr(2) x y u v]];
  plot(px,py,'.');
  quiver(x,y,u,v,'r');
  hypot(u,v)
  
  plot(x,y,'.r');
end



