function next_clip_in_seconds = split_video_in_files(video_in,out_folder, ...
    clip_length, clip_interval, start_in_second)
% This function divide an input video into several clips according to the
% input params (clip_length, clip_interval).
% Video length (in hh:mm:ss) is estimated from the input video framerate
% Output clips will be placed in the out_folder with the following naming
% scheme: video_name-init_time-end_time.avi
% Thus to allow easy matching with the main video independently from the
% frame_rate clip_length and clip_interval are supposed to be in seconds

disp('[split_video_in_files] Start');

%clips_folder = video_in(1:end-4);

if ~exist(out_folder,'dir')
    disp(['[split_video_in_files] Creating folder' out_folder]);
    mkdir(out_folder);
end

video_reader = VideoReader(video_in);
frame_rate = video_reader.FrameRate;

video_split = regexp(video_in,'/','split');
video_name = video_split{end};
video_name = video_name(1:end-4);

if length(out_folder) == 0
    out_folder == '/';
elseif ~(out_folder(end) == '/')
    out_folder = [out_folder '/'];
end

if start_in_second > 1
    init_frame = start_in_second * frame_rate;
else init_frame = 1;
end

interval_frames = frame_rate * clip_interval;
clip_frames = clip_length * frame_rate;
for i = init_frame:interval_frames:video_reader.NumberOfFrames
    disp(['[split_video_in_files] Creating clip ' num2str(round(i/interval_frames + 1)) ' of ' ...
        num2str(round(video_reader.NumberOfFrames/interval_frames +1))]);
    
    init_timestamp = round(i/frame_rate);
    end_timestamp = init_timestamp + clip_length;
    
    if end_timestamp <= video_reader.Duration
        clip_name = [out_folder video_name '_' sprintf('%05d', init_timestamp) '-' ...
            sprintf('%05d',end_timestamp)];
        
        video_writer = VideoWriter(clip_name);
        video_writer.FrameRate = frame_rate;
        open(video_writer);
        
        
        
        for j = 1:round(clip_frames)
            disp([num2str(j) '/' num2str(round(clip_frames))]);
            
            % displacement to create the clips
            img = read(video_reader,i+j);
            writeVideo(video_writer,img);
        end
        close(video_writer);
    end
end

next_clip_in_seconds = round((video_reader.NumberOfFrames-i)/frame_rate);
disp('[split_video_in_files] End');
end

