%% Split video into frames with predator position

filepath = '/Volumes/Datos/collpen/predator/brown_net/seq1/';
d = dir([filepath '*.avi']);

for i=1:length(d)
    
    filename = d(i).name;
    avipath = [filepath filename];

    predator_data_path = strrep(filename,'.avi','_interp_extrap_path.mat');
    predator_data_path = [filepath 'predator_position/' predator_data_path];
    % Check if predator positions file exist
    if(exist(predator_data_path,'file')~=2)
        display(['Aborting... Predator data file does not exist: ' predator_data_path]);
        return;
    end
    load(predator_data_path);
    
    
    new_dir = strrep(d(i).name,'.avi','');
    new_dir = [filepath new_dir '/'];
    
    if ~(exist(new_dir,'dir')==7)
        disp(['Creating data folder, ' new_dir]);
        mkdir(new_dir);
        
    end
    
    movieobj = VideoReader(avipath);
    
    
    RGB         = uint16(read(movieobj, 1));
    nf          = movieobj.NumberOfFrame;
    [m, n, z]     = size(RGB);
    Is          = zeros(m,n,nf);
    
    for j = 1:size(frame_pixel_info,1)
        
        pred_vector =  [frame_pixel_info(j,2) , frame_pixel_info(j,3)];
        pred_vector = round(pred_vector);
        I = rgb2gray(read(movieobj,frame_pixel_info(j,1)));
        if(frame_pixel_info(j,4) == 1)
            color = uint8([255 0 0]);  % [R G B]; extrapolated positions in red
        else
            color = uint8([0 255 0]); % Smoothed positions in green
        end
        
        markerInserter = vision.MarkerInserter('Shape','Circle','BorderColor','Custom','CustomBorderColor',color);
        RGB = repmat(I,[1 1 3]); % convert the image to RGB        
        J = step(markerInserter, RGB, int32(pred_vector));
        %imshow(J);
        
        save_file = [new_dir int2str(frame_pixel_info(j,1)) '.jpg'];
        imwrite(J, save_file,'jpg');
        
    end
    
    
end