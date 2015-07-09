function [angles ranges dot_products relative_range] = checkPIV2(file, pr_frames, pr_x, pr_y, movieobj, px_meter, fps, save_path, save_image)

close
load(file);

% Cluster manually labeled prey positions
preys = [];
for i = 3:3:length(pr_frames)
    fr = pr_frames(i-2:i);
    px = pr_x(i-2:i);
    py = pr_y(i-2:i);
    [x y u v] = averagePreyMovement(fr,px,py);
    preys = [preys ; [fr(2) x y u v]];
end

I = read(movieobj, 1);
[r c n] = size(I);
if(n>1)
    I = rgb2gray(I);
end
angles = [];
ranges = [];
dot_products = [];
relative_range = [];

if(save_image)
    f = figure('Units','normalized','Position',[0 0 0.5 1]);
    
end

for i = 1:length(preys)
    
    if(save_image)
        clf(f,'reset');
        I = read(movieobj, preys(i,1));
        [r c n] = size(I);
        if(n>1)
            I = rgb2gray(I);
        end
        imagesc(I); axis equal; axis tight; colormap gray;
        hold on;
        img_save_path = [save_path '_' int2str(preys(i,1)) '.png'];
    end
    US = imresizeNN(us(:,:,preys(i,1)),size(I));
    VS = imresizeNN(vs(:,:,preys(i,1)),size(I));
    
    piv_u = US(round(preys(i,3)),round(preys(i,2))); % In pixels/sec
    piv_v = VS(round(preys(i,3)),round(preys(i,2))); % In pixels/sec
    
%     piv_u = piv_u/fps;
%     piv_v = piv_v/fps;
    
%     piv_u = piv_u / px_meter;
%     piv_v = piv_v / px_meter;
    
    %    subsampled_x = round(preys(i,2)*100/c);
    %    subsampled_y = round(preys(i,3)*100/r);
    
    vvv = vs(:,:,preys(i,1)); % In pixels/sec
    uuu = us(:,:,preys(i,1)); % In pixels/sec
    %vvv = vvv / px_meter; % In meters/sec No conversion, just for display
    %uuu = uuu / px_meter; % In meters/sec
    xxx = xs(:,:,preys(i,1));
    yyy = ys(:,:,preys(i,1));
    prey_u = preys(i,4); % In pixels/frame
    prey_v = preys(i,5); % In pixels/frame
%     prey_u = prey_u * fps / px_meter; % In meters/sec
%     prey_v = prey_v * fps / px_meter; % In meters/sec
    prey_x = preys(i,2);
    prey_y = preys(i,3);
    
    if(save_image)
        quiver(xxx,yyy,uuu,vvv,'color',[0 0 1]);
        quiver(prey_x,prey_y,prey_u,prey_v,4,'g');
        quiver(prey_x,prey_y,piv_u,piv_v,4,'r');
        
        plot(pr_x((i*3)-2:1:i*3),pr_y((i*3)-2:1:i*3),'.g');
        F = getframe(f);
        % saveas(f, img_save_path,'epsc2');
        saveas(f, img_save_path);
        
        %imwrite(F.cdata,img_save_path);
    end
    
    
    %  piv_u = uuu(subsampled_x,subsampled_y);
    %  piv_v = vvv(subsampled_x, subsampled_y) ;
    %   uuu(subsampled_y,subsampled_x)
    %   vvv(subsampled_y,subsampled_x)
    
    [prey_theta prey_len] = cartesian2Polar(prey_u,prey_v);
    [piv_theta piv_len] = cartesian2Polar(piv_u,piv_v);
    
    %     prey_theta = mod((prey_theta+180),360) - 180
    %     piv_theta = mod((piv_theta+180),360) - 180
    %
    %     angle = piv_theta - prey_theta;
    len = piv_len - prey_len;
    
    relative_range = [relative_range ; piv_len*100/prey_len];
    
    angle = getAngleTwoVectors([prey_u,prey_v],[piv_u,piv_v]);
    dot_product = dot([prey_u,prey_v],[piv_u,piv_v]);
    
    angles = [angles ; angle];
    ranges = [ranges ; len];
    dot_products = [dot_products ; dot_product];
    
end

end

