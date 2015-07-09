function val = inCircle(point, circle)

% point = [x1 y1];
% point = [x1 y1 ; x2 y2];
% circle = [xc yc radious];
% val --> 0 = outside; 1 = inside or border

p = [point(:,1) - circle(:,1) , point(:,2) - circle(:,2) ];

d = hypot(point(:,1),point(:,2));

val = d-circle(:,3)<=1e-12

end