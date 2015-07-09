function I = normalizeSonarImage(img)

[h w] = size(img);
img = double(img);

% Normalize sonar image according to the factor 20*Log(r)
a = 20 * log(h);
for i = 1:h
    I(i,:) = img(i,:) * 20 * log(h-i+1); % h-i+1 instead of i because the y axis is inverted (avoid computation overflow due to rotating the image twice)
end

I = I/a; % Normalize in the range [0-255]
end