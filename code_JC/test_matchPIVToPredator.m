%%
close all
[r c n] = size(xs);
for i = 1:n
    x = xs (:,:,i);
    y = ys (:,:,i);
    u = us (:,:,i);
    v = vs (:,:,i);
    
    quiver(x,y,u,v,10);axis equal; axis tight;
    set(gca,'YDir','reverse');
end


%%
close all
I = zeros(100,100);
wsize = 16;
x = 16;
y = 8;

lowerx = x-wsize/2;
lowery = y-wsize/2;
upperx = x+wsize/2;
uppery = y+wsize/2;

if (lowerx <=0)
    lowerx=1 ;
end

if (lowery <=0)
    lowery=1 ;
end

I(lowery:uppery,lowerx:upperx) = 255;
imagesc(I); axis equal; axis tight; colormap gray;
hold on
quiver(x,y,20,20);
keyboard


%% Script to test matching PIVs to predator positions from folder
clear
close all
clc

folder              = '/Volumes/Datos/collpen/predator/test/';
wsize               = 32;
fps                 = 8;
fov_left1           = [3,26]; %Points to define sonar Field of View
fov_left2           = [186,745];
fov_right1          = [399,26];
fov_right2          = [216,745];
denoising_method    = -1; % keep raw images
denoising_param     = 0;

d=dir([folder '*.avi']);

for i = 1:length(d)
    file = d(i).name;
    [frame_acc pred_x_acc pred_y_acc pred_u_acc pred_v_acc piv_x_acc piv_y_acc ... 
        piv_u_acc piv_v_acc intensity_wsize_acc intensity_half_wsize_acc score_acc fov_limit_acc] =...
        matchPIVToPredator(folder, file, wsize, fps, denoising_method, denoising_param, fov_left1, fov_left2, fov_right1, fov_right2);
    
    savepath = strrep(file,'.avi','_match_PIV_predator.mat');
    savepath = [folder '/PIVdata/' savepath];
    
    if(size(frame_acc,1) > 0)
        D = [frame_acc pred_x_acc pred_y_acc pred_u_acc pred_v_acc piv_x_acc piv_y_acc ... 
            piv_u_acc piv_v_acc intensity_wsize_acc intensity_half_wsize_acc score_acc fov_limit_acc];
        
        save(savepath,'D','wsize','fps');
    end
    
end

%% Render frames with PIV/mean intensity info
folder = '/Volumes/Datos/collpen/predator/test/';

d=dir([folder '*.avi']);
wsize = 32;
for x = 1%:length(d);
    close all
    getFramesFromMatchPIVToPredator(folder, d(x).name,wsize)
end


%% Script to merge all PIV matching matrices into a single file

folder = '/Volumes/Datos/collpen/predator/test/PIVdata/';

d=dir([folder '*_match_PIV_predator.mat']);
E = [];


for i=1:size(d,1)
    i
    load([folder d(i).name]);
    rows = size(D,1);

    E = [E ; [repmat(i,rows,1) D]];
    
end
savepath = [folder 'merged_match_PIVdata_16.mat'];
save(savepath,'E','wsize','fps');

%% Script to plot  PIV projection vs Predator position
close all
clear
folder = '/Volumes/Datos/collpen/predator/test/PIVdata/'
datapath = [folder 'merged_match_PIVdata.mat'];

load(datapath);

rows = size(E,1);

projection  = [];
angle = [];
direction   = [];

for i=1:rows
    pred_u = E(i,7) - E(i,3);
    pred_v = E(i,8) - E(i,4);
    piv_u  = E(i,9);
    piv_v  = E(i,10);
    
    %angle = [angle ; cosd(getAngleTwoVectors([pred_u,pred_v],[piv_u,piv_v]))];
    
pred_module = sqrt((pred_u)^2 + (pred_v)^2);
piv_module  = sqrt(piv_u^2 + piv_v.^2); 
dot_product = dot([pred_u , pred_v],[piv_u piv_u]);
projection  = [projection ; [pred_module , (dot_product/pred_module)]]; 
direction   = [direction ; [pred_module , dot_product/(pred_module*piv_module)]];
end
keyboard
plot(projection(:,1), projection(:,2),'*');
figure; 
plot(direction(:,1),direction(:,2),'*');
%figure;
%plot(projection(:,1),angle);

%% Script to plot  PIV projection vs Predator position
close all
folder = '/Volumes/Datos/collpen/predator/test/PIVdata/'
datapath = [folder 'merged_match_PIVdata.mat'];

load(datapath);

rows = size(E,1);
score  = E(:,13);
index_score  = score<0.25;
index_border = logical(E(:,14));
index = index_score | ~index_border;

pred_u = E(:,7) - E(:,3);
pred_v = E(:,8) - E(:,4);
piv_u  = E(:,9);
piv_v  = E(:,10);

pred_module = hypot(pred_u,pred_v);
piv_module  = hypot(piv_u, piv_v);

hypot(pred_u./pred_module,pred_v./pred_module)

dot_product = pred_u.*piv_u + pred_v.*piv_v;
projection  = [pred_module , (dot_product./pred_module)];
direction   = [pred_module , dot_product./(pred_module.*piv_module)];

pred_u2 = pred_u(index);
pred_v2 = pred_v(index);
piv_u2  = piv_u(index);
piv_v2  = piv_v(index);
pred_module2 = sqrt(pred_u2.^2 + pred_v2.^2);
piv_module2  = sqrt(piv_u2.^2 + piv_v2.^2);

dot_product2 = pred_u2.*piv_u2 + pred_v2.*piv_v2;
projection2  = [pred_module2 , (dot_product2./pred_module2)];
direction2   = [pred_module2 , dot_product2./(pred_module2.*piv_module2)];
figure;
plot(projection(:,1), projection(:,2),'*');
figure;
plot(direction(:,1),direction(:,2),'*');

figure;
plot(projection2(:,1), projection2(:,2),'*');
figure;
plot(direction2(:,1),direction2(:,2),'*');


%% Script to test matching PIVs to predator positions from file
clear
close all
clc

folder = '/Volumes/Datos/collpen/predator/test/';
file = 'predmodel2013_TREAT_Brown net_didson_block45_sub1.avi';

wsize = 16;
fps = 8;

denoising_method = -1; % keep raw images
denoising_param = 0;

[frame_acc pred_x_acc pred_y_acc pred_u_acc pred_v_acc piv_x_acc piv_y_acc piv_u_acc piv_v_acc intensity_wsize_acc intensity_half_wsize_acc] =...
    matchPIVToPredator(folder, file, wsize, fps, denoising_method, denoising_param);

D = [frame_acc pred_x_acc pred_y_acc pred_u_acc pred_v_acc piv_x_acc piv_y_acc piv_u_acc piv_v_acc intensity_wsize_acc intensity_half_wsize_acc];

savepath = strrep(file,'.avi','_match_PIV_predator.mat');
savepath = [folder '/PIVdata/' savepath];

save(savepath,'D');

