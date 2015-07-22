% Different window size
% Script to automatize tests of PIV estimation coupled to a denoising technique
clear
close all
PIV_technique = 0;
% denoising_technique = 0;
% denoising_param = 0;
debug = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Describe the set of tests %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

denoising_techniques = [
                            -1,0;    % Raw images
    %                         0,0;    % Background subtraction + normalization
    %                         1,0;    % Gaussian
    %                         3,0;    % Median
    %                         5,0;    % Median + average
%      1,1;    % Wavelet + gaussian
%      3,1;    % Wavelet + Median
%      5,1;    % Wavelet + Median + average
    %                         9,50;   % DPAD 50
    %                         11,50;  % DPAD 50 + Median
    %                         10,25;  % SRAD 25
    %                         10,50;  % SRAD 50
    %                         10,100; % SRAD 100
    %                         12,25;  % SRAD 25 + Median
    %                         12,50;  % SRAD 50 + Median
    %                         12,100; % SRAD 100 + Median
    %                         8,0     % Frost
    ];
%
 denoising_techniques_name{1}  = '01-Raw images-filter';
% denoising_techniques_name{2}  = '02-Background subtraction + normalization-filter';
% denoising_techniques_name{3}  = '03-Gaussian-filter';
% denoising_techniques_name{4}  = '04-Median-filter';
% denoising_techniques_name{5}  = '05-Median + average-filter';
% denoising_techniques_name{6}  = '06-Wavelet + gaussian-filter';
% denoising_techniques_name{7}  = '07-Wavelet + Median-filter';
% denoising_techniques_name{8}  = '08-Wavelet + Median + average-filter';
% denoising_techniques_name{9}  = '09-DPAD 50-filter';
% denoising_techniques_name{10} = '10-DPAD 50 + Median-filter';
% denoising_techniques_name{11} = '11-SRAD 25-filter';
% denoising_techniques_name{12} = '12-SRAD 50-filter';
% denoising_techniques_name{13} = '13-SRAD 100-filter';
% denoising_techniques_name{14} = '14-SRAD 25 + Median-filter';
% denoising_techniques_name{15} = '15-SRAD 50 + Median-filter';
% denoising_techniques_name{16} = '16-SRAD 100 + Median-filter';
% denoising_techniques_name{17} = '17-Frost-filter';

% denoising_techniques_name{1}  = '06-Wavelet + gaussian-filter';
% denoising_techniques_name{2}  = '07-Wavelet + Median-filter';
% denoising_techniques_name{3}  = '08-Wavelet + Median + average-filter';

% denoising_techniques_name{1}  = '01-Raw images-filter';
% denoising_techniques_name{2}  = '04-Median-filter';
% denoising_techniques_name{3}  = '05-Median + average-filter';
% denoising_techniques_name{4} = '11-SRAD 25-filter';
% denoising_techniques_name{5} = '12-SRAD 50-filter';
% denoising_techniques_name{6} = '14-SRAD 25 + Median-filter';
% denoising_techniques_name{7} = '15-SRAD 50 + Median-filter';

folder = '/Volumes/Datos/collpen/predator/test/';
winsize=64;

for i = 1: length(denoising_techniques)
   % getPIVsFromFolder(folder, denoising_techniques(i,1), denoising_techniques(i,2), denoising_techniques_name(i));
    
    JC_PIV_getPIVvectorsFromFolder(folder, denoising_techniques(i,1), ...
        denoising_techniques(i,2), denoising_techniques_name(i), winsize);
    
    
end

folder = '/Volumes/Datos/collpen/predator/test/';
winsize=32;

for i = 1: length(denoising_techniques)
   % getPIVsFromFolder(folder, denoising_techniques(i,1), denoising_techniques(i,2), denoising_techniques_name(i));
   
    JC_PIV_getPIVvectorsFromFolder(folder, denoising_techniques(i,1),...
        denoising_techniques(i,2), denoising_techniques_name(i), winsize);
    
    
end

folder = '/Volumes/Datos/collpen/predator/test/';
winsize=64;

for i = 1: length(denoising_techniques)
   % getPIVsFromFolder(folder, denoising_techniques(i,1), denoising_techniques(i,2), denoising_techniques_name(i));
    
    JC_PIV_getPIVvectorsFromFolder(folder, denoising_techniques(i,1), ...
        denoising_techniques(i,2), denoising_techniques_name(i), winsize)
    
    
end


%% Script to automatize tests of PIV estimation coupled to a denoising technique
clear
close all
PIV_technique = 0;
% denoising_technique = 0;
% denoising_param = 0;
debug = 0;
winsize = 64;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Describe the set of tests %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

denoising_techniques = [
                            -1,0;    % Raw images
    %                         0,0;    % Background subtraction + normalization
    %                         1,0;    % Gaussian
                             3,0;    % Median
                             5,0;    % Median + average
    %                         1,1;    % Wavelet + gaussian
    %                         3,1;    % Wavelet + Median
    %                         5,1;    % Wavelet + Median + average
    %                         9,50;   % DPAD 50
    %                         11,50;  % DPAD 50 + Median
                             10,25;  % SRAD 25
                             10,50;  % SRAD 50
    %                         10,100; % SRAD 100
                             12,25;  % SRAD 25 + Median
                             12,50;  % SRAD 50 + Median
    %                         12,100; % SRAD 100 + Median
    %                         8,0     % Frost
    ];
%
% denoising_techniques_name{1}  = '01-Raw images-filter';
% denoising_techniques_name{2}  = '02-Background subtraction + normalization-filter';
% denoising_techniques_name{3}  = '03-Gaussian-filter';
% denoising_techniques_name{4}  = '04-Median-filter';
% denoising_techniques_name{5}  = '05-Median + average-filter';
% denoising_techniques_name{6}  = '06-Wavelet + gaussian-filter';
% denoising_techniques_name{7}  = '07-Wavelet + Median-filter';
% denoising_techniques_name{8}  = '08-Wavelet + Median + average-filter';
% denoising_techniques_name{9}  = '09-DPAD 50-filter';
% denoising_techniques_name{10} = '10-DPAD 50 + Median-filter';
% denoising_techniques_name{11} = '11-SRAD 25-filter';
% denoising_techniques_name{12} = '12-SRAD 50-filter';
% denoising_techniques_name{13} = '13-SRAD 100-filter';
% denoising_techniques_name{14} = '14-SRAD 25 + Median-filter';
% denoising_techniques_name{15} = '15-SRAD 50 + Median-filter';
% denoising_techniques_name{16} = '16-SRAD 100 + Median-filter';
% denoising_techniques_name{17} = '17-Frost-filter';
% 
% denoising_techniques_name{1}  = '06-Wavelet + gaussian-filter';
% denoising_techniques_name{2}  = '07-Wavelet + Median-filter';
% denoising_techniques_name{3}  = '08-Wavelet + Median + average-filter';

denoising_techniques_name{1}  = '01-Raw images-filter';
denoising_techniques_name{2}  = '04-Median-filter';
denoising_techniques_name{3}  = '05-Median + average-filter';
denoising_techniques_name{4} = '11-SRAD 25-filter';
denoising_techniques_name{5} = '12-SRAD 50-filter';
denoising_techniques_name{6} = '14-SRAD 25 + Median-filter';
denoising_techniques_name{7} = '15-SRAD 50 + Median-filter';

folder = 'c:/collpen/predator/test/';
for i = 1: length(denoising_techniques)
   % getPIVsFromFolder(folder, denoising_techniques(i,1), denoising_techniques(i,2), denoising_techniques_name(i));
    
    JC_PIV_getPIVvectorsFromFolder(folder, denoising_techniques(i,1), ...
        denoising_techniques(i,2), denoising_techniques_name(i), winsize)
    
    
end





%% Script to compare PIVs to manually labelled points
clear
%close all
clc

winsize = 16;

folder = '/Volumes/Datos/collpen/predator/test/';


denoising_techniques_name{1}  = '01-Raw images-filter';
denoising_techniques_name{2}  = '02-Background subtraction + normalization-filter';
denoising_techniques_name{3}  = '03-Gaussian-filter';
denoising_techniques_name{4}  = '04-Median-filter';
denoising_techniques_name{5}  = '05-Median + average-filter';
denoising_techniques_name{6}  = '06-Wavelet + gaussian-filter';
denoising_techniques_name{7}  = '07-Wavelet + Median-filter';
denoising_techniques_name{8}  = '08-Wavelet + Median + average-filter';
denoising_techniques_name{9}  = '09-DPAD 50-filter';
denoising_techniques_name{10} = '10-DPAD 50 + Median-filter';
denoising_techniques_name{11} = '11-SRAD 25-filter';
denoising_techniques_name{12} = '12-SRAD 50-filter';
denoising_techniques_name{13} = '13-SRAD 100-filter';
denoising_techniques_name{14} = '14-SRAD 25 + Median-filter';
denoising_techniques_name{15} = '15-SRAD 50 + Median-filter';
denoising_techniques_name{16} = '16-SRAD 100 + Median-filter';
denoising_techniques_name{17} = '17-Frost-filter';


% denoising_techniques_name{1}  = '01-Raw images-filter';
% denoising_techniques_name{2}  = '02-Background subtraction + normalization-filter';
% denoising_techniques_name{3}  = '03-Gaussian-filter';
% denoising_techniques_name{4}  = '04-Median-filter';
% denoising_techniques_name{5}  = '06-Wt + gaussian-filter';
% denoising_techniques_name{6}  = '07-Wt + Median-filter';
% denoising_techniques_name{7}  = '08-Wt + Median + avg-filter';
% denoising_techniques_name{8}  = '09-DPAD 50-filter';
% denoising_techniques_name{9} = '10-DPAD 50 + Median-filter';
% denoising_techniques_name{10} = '11-SRAD 25-filter';
% denoising_techniques_name{11} = '12-SRAD 50-filter';
% denoising_techniques_name{12} = '13-SRAD 100-filter';
% denoising_techniques_name{13} = '14-SRAD 25 + Median-filter';
% denoising_techniques_name{14} = '15-SRAD 50 + Median-filter';
% denoising_techniques_name{15} = '16-SRAD 100 + Median-filter';
% denoising_techniques_name{16} = '17-Frost-filter';

% denoising_techniques_name{1}  = '01-Raw images-filter';
% denoising_techniques_name{2}  = '02-Background subtraction + normalization-filter';
% denoising_techniques_name{3}  = '06-Wavelet + gaussian-filter';
% denoising_techniques_name{4}  = '07-Wavelet + Median-filter';
% denoising_techniques_name{5}  = '08-Wavelet + Median + average-filter';


d=dir([folder '*.avi']);
% Acquire image size
% filepath = [folder d(1).name];
% movieobj = VideoReader(filepath);
% RGB         = read(movieobj, 1);

px_meter = 71.4413;
fps = 8;

save_image = 0;

% PIVdata_angles_denoising = [];
% PIVdata2_angles_denoising = [];
% PIVdata_ranges_denoising = [];
% PIVdata2_ranges_denoising = [];

disp('Loading and averaging data...');
tic
% Group disparity per denoising technique
for j = 1:length(denoising_techniques_name)
    for i = 1:length(d)
        PIVdata_angles_denoising{j,i} = [];
        PIVdata2_angles_denoising{j,i} = [];
        PIVdata_ranges_denoising{j,i} = [];
        PIVdata2_ranges_denoising{j,i} = [];
        PIVdata_dot_prod_denoising{j,i} = [];
        PIVdata2_dot_prod_denoising{j,i} = [];
        PIVdata_rel_ranges_denoising{j,i} = [];

        % Acquire image size
        filepath = [folder d(i).name];
        movieobj = VideoReader(filepath);
        % Load prey positions file
        preyfile = strrep([folder 'prey_position/' d(i).name], '.avi',...
            '_prey_positions.mat');
        %disp(['Load prey file ' preyfile]);
        load(preyfile);
        
        % Load PIVdata path
        
        pivdatapath   = strrep([folder 'PIVdata/' ...
            denoising_techniques_name{j} '/' d(i).name],'.avi','_PIV.mat');
       % disp(['Load PIVdata file ' pivdatapath]);
        load(pivdatapath);
        
        px_meter = 71.4413;
        fps = 8;
        save_path = strrep([folder 'PIVdata/' ...
            denoising_techniques_name{j} '/' d(i).name],'.avi','');
        % Check disparity
        [PIVdata_angles PIVdata_ranges PIVdata_dotproduct ...
            PIV_relative_range] = checkPIV2(pivdatapath, frames,...
            predator_x, predator_y, movieobj, px_meter, fps, save_path,...
            save_image);
        
%         % Load PIVdata2 path
%         pivdata2path   = strrep([folder 'PIVdata2/' denoising_techniques_name{j} '/' d(i).name],'.avi','_PIV.mat');
%        % disp(['Load PIVdata2 file ' pivdata2path]);
%         save_path = strrep([folder 'PIVdata2/' denoising_techniques_name{j} '/' d(i).name],'.avi','.');
%         load(pivdata2path);
%         px_meter = 71.4413;
%         fps = 8;
%         % Check disparity
%         [PIVdata2_angles PIVdata2_ranges PIVdata2_dotproduct] = checkPIV2(pivdata2path, frames, predator_x, predator_y, movieobj, save_path, save_image);
%         
       % disp('Append');
        
        PIVdata_angles_denoising{j,i} = [PIVdata_angles_denoising{j,i} ;...
            PIVdata_angles];
   %     PIVdata2_angles_denoising{j,i} = [PIVdata2_angles_denoising{j,i} ; PIVdata2_angles];
        PIVdata_ranges_denoising{j,i} = [PIVdata_ranges_denoising{j,i} ; ...
            PIVdata_ranges];
    %    PIVdata2_ranges_denoising{j,i} = [PIVdata2_ranges_denoising{j,i} ; PIVdata2_ranges];
        PIVdata_dot_prod_denoising{j,i} = [PIVdata_dot_prod_denoising{j,i}...
            ; PIVdata_dotproduct];
     %   PIVdata2_dot_prod_denoising{j,i} = [PIVdata2_dot_prod_denoising{j,i} ; PIVdata2_dotproduct];
        PIVdata_rel_ranges_denoising{j,i} = [PIVdata_rel_ranges_denoising{j,i}...
            ; PIV_relative_range];

    end
end
toc
disp('...Finished');

%% Average info

clc
% denoising_techniques_name{1}  = '01-Raw images-filter';
% denoising_techniques_name{2}  = '02-Bg sub + TVG-filter';
% denoising_techniques_name{3}  = '03-Gaussian-filter';
% denoising_techniques_name{4}  = '04-Median-filter';
% denoising_techniques_name{5}  = '05-Median + avg-filter';
% denoising_techniques_name{6}  = '06-Wt + gaussian-filter';
% denoising_techniques_name{7}  = '07-Wt + Median-filter';
% denoising_techniques_name{8}  = '08-Wt + Median + avg-filter';
% denoising_techniques_name{9}  = '09-DPAD 50-filter';
% denoising_techniques_name{10} = '10-DPAD 50 + Median-filter';
% denoising_techniques_name{11} = '11-SRAD 25-filter';
% denoising_techniques_name{12} = '12-SRAD 50-filter';
% denoising_techniques_name{13} = '13-SRAD 100-filter';
% denoising_techniques_name{14} = '14-SRAD 25 + Median-filter';
% denoising_techniques_name{15} = '15-SRAD 50 + Median-filter';
% denoising_techniques_name{16} = '16-SRAD 100 + Median-filter';
% denoising_techniques_name{17} = '17-Frost-filter';

% denoising_techniques_name{1}  = '01-Raw images-filter';
% denoising_techniques_name{2}  = '02-Bg sub + TVG-filter';
% denoising_techniques_name{3}  = '03-Gaussian-filter';
% denoising_techniques_name{4}  = '04-Median-filter';
% denoising_techniques_name{5}  = '06-Wt + gaussian-filter';
% denoising_techniques_name{6}  = '07-Wt + Median-filter';
% denoising_techniques_name{7}  = '08-Wt + Median + avg-filter';
% denoising_techniques_name{8}  = '09-DPAD 50-filter';
% denoising_techniques_name{9} = '10-DPAD 50 + Median-filter';
% denoising_techniques_name{10} = '11-SRAD 25-filter';
% denoising_techniques_name{11} = '12-SRAD 50-filter';
% denoising_techniques_name{12} = '13-SRAD 100-filter';
% denoising_techniques_name{13} = '14-SRAD 25 + Median-filter';
% denoising_techniques_name{14} = '15-SRAD 50 + Median-filter';
% denoising_techniques_name{15} = '16-SRAD 100 + Median-filter';
% denoising_techniques_name{16} = '17-Frost-filter';


% denoising_techniques_name{1}  = '01-Raw images-filter';
% denoising_techniques_name{2}  = '02-Background subtraction + normalization-filter';
% denoising_techniques_name{3}  = '06-Wavelet + gaussian-filter';
% denoising_techniques_name{4}  = '07-Wavelet + Median-filter';
% denoising_techniques_name{5}  = '08-Wavelet + Median + average-filter';

path = '/Volumes/Datos/collpen/predator/test/';
d=dir([path '*.avi']);

for i=1:size(PIVdata_angles_denoising,1)
    piv_angles_acc = [];
    piv2_angles_acc = [];
    piv_ranges_acc = [];
    piv2_ranges_acc = [];
    piv_dot_prod_acc = [];
    piv2_dot_prod_acc = [];
    piv_rel_ranges_acc = [];
    
    piv_nan_acc = [];
    
    for j=1:length(d)
        piv_angles_acc = [piv_angles_acc ; PIVdata_angles_denoising{i,j}];
     %   piv2_angles_acc = [piv2_angles_acc ; PIVdata2_angles_denoising{i,j}];
        piv_ranges_acc = [piv_ranges_acc ; PIVdata_ranges_denoising{i,j}];
      %  piv2_ranges_acc = [piv2_ranges_acc ; PIVdata2_ranges_denoising{i,j}];
        piv_dot_prod_acc = [piv_dot_prod_acc ; PIVdata_dot_prod_denoising{i,j}];
       % piv2_dot_prod_acc = [piv2_dot_prod_acc ; PIVdata2_dot_prod_denoising{i,j}];
         piv_rel_ranges_acc = [piv_rel_ranges_acc ; PIVdata_rel_ranges_denoising{i,j}];

        piv_nan_acc = [piv_nan_acc ; ...
            sum(isnan(PIVdata_angles_denoising{i,j}))*100/length(PIVdata_angles_denoising{i,j})];
    end
    mean_piv_angles(i) = mean(piv_angles_acc(~isnan(piv_angles_acc)));
%    mean_piv2_angles(i) = mean(piv2_angles_acc(~isnan(piv2_angles_acc)));
    
    mean_piv_ranges(i) = mean(piv_ranges_acc(~isnan(piv_ranges_acc)));
 %   mean_piv2_ranges(i) = mean(piv2_ranges_acc(~isnan(piv2_ranges_acc)));
    
    mean_piv_dotprod(i) = mean(piv_dot_prod_acc(~isnan(piv_dot_prod_acc)));
  %  mean_piv2_dotprod(i) = mean(piv2_dot_prod_acc(~isnan(piv2_dot_prod_acc)));
    mean_piv_nan(i) = mean(piv_nan_acc);
    
    mean_piv_relative_ranges(i) = mean(piv_rel_ranges_acc(~isnan(piv_rel_ranges_acc)));

    
   % disp(sprintf('%s \t %f \t %f \t %f \t %f',denoising_techniques_name{i},mean_piv_angles(i),mean_piv2_angles(i),mean_piv_ranges(i),mean_piv2_ranges(i)));
    
end
%close all
figure(2)
% mean_angle = [mean_piv_angles' mean_piv2_angles'];
mean_angle = mean_piv_angles';

bar(abs(mean_angle),'group');
leg{1} = 'PIVdata';
%leg{2} = 'PIVdata2';
legend(leg);

%set(gca,'XTickLabel',denoising_techniques_name);



%
close all
for i = 1:length(d)
    piv_mean_angle_test_file = [];
    piv_mean_range_test_file = [];
%     piv2_mean_angle_test_file = [];
%     piv2_mean_range_test_file = [];
    piv_dotprod_test_file = [];
    piv_nan_test_file = [];
    piv_rel_ranges_test_file = [];
    
    
    
    
    
    for j = 1:size(PIVdata_angles_denoising,1)
        piv_angles_video_denoising =  PIVdata_angles_denoising{j,i};
        piv_mean_angle_test_file =[ piv_mean_angle_test_file ;...
            mean(piv_angles_video_denoising(~isnan(piv_angles_video_denoising)))];

        piv_ranges_video_denoising =  PIVdata_ranges_denoising{j,i};
        piv_mean_range_test_file =[ piv_mean_range_test_file ;...
            mean(piv_ranges_video_denoising(~isnan(piv_ranges_video_denoising)))];
        
        piv_dotprod_video_denoising =  PIVdata_dot_prod_denoising{j,i};
        piv_dotprod_test_file =[ piv_dotprod_test_file ...
            mean(piv_dotprod_video_denoising(~isnan(piv_dotprod_video_denoising)))];
        
        nan_percentage = sum(isnan(piv_angles_video_denoising))*100/length(piv_angles_video_denoising);
        
        piv_nan_test_file = [piv_nan_test_file ; nan_percentage];
        
         piv_rel_ranges_video_denoising =  PIVdata_rel_ranges_denoising{j,i};
         piv_rel_ranges_test_file =[ piv_rel_ranges_test_file ; ...
             mean(piv_rel_ranges_video_denoising(~isnan(piv_rel_ranges_video_denoising)))];
        
%         piv2_angles_video_denoising =  PIVdata2_angles_denoising{j,i};
%         piv2_mean_angle_test_file =[ piv2_mean_angle_test_file ; mean(piv2_angles_video_denoising(~isnan(piv2_angles_video_denoising)))];
% 
%     
%         piv2_ranges_video_denoising =  PIVdata2_ranges_denoising{j,i};
%         piv2_mean_range_test_file =[ piv2_mean_range_test_file ; mean(piv2_ranges_video_denoising(~isnan(piv2_ranges_video_denoising)))];
%         
    end

    figure(1);
    plot(piv_mean_angle_test_file,'o');
    hold all
    figure(2);
    plot(piv_mean_range_test_file,'o');
    hold all
    figure(3);
    plot(piv_dotprod_test_file,'o');
    hold all
    figure(4);
    plot(piv_nan_test_file,'o');
    hold all 
    figure(5);
    plot(piv_rel_ranges_test_file,'o');
    hold all  
    
%     figure(3);
%     plot(piv2_mean_angle_test_file,'o');
%     hold all
%     figure(4);
%     plot(piv2_mean_angle_test_file,'o');
%     hold all
end

f = figure(1); set(f,'name','Angles');
plot(mean_piv_angles);
legend(d.name,'Location','northoutside')
print(f,'-dpng',[path int2str(winsize) '-angles.png']);

f = figure(2); set(f,'name','Ranges');
plot(mean_piv_ranges);
legend(d.name,'Location','northoutside')
print(f,'-dpng',[path int2str(winsize) '-ranges.png']);

f = figure(3); set(f,'name','Dot Product');
plot(mean_piv_dotprod);
legend(d.name,'Location','northoutside')
print(f,'-dpng',[path int2str(winsize) '-dotproduct.png']);

f = figure(4); set(f,'name','NaN Values Generated');
plot(mean_piv_nan);
legend(d.name,'Location','northoutside')
print(f,'-dpng',[path int2str(winsize) '-nan.png']);

f = figure(5); set(f,'name','Relative range differences');
plot(mean_piv_relative_ranges);
legend(d.name,'Location','northoutside')
print(f,'-dpng',[path int2str(winsize) '-reldiff.png']);


% figure(5);
% plot(mean_piv_nan',mean_piv_angles','o'); axis equal
disp(sprintf('Technique \t NaN \t Angle \t Range \t Dot Product'));
values = [(1:size(PIVdata_angles_denoising,1))' mean_piv_nan'...
    mean_piv_angles' mean_piv_ranges' mean_piv_dotprod'];
display(values);
% figure(3);
% plot(mean_piv2_angles);
% legend(d.name,'Location','northoutside')
% 
% figure(4);
% plot(mean_piv2_angles);
% legend(d.name,'Location','northoutside')


%% Script to generate videos from all fish input and denoising technique combinations

close all
clear
% 
% denoising_techniques_name{1}  = '01-Raw images-filter';
% denoising_techniques_name{2}  = '02-Background subtraction + normalization-filter';
% denoising_techniques_name{3}  = '03-Gaussian-filter';
% denoising_techniques_name{4}  = '04-Median-filter';
% denoising_techniques_name{5}  = '05-Median + average-filter';
% denoising_techniques_name{6}  = '06-Wavelet + gaussian-filter';
% denoising_techniques_name{7}  = '07-Wavelet + Median-filter';
% denoising_techniques_name{8}  = '08-Wavelet + Median + average-filter';
% denoising_techniques_name{9}  = '09-DPAD 50-filter';
% denoising_techniques_name{10} = '10-DPAD 50 + Median-filter';
% denoising_techniques_name{11} = '11-SRAD 25-filter';
% denoising_techniques_name{12} = '12-SRAD 50-filter';
% denoising_techniques_name{13} = '13-SRAD 100-filter';
% denoising_techniques_name{14} = '14-SRAD 25 + Median-filter';
% denoising_techniques_name{15} = '15-SRAD 50 + Median-filter';
% denoising_techniques_name{16} = '16-SRAD 100 + Median-filter';

denoising_techniques_name{1}  = '01-Raw images-filter';
denoising_techniques_name{2}  = '04-Median-filter';
denoising_techniques_name{3}  = '05-Median + average-filter';
denoising_techniques_name{4} = '11-SRAD 25-filter';
denoising_techniques_name{5} = '12-SRAD 50-filter';
denoising_techniques_name{6} = '14-SRAD 25 + Median-filter';
denoising_techniques_name{7} = '15-SRAD 50 + Median-filter';

d=dir('c:/collpen/predator/test/*.avi');

for i=1:length(d)
    filedir{i} = 'c:/collpen/predator/test/';
    file{i} = d(i).name;
end

% Datafolder
datafolder = [filedir{1} 'PIVdata2'];


f = figure;

for i = 1:length(d)
    
    filepath = [filedir{i}  file{i}];
    for k = 1:length(denoising_techniques_name)
        % Datapath
        datapath   = strrep([filedir{i} 'PIVdata2/' ...
            denoising_techniques_name{k} '/' file{i}],'.avi','_PIV.mat');
        pivavipath = strrep(datapath, 'mat','avi');
        disp(['Generate PIV video for file ' filepath]);
        load(datapath);
        %keyboard;
        
        % Opening movie object
        disp(['..Opening ' filepath]);
        info     = aviinfo(filepath);
        movieobj = VideoReader(filepath);
        
        n    = info.NumFrames-1;
        aviobj = avifile(pivavipath, 'compression', 'none', 'fps',8);
        
        % Loop to generate avi file
        disp(['Creating PIV avi in ' pivavipath]);
        tic
        for j = 1: n
            I   = read(movieobj, j);
            colormap gray
            [r c] = size(I);
            subplot(1,2,1);
            imagesc(I); axis equal;axis tight;
            subplot(1,2,2);
            imagesc(I); axis equal;axis tight;
            hold on
            %US = imresizeNN(us(:,:,j),size(I));
            %VS = imresizeNN(vs(:,:,j),size(I));
            US = us(:,:,j);
            VS = vs(:,:,j);
            US = medfilt2(US); % Median filter
            VS = medfilt2(VS); % Median filter
            uindex = find(US);
            ux = floor(uindex/100)+1;
            uy = mod(uindex,100);
            USi = US(uindex);
            VSi = VS(uindex);
            
            % Resize to get a clearer render
            xs = imresizeNN(xs,[50 50]);
            ys = imresizeNN(ys,[50 50]);
            US = imresizeNN(US,[50 50]);
            VS = imresizeNN(VS,[50 50]);
            
            quiver(xs, ys, US, VS, 5,'b');
            
            hold off
            pause(0.125);
            F = getframe(f);
            aviobj = addframe(aviobj,F.cdata);
            
        end
        toc
        aviobj = close(aviobj);
        disp('Video created');
    end
end
