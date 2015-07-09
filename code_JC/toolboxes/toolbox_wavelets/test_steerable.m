% test for steerable transform

n = 512;
name = 'barb';
name = 'turbulence';
M = load_image(name,n);

k = 4;
options.nb_orientations = k;
J = 4;
Jmax = log2(n)-1;
Jmin = Jmax-J+1;
MW = perform_steerable_transform(M,Jmin,options);
M2 = perform_steerable_transform(MW,Jmin,options);

save_image = 1;
rep = ['results/steerable/' name '/'];

if ~exist(rep)
    mkdir(rep);
end

% display and save the images
m = 0;
clf;
warning off;
for j=1:J
    for s=1:k
        m = m+1;
        subplot(k,J,m)
        imagesc(MW{m+1});
        axis image; axis off;
        str = ['j=' num2str(j) 's=' num2str(s)];
        title(str);
        if save_image
            imwrite(rescale(MW{m+1}), [rep name '_' str '.png'], 'png');        
            imwrite(rescale(MW{m+1}), [rep name '_' str '.jpg'], 'jpg');   
        end
    end
end
colormap gray(256);


if save_image
    imwrite(rescale(MW{1}), [rep name '_high.png'], 'png');
    imwrite(rescale(MW{end}), [rep name '_low.png'], 'png');
end

warning on;