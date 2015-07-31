function comparison_result = compare_PIV_to_GT(PIVs_folder, GT_folder, ...
    source_video_folder, px_per_meter, frames_per_second)

% This function compares PIVs to the groundtruth. 
% The groundtruth should be generated with the script named test_prey_labeling.m
% For each ground truth file all videos matching its name are compared.


% Constants for unit conversion 
px_meter = px_per_meter;
fps      = frames_per_second;

if PIVs_folder(end)~='/'
    PIVs_folder = [PIVs_folder '/'];
end

if GT_folder(end)~='/'
    GT_folder = [GT_folder '/'];
end

if source_video_folder(end)~='/'
    source_video_folder = [source_video_folder '/'];
end


% Read prey files
d = dir([GT_folder '*_prey_positions.mat']);

prey_files = cell(length(d),1); % Preallocate to increase speed
for i = 1:length(d)
    prey_files{i} = d(i).name;
    source_file{i} = strrep(prey_files{i},'_prey_positions.mat', '');
end

% Read PIV files
d = dir([PIVs_folder '*_PIV.mat']);

PIV_files = cell(length(d),1); % Preallocate to increase speed
for i = 1:length(d)
    PIV_files{i} = d(i).name;
end

comparison_result = [];

% For each prey file, find the PIV files associated and process

for i = 1:length(source_file)
    inc_i = (i-1)*length(source_file);
    for j = 1:length(PIV_files)
        disp(PIV_files{j}); disp(source_file{i});
        % Match prey (source) files to PIV_files
        if strfind(PIV_files{j}, source_file{i})
            % Load prey data
            prey_file = [GT_folder prey_files{i}];
            load(prey_file);
            
            % Get PIV file path
            pivdatapath = [PIVs_folder PIV_files{j}];
            
            % Open source video
            source_video = [source_video_folder source_file{i} '.avi'];
            movieobj = VideoReader(source_video);
            
            % Compare PIVs to GT
            
            [PIVdata_angles PIVdata_ranges PIVdata_dotproduct ...
                PIV_relative_range] = checkPIV2(pivdatapath, frames,...
                predator_x, predator_y, px_meter, fps, '',...
                0, movieobj);
            
            % Save results for the current file
            comparison_result(inc_i + j).piv_file = PIV_files{j};
            comparison_result(inc_i + j).piv_folder = PIVs_folder;
            comparison_result(inc_i + j).angles = PIVdata_angles;
            comparison_result(inc_i + j).ranges = PIVdata_ranges;
            comparison_result(inc_i + j).dotproduct = PIVdata_dotproduct;
            comparison_result(inc_i + j).relative_range = PIV_relative_range;
        end
    end
end




end