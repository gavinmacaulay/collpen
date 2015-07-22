function render_video_from_pivs_and_filtered(video_file, mat_file, ...
                                             destination_file)

% This function merges an input video with the PIV sequence calculated from
% it into an output video that overlais the PIVs as arrows on top of the
% input images.
%
% The way it is done, it is necessary to keep the figure allways in the
% screen and not to place any other window on top of it. If so, the window
% on top will be included in the video causing weird results

map = createcolormap([1 2 10 48 64], [255 255 128 ; 255 255 0 ; ...
                                      255 153 0 ; 255 0 0 ; 0 0 0]);

input_video = VideoReader(video_file);
load(mat_file);

output_video = avifile(destination_file, 'compression', 'none', 'fps', 8);
disp(['Creating PIV avi in ' destination_file]);
tic
%f = figure;
f = figure('units','normalized','outerposition',[0 0 1 1])
for i = 2000:2500%input_video.NumberOfFrames-1
    I = read(input_video,i);
   % colormap gray
    xs_frame = xs(:,:,i);
    ys_frame = ys(:,:,i);
    mask = mask_low_intensity(I, xs_frame, ys_frame);
    mask(find(mask(:)<8))=0;
    

    [r c] = size(I);
%     subplot(1,2,1);
     imagesc(I); axis equal;axis tight;
% %     subplot(1,2,2);
%     I2 = (I.*0)+255;
%     imagesc(I2); axis equal;axis tight;
    hold on

    US = us(:,:,i).*mask;
    VS = vs(:,:,i).*mask;
    US = medfilt2(US); % Median filter
    VS = medfilt2(VS); % Median filter
    uindex = find(US);
    ux = floor(uindex/100)+1;
    uy = mod(uindex,100);
    USi = US(uindex);
    VSi = VS(uindex);
    
    % Resize to get a clearer render
    xs_frame = imresizeNN(xs_frame,[50 50]);
    ys_frame = imresizeNN(ys_frame,[50 50]);
    US = imresizeNN(US,[50 50]);
    VS = imresizeNN(VS,[50 50]);
    
    %plot PIVs
    colormap(map);
    quiver(xs_frame, ys_frame, US, VS,3);
    %colorbar;
    hold off
    pause(0.125);
    F = getframe(f);
    output_video = addframe(output_video,F.cdata);
    
    set(gcf,'PaperPositionMode','auto');
    index = sprintf('%04d',i);
    print('-dpng', [index '.png']);
end
toc
output_video = close(output_video);
disp('Video created');
end


function mask = mask_low_intensity(img, xs, ys)

xs_win_min = xs - 16 + 1;
xs_win_max = xs + 16;
ys_win_max = ys + 16;
ys_win_min = ys - 16 + 1;

[r c] = size(xs);
[a b n] = size(img);
if(n>1)
    img = rgb2gray(img); 
end
mask = zeros(r,c);

for i = 1:r
    for j = 1:c
        img2 = img(ys_win_min(i,j):ys_win_max(i,j),xs_win_min(i,j):xs_win_max(i,j));
        mask(i,j) = mean(img2(:));
    end
end

end