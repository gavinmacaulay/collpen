function consecutive_frames_subtraction(video_in, video_out)

disp('[consecutive_frames_subtraction] Start');
video_reader = VideoReader(video_in);
video_writer = VideoWriter(video_out);
video_writer.FrameRate = video_reader.FrameRate;
open(video_writer);

I1 = read(video_reader,1);
end_frame = video_reader.NumberOfFrames; 
I1 = histeq(rgb2gray(I1));
for i = 2:end_frame
   disp(['[consecutive_frames_subtraction] Processing frame ' num2str(i) ' of ' num2str(end_frame-2)]);
   I2 = read(video_reader,i);
   
   Isub = abs(I2-I1); 
   writeVideo(video_writer,Isub);
   I1 = I2;
end

disp('[consecutive_frames_subtraction] End');
end