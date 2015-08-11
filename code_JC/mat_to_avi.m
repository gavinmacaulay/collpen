function mat_to_avi(mat_data,avi_out,frame_rate,init_frame,end_frame)
% This function render the information contained in a 3 dimensonal matrix
% into an avi file. The third dimension of the matrix must index the
% samples that will be translated into frames.
%
% If init_frame or end_frame equals -1 the whole video length will be
% rendered. Otherwise, the output video will be rendered according to the
% input length.
%
% This function was intially thought to work with the information coming
% from ddf files containing ultrasound data.
%
% EXAMPLE
%
% avi_out = 'video.avi';
% frame_rate = 10;
% mat_imgs = [];
% for i =1:100
%     y = linspace(10,i*2,640);
%     mat_imgs(:,:,i) = repmat(y,480,1);  
% end
% mat_to_avi(mat_imgs,avi_out,frame_rate);

disp(['[polar_mat_to_avi] Generating file ' avi_out]);

video_writer = VideoWriter(avi_out);
video_writer.FrameRate = frame_rate;
open(video_writer);

[fr, ~, ~] = size(mat_data);

if(init_frame == -1 || end_frame == -1)
    init_frame = 1;    
    end_frame = fr;
elseif (end_frame > fr)
    end_frame = fr;
end


for i = init_frame:end_frame
    img = uint8(mat_data(i,:,:));
    img = squeeze(img);
    img = imrotate(img,180);
    writeVideo(video_writer,img);
end

close(video_writer)

end