function distance = distanceToStraightLine(x, y, straigth_p1_x, straigth_p1_y, straigth_p2_x, straigth_p2_y)

distance = (x - straigth_p1_x) / (straigth_p2_x - straigth_p1_x) - ...
           (y - straigth_p1_y) / (straigth_p2_y - straigth_p1_y);

end