function enhance_video_contrast(input_video, output_video)
% This function applies a histogram equalization to enhance the contrast in
% a video sequence.

disp('[enhance_video_contrast] Start');

video_reader = VideoReader(input_video);
video_writer = VideoWriter(output_video);
video_writer.FrameRate = video_reader.FrameRate;
open(video_writer);

for i = 1:video_reader.NumberOfFrames
    disp(['[enhance_video_contrast] Processing frame ' num2str(i) ' of '...
          num2str(video_reader.FrameRate)]);

    img = read(video_reader,i);
    img = histeq(rgb2gray(img));
    writeVideo(video_writer,img);
end
disp('[enhance_video_contrast] End');
end