% Test split_video_folder_in_clips
clear all
close
video_folder    = '/Volumes/Datos/RedSlip';
seq_videos_txt  = '/Volumes/Datos/RedSlip/video_sync.txt';
clip_length    = 1; % duration of the clip in seconds
clip_interval  = 300; % time between clips in seconds

split_video_folder_in_clips(video_folder, seq_videos_txt, clip_length, clip_interval)


