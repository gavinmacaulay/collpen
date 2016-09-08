function pout = aris_raw_polar_to_polar_arissfw_point(pin)

sfw_image_width = 1206;
sfw_image_height = 1080;
sfw_left_displacement = 54;
sfw_right_displacement = 46;
sfw_top_displacement = 232;
sfw_bottom_displacement = 174;
sfw_width = sfw_image_width - sfw_left_displacement - sfw_right_displacement; % 1106
sfw_height = sfw_image_height - sfw_bottom_displacement - sfw_top_displacement; %674

raw_width = 96;
raw_height = 1640;


pin_x_corrected = double(pin(1));

pin_x_corrected = int32(pin_x_corrected * sfw_width / raw_width);
pin_x_corrected = pin_x_corrected + sfw_left_displacement;

pin_y_corrected = double(pin(2));

pin_y_corrected = int32(pin_y_corrected * sfw_height / raw_height);
pin_y_corrected = pin_y_corrected + sfw_top_displacement;

pout = [pin_x_corrected pin_y_corrected];
end