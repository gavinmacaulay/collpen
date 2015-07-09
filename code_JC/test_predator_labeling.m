%% Labeling of frames to track predator trajectory

clear
close all

filepath = '/Volumes/Datos/collpen/predator/brown_net/seq1/';
filename = 'predmodel2013_TREAT_Brown net_didson_block47_sub1.avi';



end_frame = 75;
start_frame = 36;
interpolate = 1;
debug = 1;
save_data = 1;
predator = 0; 

[frames pred_x pred_y frames_interp interp_x interp_y]  = labelPredatorPosition(filepath, filename, predator, start_frame, end_frame, interpolate, save_data, debug);

[frames pred_x pred_y]
[frames_interp interp_x interp_y]

%% Data analysis after separating labeled data into white_net, brown_net, with 2 subsequences each dataset

close all
clear
clc

path = '/Volumes/Datos/collpen/predator/test/';
d = dir([path '*_raw_predator_positions.mat']);

filepath = '/Volumes/Datos/collpen/predator/test/predmodel2013_TREAT_Brown net_didson_block45_sub1.avi';


debug = 0;


info     = aviinfo(filepath);
movieobj = mmreader(filepath);
RGB         = rgb2gray(read(movieobj, 10));



f = [];
reg_x = [];
reg_y = [];
reg_frames_x =[];
reg_frames_y = [];



if(debug)
    subplot(1,3,2);
    axis equal
    subplot(1,3,3);
    axis equal
    subplot(1,3,1);
    imagesc(RGB);
    colormap gray
    axis equal
    hold all
end
leg = [] ;

mx = [];
my = [];
px = []; 
fr = []; 
py = [];

% Apply lineal regression to get the average slope of the
% trajectories
tic
for i = 1:length(d)
    
    load([path d(i).name]);
    
    px{i} = predator_x;
    fr{i} = frames;
    py{i} = predator_y;
    max_length = -1;
    
    
    if(~isempty(predator_x))
        [r_x r_y r_frames_x r_frames_y m_x m_y ] = regressionPredatorTrajectory(px{i}, py{i}, fr{i}, debug);
        
        reg_x{i} = r_x;
        reg_y{i} = r_y;
        reg_frames_x{i} = r_frames_x;
        reg_frames_y{i} = r_frames_y;
        mx{i} = m_x;
        my{i} = m_y;
        
        leg{i} = d(i).name;
        
    else
        display(['No data available. Seq ' d(i).name])
    end
    
    hold all
    
end

mean_mx = mean(cell2mat(mx));
mean_my = mean(cell2mat(my));

% Interpolate predator trajectory using a smoothing spline
smoothed_x = [];
smoothed_y = [];
smoothed_fr = [];

for f = 1:length(fr)
    if(~isempty(px{f}))
        % Smooth x vs frames
        [sm_fr sm_x] = smoothingSpline(fr{f},px{f});
        smoothed_x{f} = sm_x;
        
        % Smooth y vs frames
        [sm_fr sm_y] = smoothingSpline(fr{f},py{f});
        smoothed_y{f} = sm_y;
        smoothed_fr{f} = sm_fr;
    end
end

% Extrapolate predator trajectory backwards from the first smoothed detection
extrapolated_x = [];
extrapolated_y = [];
extrapolated_fr = [];

for f = 1:length(fr)
    if(~isempty(px{f}))
        if(debug)
            figure(2);
            hold all;
        end
        [ext_x ext_y ext_fr] = extrapolatePredatorTrajectory(smoothed_x{f}(1), smoothed_y{f}(1), smoothed_fr{f}(1), mean_mx, mean_my, debug);
        
        extrapolated_x{f} = ext_x(end:-1:1);
        extrapolated_y{f} = ext_y(end:-1:1);
        extrapolated_fr{f} = ext_fr(end:-1:1);
    end
end
toc

%% Plot the result
close all
imagesc(RGB);
colormap gray
axis equal

for f = 1:length(fr)
    if(~isempty(px{f}))
        hold on
        color = rand(1,3);
        plot(smoothed_x{f},smoothed_y{f},'color',color);
        % plot(px{f},py{f}, '.', 'color', color);
        plot(extrapolated_x{f}, extrapolated_y{f}, 'color', color);
        hold off
    end
end



%% Save smoothed and extrapolated data
clc

if(exist('d','var') ~= 1) % The smoothing and extrapolating code (above) should have been executed in advance
    disp('Data not available. Consider running the smoothing and extrapolating code above');
    disp('Aborting...');
    return;
end

tic
for f = 1:length(extrapolated_fr)
    extrap = [extrapolated_fr{f}, extrapolated_x{f},extrapolated_y{f}, repmat(1, length(extrapolated_fr{f}), 1)];
    smooth = [smoothed_fr{f}, smoothed_x{f}, smoothed_y{f}, repmat(2, length(smoothed_fr{f}), 1)];
    frame_pixel_info = [extrap ; smooth];
    
    if(~isempty(extrapolated_fr{f}))
        str = strrep(leg{f}, '_raw_predator_positions.mat', '_interp_extrap_path.mat');
        %datafolder = [path 'predator_position/'];
        str = [path str];
        
%         if ~(exist(datafolder,'dir')==7)
%             disp(['Creating data folder, ' datafolder]);
%             mkdir(datafolder);
%             
%         end
        
        display(['Saving data in ' str]);
        save(str, 'frame_pixel_info');
    end
    
end
toc

%%
%clc
% for i = 1:length(leg)
%     i
%     disp(leg{i});
% end
%
% disp('.');
%
% for i = 1:length(d)
%     disp(d(i).name)
% end


%% Analyzing predator positions to extrapolate unknown ones

% close all clear clc
%
% path = '/Volumes/Datos/collpen/predator/brown_net/seq2/'; d = dir([path
% '*.mat']);
%
% filepath =
% '/Volumes/Datos/collpen/predator/white_net/seq2/predmodel2013_TREAT_White
% net_didson_block59_sub1.avi';
%
%
% info     = aviinfo(filepath); movieobj = mmreader(filepath); RGB
% = rgb2gray(read(movieobj, 10)); subplot(1,3,1); imagesc(RGB); colormap
% gray axis equal hold all
%
% subplot(1,3,2); imagesc(RGB); colormap gray axis equal hold all
%
% x = []; y = []; x_int = []; y_int = [];
%
% subplot(1,3,1); hold all
%
% for i = 1:length(d)
%     load([path d(i).name]); x = [x ; predator_x]; y = [y ; predator_y];
%
%     x_int = [x_int ; interp_x]; y_int = [y_int ; interp_y];
%
%     plot(round(predator_x), round(predator_y),'o'); hold all
%
%
%
% end
%
% % axis([0, 1000,0,750])
%
%
%
% % legend(d.name);
%
%
% [y_sort index] = sort(y); smooth_x = smooth(x(index),100,'loess');
% plot(smooth_x,y_sort,'-g');
%
%
% X = [x ones(size(x,1),1)]; % Add column of 1's to include constant term
% in regression a = regress(y,X) ;  % = [a1; a0] plot(x,X*a,'k-');  % This
% line perfectly overlays the previous fit line
%
%
% % Add to the scatterplot title('Without interp');
%
%
%
%
% subplot(1,3,2); plot(round(x_int), round(y_int), 'bo'); hold on
%
% [y_sort index] = sort(y_int); smooth_x =
% smooth(x_int(index),100,'loess'); plot(smooth_x,y_sort,'-g');
%
%
% X = [x_int ones(size(x_int,1),1)]; % Add column of 1's to include
% constant term in regression a = regress(y_int,X) ;  % = [a1; a0]
% plot(x_int,X*a,'-k');  % This line perfectly overlays the previous fit
% line
%
%
% % Add to the scatterplot title('With interpolation'),
%
%
% subplot(1,3,3);
%
% imagesc(RGB); colormap gray axis equal hold all
%
%
% % Plot means and apply regression to them
%
%
% [y_sort index] = sort(y); y_sort_round = round(y_sort); x_sort =
% x(index); y_unique = unique(y_sort_round); x_unique = [];
%
% for i = 1:size(y_unique)
%
%     y_ind =  find(y_sort_round == y_unique(i)); x_unique = [x_unique ;
%     mean(x_sort(y_ind))];
% end
%
% plot(x_unique,y_unique,'o')
%
%
% X = [x_unique ones(size(x_unique,1),1)]; % Add column of 1's to include
% constant term in regression a = regress(y_unique,X) ;  % = [a1; a0]
% plot(x_unique,X*a,'-k');  % This line perfectly overlays the previous fit
% line
%
% smooth_x = smooth(x_unique,100,'loess'); plot(smooth_x,y_unique,'g-');
% title('Averaging through y'); legend('means','Linear regression',
% 'loess');

