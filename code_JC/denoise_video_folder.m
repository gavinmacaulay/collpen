function denoise_video_folder(folder, denoising_method, denoising_param,...
                              denoising_label)
%                           
% This function applies a series of denoising techniques to a whole video 
% folder. Output videos are arranged in directories according to the 
% denoising technique employed.
%                           
% Check preprocessingSonarImage function for information about the 
% available denoising techniques and their parameters                      
%                           
%                           
% EXAMPLE 1                          
%                           
% video_folder = '/Volumes/Datos/collpen/data/block1/didson/';
% denoising_method = 0;
% denoising_params = 0;
% denoising_label = 'bg_sub';
% 
% denoise_video_folder(video_folder,denoising_method,denoising_params,...
%                      denoising_label);                          
%   
% 
% EXAMPLE 2
% 
% denoising_techniques_name{1}  = [];
% denoising_techniques_name{2}  = [];
% denoising_techniques_name{3}  = [];
% 
% 
% denoising_techniques = [
%    -1,0;    % Raw images
%     0,0;    % Background subtraction + normalization
%     1,0;    % Gaussian
%     ];
% 
% denoising_techniques_name{1}  = '01-Raw images-filter';
% denoising_techniques_name{2}  = '02-Background_subtraction_+_normalization_filter';
% denoising_techniques_name{3}  = '03-Gaussian-filter';
% 
% video_folder = '/Volumes/Datos/collpen/predator/test/';
% 
% for i = 1: length(denoising_techniques)
%     if(~cellfun(@isempty,denoising_techniques_name(i)))
%         denoise_video_folder(video_folder,denoising_techniques(i,1),...
%                              denoising_techniques(i,2),...
%                              denoising_techniques_name{i});
%     end
% end
% 
                          
disp('[denoise_video_folder]: Start');


if folder(end)~='/'
    folder = [folder '/'];
end

d=dir([folder '*.avi']);
for i = 1: length(d)
    disp(['Denoising video file' d(i).name]);
    disp('Load bg image for video file');
    try
        bg_image = load_bg_image(folder, d(i).name);
    catch
        disp(['>>> Background image not found: ' d(i).name]);
        continue;
    end
    
    % create folder for saving denoised video
    save_path = [folder 'denoised/'];
    if~(exist(save_path,'dir')==7)
        disp(['Creating data folder: ' save_path]);
        mkdir(save_path);
    end
    
    save_path = [save_path d(i).name];
    video_path = [folder d(i).name];
    denoise_file(video_path, save_path, bg_image, denoising_method, ...
                 denoising_param, denoising_label)
end
end

%%
function denoise_file(load_video_path, save_video_path, bg_image, ...
                      denoising_method, denoising_param, denoising_label)

disp(['Opening' load_video_path]); 
movieobj = VideoReader(load_video_path);
denoised_video_path = strrep(save_video_path, '.avi', ...
                             ['___' denoising_label '.avi']);
writeobj = VideoWriter(denoised_video_path);
writeobj.FrameRate=movieobj.FrameRate;
open(writeobj);

for i = 1:movieobj.NumberOfFrames
    disp(['Denoising frame ' num2str(i) ' of ' ...
          num2str(movieobj.NumberOfFrames)]);
    img = read(movieobj,i);
    if(ndims(img)==3)
        img = rgb2gray(img);
    end
    img_denoised = denoise_frame(img, bg_image, denoising_method, ...
                                 denoising_param);
    img_denoised = uint8(img_denoised);
%     compare_denoised(img, img_denoised);
    writeVideo(writeobj,img_denoised);
    pause(0.1);
end

close(writeobj);

end

%%
function compare_denoised(img, img_denoised)
    subplot(1,3,1);
    imagesc(img);
    title('Original')
    axis equal;axis tight;
    subplot(1,3,2);
    imagesc(img_denoised);
    title('Denoised');
    axis equal;axis tight;
    subplot(1,3,3);
    imagesc(abs(img-img_denoised));
    title('difference');
    axis equal;axis tight;
    colormap gray;
end

%%
function I= denoise_frame(img, bg_image, denoising_method, denoising_param)

    I = preprocessingSonarImage(img,bg_image,denoising_method,...
                                denoising_param,0,0);
end


%%
function bg_image = load_bg_image(folder, avifilename)
    bgpath = [folder 'PIVdata/' avifilename];
    bgpath = strrep(bgpath, '.avi','_BG.bmp');
    bg_image=imread(bgpath);
end