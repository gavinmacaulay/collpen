function split_video_folder_in_clips(video_folder, seq_videos_txt, ...
                                     clip_length, clip_interval)
% This function divide an input video folder into several clips. 
% Videos are supposed to belong to different sequences in the way GoPro
% cameras produce them. Thus, an input text file (seq_videos_path) containint the assotiation
% between videos and sequences is expected with the following format:
% 1 Video1.avi
% 1 Video2.avi
% 2 VideoN.avi
% 3 VideoN+1.avi
% Where the first column coresponds to the video sequence Id and the second
% one to the video name
% 
% Videos are splitted according to the input params clip_length and 
% clip_interval.
%
% Video length (in hh:mm:ss) is estimated from the input video framerate
% Output clips will be placed in a folder under the sequence id and named 
% following an incremental numeric pattern
%
% clip_length and clip_interval are supposed to be in seconds

disp('[split_video_folder_in_clips] Start'); 

% Get video names grouped by sequences
[sequence_no videos] = read_txt(seq_videos_txt);
unique_seq = unique(sequence_no);

% Loop through the different sequences
for m = 1:length(unique_seq)
    % Videos in a sequence
    seq_video_index = sequence_no==m;
    
    % Create folder to contain sequence clips
    clips_folder = sprintf('%04d',unique_seq(m));
    clips_folder = [video_folder '/' clips_folder];
    if ~exist(clips_folder,'dir')
        disp(['[split_video_folder_in_clips] Creating folder' clips_folder]); 
        mkdir(clips_folder);
    end
    seq_videos = videos(seq_video_index);
    last_timestamp = 0;
    % Loop among the videos of a sequence
    for n = 1:length(seq_videos)
        video_name = seq_videos{n};
        video_name = [video_folder '/' video_name];
        last_timestamp = split_video_in_files(video_name, clips_folder, ...
                                              clip_length, clip_interval, ...
                                              last_timestamp);
                                       
    end
     
end

disp('[split_video_folder_in_clips] End'); 
end


function [num txt]= read_txt(seq_videos_txt)

fileID = fopen(seq_videos_txt);
file_data = textscan(fileID,'%d %s');
fclose(fileID);
num = file_data{1};
txt = file_data{2};
end