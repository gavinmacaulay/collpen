function [extrap_x extrap_y extrap_fr] = extrapolatePredatorTrajectory(px, py, fr, mean_mx, mean_my, debug)

if(debug)
plot(px, py);
end

extrap_fr = [];
extrap_x = [];
extrap_y = [];

reached_boundary = false;

init_frame = fr-1;
while ~reached_boundary
    extrap_fr = [extrap_fr ; init_frame];
    extrap_x =  [extrap_x ; mean_mx * (init_frame - fr) + px];
    extrap_y = [extrap_y ; mean_my * (init_frame - fr) + py];
    
    init_frame = init_frame-1;
    
    if(mean_my * (init_frame - fr) + py) <=0
        reached_boundary = true;
    end
end

if(debug)
plot(extrap_x, extrap_y,'LineWidth',1);
figure(1);
subplot(1,3,1)
hold all
plot(extrap_x, extrap_y,'LineWidth',1);
end
%keyboard



end