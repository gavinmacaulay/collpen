function mask = mask_low_intensity(img, xs, ys)
% This function returns a matrix with the average windowed intenity of an
% image. Two input matrices (xs, ys) provide the indexes for the window
% (32x32 pixels) 

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