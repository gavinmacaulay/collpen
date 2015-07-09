function video_to_image_files(video_path)

% This function split the input video into frames and save them to disk.
% Output frames will be written into the same directory as the input video
% with png extension

disp(['[video_to_image_files] Opening' video_path]); 
movieobj = VideoReader(video_path);

for i = 1:movieobj.NumberOfFrames
    img = read(movieobj,i);
    index = sprintf('%04d',i);
    imwrite(img,[index '.png']);    
end
disp(['[video_to_image_files] Done! ' num2str(i) ' files saved to disk']);