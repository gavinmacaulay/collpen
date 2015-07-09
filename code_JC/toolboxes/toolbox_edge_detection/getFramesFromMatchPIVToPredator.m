function getFramesFromMatchPIVToPredator(folder, file, wsize)

% Load predator data
% Check if predator info is available
matPath = strrep(file,'.avi','_interp_extrap_path.mat');
matPath = [folder 'predator_position/' matPath];
if exist(matPath,'file')~=2
    disp(['matchPIVToPredator: mat file not found in path: ' matPath]);
    disp('Skipping...');
    return;
end
load(matPath);


% Load PIV matched data
pivdatapath   = strrep([folder 'PIVdata/'  file],'.avi','_match_PIV_predator.mat');
if exist(pivdatapath,'file')~=2
    disp(['matchPIVToPredator: PIV data file not found in path: ' pivdatapath]);
    disp('Skipping...');
    return;
end
load(pivdatapath);


% Images folder
datafolder = [folder 'PIVdata/'];
savedatafolder = strrep(file,'.avi','/');
savedatafolder = [datafolder savedatafolder];
if ~(exist(savedatafolder,'dir')==7)
    disp(['Creating data folder, ' savedatafolder]);
    mkdir(savedatafolder);
end


piv_score_threshold = 0.25;
piv_intensity_threshold = 50;
color_samples = 128;
cmap = colormap(hsv(color_samples)); % Create a color map based on hsv with 32 values

filepath = [folder file];
movieobj = VideoReader(filepath);

% Load predator info
frames = frame_pixel_info(:,1);
predator_x = frame_pixel_info(:,2);
predator_y = frame_pixel_info(:,3);
interp_extrap = frame_pixel_info(:,4);

f1 = figure('Units','normalized','Position',[0 0 0.5 1]);
f2 = figure('Units','normalized','Position',[0.5 0 0.5 1]);

for j = 1: length(predator_x)-1
    pred_x = predator_x(j);
    pred_y = predator_y(j);
    pred_u = predator_x(j+1)-predator_x(j);
    pred_v = predator_y(j+1)-predator_y(j);
    frame = frames(j);
    interp = interp_extrap(j);
    
    savepath_half_wsize = [savedatafolder file];
    savepath_half_wsize = strrep(savepath_half_wsize,'.avi',['_' int2str(frame) '_' int2str(wsize) '_half_wsize.png']);
    
    savepath_score = [savedatafolder file];
    savepath_score = strrep(savepath_score,'.avi',['_' int2str(frame) '_' int2str(wsize) '_score.png']);
    
    
    I = read(movieobj, frames(j));
    [r c n] = size(I);
    if(n>1)
        I = rgb2gray(I);
    end
    
    
    % Get pivs from current frame
    d = D(:,1);
    index = d==frame;
    curr_frame_data = D(index,:);
    
    
%     % Render figure with full window size mean
%     ind = ~isnan(curr_frame_data(:,10)) & ~isnan(curr_frame_data(:,8)); % full window size mean intensity
%     
%     piv_x = curr_frame_data(:,6);
%     piv_y = curr_frame_data(:,7);
%     piv_u = curr_frame_data(:,8);
%     piv_v = curr_frame_data(:,9);
%     piv_full_window = curr_frame_data(:,10);
%     piv_score = curr_frame_data(:,12);
%     piv_border = curr_frame_data(:,13);
% 
%     piv_x = piv_x(ind);
%     piv_y = piv_y(ind);
%     piv_u = piv_u(ind);
%     piv_v = piv_v(ind);
%     piv_full_window = piv_full_window(ind);
%     piv_score = piv_score(ind);
%     piv_border = logical(piv_border(ind));
%     
%     
%     % Discard PIVs touching the FOV border
%     piv_x = piv_x(~piv_border);
%     piv_y = piv_y(~piv_border);
%     piv_u = piv_u(~piv_border);
%     piv_v = piv_v(~piv_border);
%     piv_full_window = piv_full_window(~piv_border);
%     piv_score = piv_score(~piv_border);
%     
%     
%     
%     % Threshold PIVs by average intensity
%     intensity_index = piv_full_window>=50;
%     
%     % Discard PIVs belonging to low intensity windows
%     piv_x = piv_x(intensity_index);
%     piv_y = piv_y(intensity_index);
%     piv_u = piv_u(intensity_index);
%     piv_v = piv_v(intensity_index);
%     piv_score = piv_score(intensity_index);
%     piv_full_window = piv_full_window(intensity_index);
%     
%     % Weigth PIVs by score (and create color code)
%     % Normalize score 
%     piv_score = piv_score/max(piv_score(:));
%     
%    % piv_u = piv_u .* piv_score;
%    % piv_v = piv_v .* piv_score;
%     
%     for i = 1:length(piv_x)
%         lower_bound_x = piv_x(i)-wsize/4;
%         if(lower_bound_x<1)
%             lower_bound_x = 1;
%         end
%         
%         lower_bound_y = piv_y(i)-wsize/4;
%         if(lower_bound_y<1)
%             lower_bound_y = 1;
%         end
%         
%         upper_bound_x = piv_x(i)+wsize/4;
%         if(upper_bound_x > c)
%             upper_bound_x = c;
%         end
%         
%         upper_bound_y = piv_y(i)+wsize/4;
%         if(upper_bound_y > r)
%             upper_bound_y = r;
%         end
%         I(lower_bound_y:upper_bound_y,lower_bound_x:upper_bound_x) = piv_full_window(i);
%     end
%     
%     



    ind = ~isnan(curr_frame_data(:,11)) & ~isnan(curr_frame_data(:,8)); % half window size mean intensity
    
    piv_x = curr_frame_data(:,6);
    piv_y = curr_frame_data(:,7);
    piv_u = curr_frame_data(:,8);
    piv_v = curr_frame_data(:,9);
    piv_half_window = curr_frame_data(:,11);
    piv_score = curr_frame_data(:,12);
    piv_border = curr_frame_data(:,13);

    piv_x = piv_x(ind);
    piv_y = piv_y(ind);
    piv_u = piv_u(ind);
    piv_v = piv_v(ind);
    piv_score = piv_score(ind);
    piv_half_window = piv_half_window(ind);
    piv_border = logical(piv_border(ind));
    
    
    % Discard PIVs touching the FOV border
    piv_x = piv_x(~piv_border);
    piv_y = piv_y(~piv_border);
    piv_u = piv_u(~piv_border);
    piv_v = piv_v(~piv_border);
    piv_half_window = piv_half_window(~piv_border);
    piv_score = piv_score(~piv_border);
    
    % Threshold PIVs by average intensity
    intensity_index = piv_half_window>=piv_intensity_threshold;
    
    % Discard PIVs belonging to low intensity windows
    piv_x = piv_x(intensity_index);
    piv_y = piv_y(intensity_index);
    piv_u = piv_u(intensity_index);
    piv_v = piv_v(intensity_index);
    piv_score = piv_score(intensity_index);
    piv_half_window = piv_half_window(intensity_index);
    
    
    %Weigth PIVs by score (and create color code)
    
   %piv_u = piv_u .* piv_score;
   %piv_v = piv_v .* piv_score;
    
    
        for i = 1:length(piv_x)
            lower_bound_x = piv_x(i)-wsize/4;
            if(lower_bound_x<1)
                lower_bound_x = 1;
            end
    
            lower_bound_y = piv_y(i)-wsize/4;
            if(lower_bound_y<1)
                lower_bound_y = 1;
            end
    
            upper_bound_x = piv_x(i)+wsize/4;
            if(upper_bound_x > c)
                upper_bound_x = c;
            end
    
            upper_bound_y = piv_y(i)+wsize/4;
            if(upper_bound_y > r)
                upper_bound_y = r;
            end
            I(lower_bound_y:upper_bound_y,lower_bound_x:upper_bound_x) = piv_half_window(i);
        end
    
    clf(f1,'reset');
    imagesc(I);  axis equal; axis tight; colormap gray;
    hold on;
    freezeColors
    colormap hsv
    for i = 1:length(piv_x)
        score = piv_score(i)/max(piv_score(:));
        color_index = round(score*color_samples);
        quiver(piv_x(i),piv_y(i),piv_u(i),piv_v(i),2,'color', cmap(color_index,:));
    end
    colorbar;
    %quiver(piv_x,piv_y,piv_u,piv_v,2);
    
    if(interp == 1)
        quiver(pred_x,pred_y,pred_u,pred_v,2,'w');
    else
        quiver(pred_x,pred_y,pred_u,pred_v,2,'k');

    end
    print('-dpng','-r500',savepath_half_wsize);
    
    % Render figure with half window size
    
    I = read(movieobj, frames(j));
    [r c n] = size(I);
    if(n>1)
        I = rgb2gray(I);
    end
    
    ind = ~isnan(curr_frame_data(:,11)) & ~isnan(curr_frame_data(:,8)); % half window size mean intensity
    
    piv_x = curr_frame_data(:,6);
    piv_y = curr_frame_data(:,7);
    piv_u = curr_frame_data(:,8);
    piv_v = curr_frame_data(:,9);
    piv_half_window = curr_frame_data(:,11);
    piv_score = curr_frame_data(:,12);
    piv_border = curr_frame_data(:,13);

    piv_x = piv_x(ind);
    piv_y = piv_y(ind);
    piv_u = piv_u(ind);
    piv_v = piv_v(ind);
    piv_score = piv_score(ind);
    piv_half_window = piv_half_window(ind);
    piv_border = logical(piv_border(ind));
    
    
    % Discard PIVs touching the FOV border
    piv_x = piv_x(~piv_border);
    piv_y = piv_y(~piv_border);
    piv_u = piv_u(~piv_border);
    piv_v = piv_v(~piv_border);
    piv_half_window = piv_half_window(~piv_border);
    piv_score = piv_score(~piv_border);
    
    
    
    % Threshold PIVs by score
    intensity_index = piv_score>=piv_score_threshold;
    
    % Discard PIVs belonging to low score
    piv_x = piv_x(intensity_index);
    piv_y = piv_y(intensity_index);
    piv_u = piv_u(intensity_index);
    piv_v = piv_v(intensity_index);
    piv_score = piv_score(intensity_index);
    piv_half_window = piv_half_window(intensity_index);
    
    
    %Weigth PIVs by score (and create color code)
    
   %piv_u = piv_u .* piv_score;
   %piv_v = piv_v .* piv_score;
    
    
        for i = 1:length(piv_x)
            lower_bound_x = piv_x(i)-wsize/4;
            if(lower_bound_x<1)
                lower_bound_x = 1;
            end
    
            lower_bound_y = piv_y(i)-wsize/4;
            if(lower_bound_y<1)
                lower_bound_y = 1;
            end
    
            upper_bound_x = piv_x(i)+wsize/4;
            if(upper_bound_x > c)
                upper_bound_x = c;
            end
    
            upper_bound_y = piv_y(i)+wsize/4;
            if(upper_bound_y > r)
                upper_bound_y = r;
            end
            I(lower_bound_y:upper_bound_y,lower_bound_x:upper_bound_x) = piv_half_window(i);
        end
    
    
    
    
    clf(f2,'reset');
    imagesc(I);  axis equal; axis tight; colormap gray;
    hold on;
    %quiver(piv_x,piv_y,piv_u,piv_v,2);
        freezeColors
    colormap hsv
    for i = 1:length(piv_x)
        score = piv_score(i)/max(piv_score(:));
        color_index = round(score*color_samples);
        quiver(piv_x(i),piv_y(i),piv_u(i),piv_v(i),2,'color', cmap(color_index,:));
    end
    colorbar;
    
    if(interp == 1)
        quiver(pred_x,pred_y,pred_u,pred_v,2,'w');
    else
        quiver(pred_x,pred_y,pred_u,pred_v,2,'k');

    end
    print('-dpng','-r200',savepath_score);
    
    
end

end


