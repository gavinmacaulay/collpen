function [frames, distances, pos_x, pos_y, angles, interp_extrap] = boundariesDetectionRayTracing(filepath, filename, bg_image,preprocessing_params, boundary_detection_params, ~, debug)

avipath = [filepath filename];

% check if input avi exists
if(exist(avipath,'file')~=2)
    display(['[boundariesDetectionRayTracing] Aborting... avi file does not exist: ' filepath]);
    return;
end

movieobj = VideoReader(avipath);


RGB         = uint16(read(movieobj, 1));
nf          = movieobj.NumberOfFrames;
[m, n, z]     = size(RGB);
Is          = zeros(m,n,nf);

predator_data_path = strrep(filename,'.avi','_interp_extrap_path.mat');

predator_data_path = [filepath 'predator_position/' predator_data_path];

% Check if predator positions file exist
if(exist(predator_data_path,'file')~=2)
    display(['[boundariesDetectionRayTracing] Aborting... Predator data file does not exist: ' predator_data_path]);
    return;
end
load(predator_data_path);

frames = [];
distances = [];
pos_x = [];
pos_y = [];
angles = []; 
interp_extrap = [];

bg_image = uint8(normalizeSonarImage(bg_image));

for i = 1:size(frame_pixel_info,1)-1
    pred_vector =  [frame_pixel_info(i,2) , frame_pixel_info(i,3) , frame_pixel_info(i+1,2) , frame_pixel_info(i+1,3)];
    pred_vector = round(pred_vector);
    
    I = rgb2gray(read(movieobj,frame_pixel_info(i,1)));
    I = uint8(normalizeSonarImage(I));
    
    if(preprocessing_params.debug)
       pause(0.1);
       figure(1);
    end
    I_filtered = imagePreprocess(I, bg_image, preprocessing_params);
    
    I_filtered = createCircularMask(I_filtered, pred_vector(1), pred_vector(2), boundary_detection_params.min_range);
    
    if(debug)
        figure(2);    
    end
    
    [dist, x, y, ang] = getBoundaries(I_filtered, pred_vector, boundary_detection_params.angle, boundary_detection_params.beams,debug);
    
    frame(1:size(dist,2),1) = frame_pixel_info(i,1);
    int_ext(1:size(dist,2),1) = frame_pixel_info(i,4);

    frames = [frames ; frame];
    distances = [distances ; dist'];
    pos_x = [pos_x ; x'];
    pos_y = [pos_y ; y'];
    angles = [angles ; ang'];
    interp_extrap = [interp_extrap ; int_ext];
    
    if(debug)
        figure(3);
        axis equal
        subplot(1,2,1);
        colormap pink
        imagesc(I);
        hold on;
        %quiver(pred_vector(1),pred_vector(2),pred_vector(3)-pred_vector(1),pred_vector(4)-pred_vector(2));
        quiver(pred_vector(1),pred_vector(2),(pred_vector(3)-pred_vector(1)), (pred_vector(4)-pred_vector(2)),2);
        plot(x, y, '.','markerSize',8);  %Plot found edges
        title('Vectors');
        subplot(1,2,2);
        xlim([-boundary_detection_params.angle/2 boundary_detection_params.angle/2]);
        plot(ang,dist, 'color', 'b');
        hold on
        smooth_distances = smooth(dist,30,'lowess');
        plot(ang,smooth_distances, 'color' , 'r');
        title('Detected edges');
        ylabel('Range');
        xlabel('Angle');
        hold off
    end
    
end

end


function img = createCircularMask(I, px, py, r)

imageSize = size(I);
ci = [py, px, r];     % center and radius of circle ([c_row, c_col, r])
[xx,yy] = ndgrid((1:imageSize(1))-ci(1),(1:imageSize(2))-ci(2));
mask = uint8((xx.^2 + yy.^2)<ci(3)^2);
mask = 1-mask;
img = uint8(zeros(size(I)));
img(:,:) = I(:,:).*logical(mask);

%imagesc(img);

end
