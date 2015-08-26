%% Script to generate ground truth from video for testing denoising
% techniques


% Along the video, each prey sample consists of 3 position detections. 
% The labeled detection will be 3 value tuples: frames, pred_x and pred_y

clear
close all

filepath = '/Volumes/Datos/collpen/denoising_tests/';
filename = '2013-07-17_171402_1844_1947_raw_polar.avi';



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



