function change_video_framerate_resolution(input_video, output_video, ...
                                           frame_rate, target_height, ...
                                           target_width, init_frame, ...
                                           out_frame)
%
% This function changes the frame rate, resolution and length of an input 
% video. This features can be used all together or separately depending on
% the input params.
% If frame_rate equals 0, the output frame rate will be the same as the 
% input video frame rate                                      
% If either target_height or target_width equals 0 output resolution will 
% be the same as the input video  
% If init_frame or out_frame equals 0 the whole intput video will be
% processed
%
% EXAMPLE
%
% in_video = '/Volumes/Datos/RedSlip/Oxygen depletion experiment/2015-18-06/40%/11_15/GOPR0006.MP4';
% out_video = '/Volumes/Datos/RedSlip/Oxygen depletion experiment/2015-18-06/40%/11_15/GOPR0006_resized_fr.MP4';
% target_h = 540;
% target_w = 750;
% fr = 8;
% 
% change_video_framerate_resolution(in_video, out_video, fr, target_h, target_w, 100, 400);                                       
%                                        
                                       
video_reader = VideoReader(input_video);
video_writer = VideoWriter(output_video);

if frame_rate == 0
    video_writer.FrameRate = video_reader.FrameRate;
    fr_step = 1;
else
    video_writer.FrameRate = frame_rate;
    
    fr_step = round(video_reader.FrameRate/frame_rate);
    if fr_step <= 0
        % If the output framerate is higher than input, keep it the same
        disp('[change_video_framerate_resolution] Output framerate cannot be bigger than input. Keeping the same');
        video_writer.FrameRate = video_reader.FrameRate;
        fr_step = 1;
    end
end

if init_frame > out_frame 
    disp('[change_video_framerate_resolution] Initial frame must be smaller than final frame');
    return;
end

% If no initial or final frame are provided, process the whole video 
% sequence
if init_frame == 0 || out_frame == 0
    init_frame = 1;
    out_frame = video_reader.NumberOfFrames;
end
    


open(video_writer);

for i = init_frame:fr_step:out_frame
    disp(['[change_video_framerate_resolution]  Processing frame ' num2str(i - init_frame +1) ' of ' ...
           num2str(out_frame-init_frame)]);
       
    img = read(video_reader,i);
    if target_height ~= 0 || target_width ~= 0
        img = imresize(img,[target_height target_width]);
    end
    
    writeVideo(video_writer,img);
end

close(video_writer);
end

