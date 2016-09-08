function [frames predator_x predator_y frames_interpolated interp_x interp_y] = ...
    labelPredatorPosition(filepath, filename, predator_prey, start_frame,...
    end_frame, interpolate, save_data, debug, preview)
% This function allows to label the predator trajectory in a set of frames
% by just pointing a click the estimated position. If the predator is no
% present in the image, just press "enter" to skip that frame and let the
% interpolation do its job.
%
% This function also saves the generated output into a file
%
% Input:
%   - filepath : Folder with the file to be labeled
%   - filename : AVI file to be labeled
%   - predator_prey : Flag to select if a predator trajectory or prey
%   positions are to be labelled: 0 = predator ; 1 = prey
%   - start_frame : Initial frame of the sequence
%   - end_frame : Last frame of the sequence
%   - interpolate : 0 or 1. 1 means perform interpolation. If the parameter
%   is set to 0, output variables 'frames_interpolated interp_x interp_y'
%  contain a copy of frames, predator_x and predator_y, respectively.
%   - debug : 0 or 1. 1 displays information at the end
%   - save_data : 0 or 1. 1 saves the generated positions into a file named
%   filepath.mat (without .avi)
%   - preview: true if you simply want to walk through the file to check
%   start and end frames
%
% Output:
%   - frames : frames containing an actual predator
%   - predator_x : actual x coordinates of the predator
%   - predator_y : actual y coordinates of the predator
%   - frames_interpolated : all frames within the range
%   (min(frames),max(frames) with those with no predator interpolated
%   - interp_x : actual and interpolated x coordinates of the predator
%   - interp_y : actual and interpolated y coordinates of the predator
%
% Example:
% filepath = '/Volumes/Datos/collpen/videos/2013-07-17_100650.avi';
% end_frame = 1866;
% start_frame = 1840;
% interpolate = 1;
% debug = 1;
% save_data = 1;
% predator = 0;
%
% [frames pred_x pred_y frames_interp interp_x interp_y]  = ...
%   labelPredatorPosition(filepath, start_frame, predator, end_frame, ...
%   interpolate, save_data, debug);
%
% (c) Jose Carlos Castillo: jccmontoya@gmail.com


video_reader    = VideoReader(fullfile(filepath,filename));
RGB         = uint16(read(video_reader, 1));
nf          = min(video_reader.NumberOfFrames,end_frame);
[m n z]     = size(RGB);
Is          = zeros(m,n,nf);


predator_positions = [];

%current_img = zeros(m,n);

current_img = rgb2gray(read(video_reader, nf));
colormap gray
for i = nf:-1:start_frame-1
    img = rgb2gray(read(video_reader, i));
    subplot(1,2,2);
    imagesc(img);
    title(['Next frame: ' int2str(i)]);
    subplot(1,2,1);
    imagesc(current_img);
    if preview
        title(['Current frame: ' int2str(i+1)]);
        xlabel('Press any key for next frame');
    else
        title(['Current frame: ' int2str(i+1) '. Click here']);
        xlabel('If the predator is not presented, press return');
    end
    current_img = img;
    if(size(predator_positions,1)>0)
        hold on;
        plot(predator_positions(:,2),predator_positions(:,3), '-ro');
        hold off;
    end
    if preview
        predator_positions=[];
        pause
    else
        point = ginput(1);
        if(size(point,1)>0)
            predator_positions = [predator_positions ; [i+1 point]];
        end
    end
end

if(size(predator_positions,1)>0)
    hold on;
    plot(predator_positions(:,2),predator_positions(:,3), '-ro');
    hold off;
    
    
    %predator_positions
    predator_positions = sortrows(predator_positions,1);
    
    % Calculate and plot distance increment
    predator_positions_d = [predator_positions(1,:) ; predator_positions]; % duplicate first row
    
    distances = [];
    for i = 2:1:size(predator_positions_d,1)
        distance = sqrt((predator_positions_d(i,2)-predator_positions_d(i-1,2))^2 ...
            + (predator_positions_d(i,3)-predator_positions_d(i-1,3))^2);
        distances = [distances ; distance];
    end
    
    
    predator_y = predator_positions(:,3);
    frames = predator_positions(:,1);
    predator_x = predator_positions(:,2);
    
    frames_interpolated = frames;
    interp_x = predator_x;
    interp_y = predator_y;
    
    % Spline interpolation
    if(interpolate)
        xi = min(predator_positions(:,1)):1:max(predator_positions(:,1));
        frames_interpolated = xi';
        interp_y = spline(frames,predator_y,frames_interpolated);
        interp_x = spline(frames,predator_x,frames_interpolated);
    end
    
else
    frames = [];
    predator_x= [];
    predator_y= [];
    frames_interpolated= [];
    interp_x= [];
    interp_y= [];
end

if (save_data)&&~preview
    
    
    if(predator_prey==0)
        file_save = [filename(1:end-4) '_raw_predator_positions.mat'];
        fullpath = fullfile(filepath,'predator_position');
    else
        file_save = [filename(1:end-4) '_prey_positions.mat'];
        fullpath = fullfile(filepath,'prey_position');
    end
    
    if ~(exist(fullpath,'dir')==7)
        disp(['Creating data folder, ' fullpath]);
        mkdir(fullpath);
        
    end
    
    file_save = fullfile(fullpath,file_save);
    savePredatorPositions(file_save, frames, predator_x, predator_y,...
        frames_interpolated, interp_x, interp_y);
end

% Show results
if(debug)&&~preview
    subplot(1,2,2);
    hold on
    if(interpolate)
        title('Interpolated');
        plot(predator_x,predator_y,'r+');
        plot(interp_x,interp_y,'-go');
    else
        title('No interpolation applied');
        plot(predator_x,predator_y, '-ro');
        
    end
else close
end

end

function savePredatorPositions(file, frames, predator_x, predator_y, ...
    frames_interpolated, interp_x, interp_y)
% Save the input arguments into a file named after the content of 'file'

save(file, 'frames', 'predator_x', 'predator_y', 'frames_interpolated',...
    'interp_x', 'interp_y');

end
