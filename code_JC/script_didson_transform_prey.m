% Script to transform prey positions from raw cartesian videos to the
% remaining formats

close all;
clear;


in_prey_folder = '/Volumes/Datos/collpen/methods_paper_sources/prey_position/';

raw_cartesian_prey_string = '_raw_cartesian_prey_positions.mat';
raw_polar_prey_string = '_raw_polar_prey_positions.mat';
raw_polarwide_prey_string = '_raw_polarwide_prey_positions.mat';

aris_cartesian_prey_string = '_aris_cartesian_prey_positions.mat';
aris_polar_prey_string = '_aris_polar_prey_positions.mat';

d = dir([in_prey_folder '*' raw_cartesian_prey_string]);

[num_files c] = size(d);

raw_cart_h = 800; % Actual height + distance to the origin of the beams
raw_cart_w = 400; % Actual width

raw_pol_h = 512;
raw_pol_w = 96;

for i=1:num_files
    disp(['Converting points in file ' num2str(i) ' of ' num2str(num_files)]);
    load([in_prey_folder d(i).name]);
    
    pout_sfw_cart_prey_x              = [];
    pout_sfw_cart_prey_y              = [];
    pout_sfw_cart_frames              = [];
    pout_sfw_cart_interp_x            = [];
    pout_sfw_cart_interp_y            = [];
    pout_sfw_cart_frames_interpolated = [];
    
    pout_sfw_pol_prey_x              = [];
    pout_sfw_pol_prey_y              = [];
    pout_sfw_pol_frames              = [];
    pout_sfw_pol_interp_x            = [];
    pout_sfw_pol_interp_y            = [];
    pout_sfw_pol_frames_interpolated = [];
    
    pout_raw_pol_prey_x              = [];
    pout_raw_pol_prey_y              = [];
    pout_raw_pol_frames              = [];
    pout_raw_pol_interp_x            = [];
    pout_raw_pol_interp_y            = [];
    pout_raw_pol_frames_interpolated = [];
    
    pout_raw_pol_wide_prey_x              = [];
    pout_raw_pol_wide_prey_y              = [];
    pout_raw_pol_wide_frames              = [];
    pout_raw_pol_wide_interp_x            = [];
    pout_raw_pol_wide_interp_y            = [];
    pout_raw_pol_wide_frames_interpolated = [];
    
    % Transform labelled positions for the current file, starting with the
    % actual labelled points
    for j=1:length(predator_x)
        pin = [predator_x(j) predator_y(j)];
        [pout_sfw_cart pout_sfw_pol pout_raw_pol pout_raw_pol_wide] ...
            = didson_match_raw_cartesian_to_sfw_and_polar(pin);
        
        pout_sfw_cart_prey_x = [pout_sfw_cart_prey_x ; pout_sfw_cart(1)];
        pout_sfw_cart_prey_y = [pout_sfw_cart_prey_y ; pout_sfw_cart(2)];
        pout_sfw_cart_frames = [pout_sfw_cart_frames ; frames(j)];
        
        pout_sfw_pol_prey_x = [pout_sfw_pol_prey_x ; pout_sfw_pol(1)];
        pout_sfw_pol_prey_y = [pout_sfw_pol_prey_y ; pout_sfw_pol(2)];
        pout_sfw_pol_frames = [pout_sfw_pol_frames ; frames(j)];
        
        pout_raw_pol_prey_x = [pout_raw_pol_prey_x ; pout_raw_pol(1)];
        pout_raw_pol_prey_y = [pout_raw_pol_prey_y ; pout_raw_pol(2)];
        pout_raw_pol_frames = [pout_raw_pol_frames ; frames(j)];
        
        pout_raw_pol_wide_prey_x = [pout_raw_pol_wide_prey_x ; pout_raw_pol_wide(1)];
        pout_raw_pol_wide_prey_y = [pout_raw_pol_wide_prey_y ; pout_raw_pol_wide(2)];
        pout_raw_pol_wide_frames = [pout_raw_pol_wide_frames ; frames(j)];

    end
    
    % The interpolated values are not used in prey labelling, just for the
    % predator, are just kept to keep coherence
    for j=1:length(interp_x)
        pin = [interp_x(j) interp_y(j)];
        [pout_sfw_cart pout_sfw_pol pout_raw_pol pout_raw_pol_wide] ...
            = didson_match_raw_cartesian_to_sfw_and_polar(pin);
        
        pout_sfw_cart_interp_x = [pout_sfw_cart_interp_x ; pout_sfw_cart(1)];
        pout_sfw_cart_interp_y = [pout_sfw_cart_interp_y ; pout_sfw_cart(2)];
        pout_sfw_cart_frames_interpolated = [pout_sfw_cart_frames_interpolated ; frames_interpolated(j)];
        

        pout_sfw_pol_interp_x = [pout_sfw_pol_interp_x ; pout_sfw_pol(1)];
        pout_sfw_pol_interp_y = [pout_sfw_pol_interp_y ; pout_sfw_pol(2)];
        pout_sfw_pol_frames_interpolated = [pout_sfw_pol_frames_interpolated ; frames_interpolated(j)];
        

        pout_raw_pol_interp_x = [pout_raw_pol_interp_x ; pout_raw_pol(1)];
        pout_raw_pol_interp_y = [pout_raw_pol_interp_y ; pout_raw_pol(2)];
        pout_raw_pol_frames_interpolated = [pout_raw_pol_frames_interpolated ; frames_interpolated(j)];
        

        pout_raw_pol_wide_interp_x = [pout_raw_pol_wide_interp_x ; pout_raw_pol_wide(1)];
        pout_raw_pol_wide_interp_y = [pout_raw_pol_wide_interp_y ; pout_raw_pol_wide(2)];
        pout_raw_pol_wide_frames_interpolated = [pout_raw_pol_wide_frames_interpolated ; frames_interpolated(j)];
    end
%     
%     raw_polar_prey_string = '_raw_polar_prey_positions.mat';
% raw_polarwide_prey_string = '_raw_polarwide_prey_positions.mat';
% 
% aris_cartesian_prey_string = '_aris_cartesian_prey_positions.mat';
% aris_polar_prey_string = '_aris_polar_prey_positions.mat';

% Save raw polar transformed points
predator_x = pout_raw_pol_prey_x;
predator_y = pout_raw_pol_prey_y;
frames = pout_raw_pol_frames;
interp_x = pout_raw_pol_interp_x;
interp_y = pout_raw_pol_interp_y;
frames_interpolated = pout_raw_pol_frames_interpolated;

polar_transformed_file = [in_prey_folder strrep(d(i).name,raw_cartesian_prey_string,raw_polar_prey_string)];
save(polar_transformed_file,'predator_x','predator_y','frames','interp_x','interp_y','frames_interpolated');

% Save raw wide polar transformed points
predator_x = pout_raw_pol_wide_prey_x;
predator_y = pout_raw_pol_wide_prey_y;
frames = pout_raw_pol_wide_frames;
interp_x = pout_raw_pol_wide_interp_x;
interp_y = pout_raw_pol_wide_interp_y;
frames_interpolated = pout_raw_pol_wide_frames_interpolated;

polar_transformed_file = [in_prey_folder strrep(d(i).name,raw_cartesian_prey_string,raw_polarwide_prey_string)];
save(polar_transformed_file,'predator_x','predator_y','frames','interp_x','interp_y','frames_interpolated');


% Save cartesian aris sofwtare transformed  points
predator_x = pout_sfw_cart_prey_x;
predator_y = pout_sfw_cart_prey_y;
frames = pout_sfw_cart_frames;
interp_x = pout_sfw_cart_interp_x;
interp_y = pout_sfw_cart_interp_y;
frames_interpolated = pout_sfw_cart_frames_interpolated;

polar_transformed_file = [in_prey_folder strrep(d(i).name,raw_cartesian_prey_string,aris_cartesian_prey_string)];
save(polar_transformed_file,'predator_x','predator_y','frames','interp_x','interp_y','frames_interpolated');


% Save polar aris sofwtare transformed points
predator_x = pout_sfw_pol_prey_x;
predator_y = pout_sfw_pol_prey_y;
frames = pout_sfw_pol_frames;
interp_x = pout_sfw_pol_interp_x;
interp_y = pout_sfw_pol_interp_y;
frames_interpolated = pout_sfw_pol_frames_interpolated;

polar_transformed_file = [in_prey_folder strrep(d(i).name,raw_cartesian_prey_string,aris_polar_prey_string)];
save(polar_transformed_file,'predator_x','predator_y','frames','interp_x','interp_y','frames_interpolated');
disp('Done!');
end

disp('The End');
