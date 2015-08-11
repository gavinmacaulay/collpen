function flip_video_folder_horizontally(in_folder, out_folder, video_extension)

disp('[flip_video_folder_horizontally]: Start');


d = dir([in_folder '*.' video_extension]);

for i=1:length(d)
    file = d(i).name;
    
    in_video = [in_folder file];
    out_video = [out_folder file];
    flip_video_file_horizontally(in_video,out_video);
end

disp('[flip_video_folder_horizontally]: End');


end

function flip_video_file_horizontally(in_video, out_video)

video_reader = VideoReader(in_video);
video_writer = VideoWriter(out_video);

video_writer.FrameRate = video_reader.FrameRate;

open(video_writer);
for i=1:video_reader.NumberOfFrames
   img = read(video_reader,i);
   img = flipdim(img,2);
   writeVideo(video_writer,img);
end


close(video_writer);

end