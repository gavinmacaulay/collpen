function pout = aris_raw_cart_to_cart_arissfw_point(pin)

sfw_image_width = 688;
sfw_image_height = 1080;
sfw_left_displacement = 78;
sfw_right_displacement = 78;
sfw_top_displacement = 22;
sfw_bottom_displacement = 36;
sfw_width = sfw_image_width - sfw_left_displacement - sfw_right_displacement; % 1106
sfw_height = sfw_image_height - sfw_bottom_displacement - sfw_top_displacement; %674

raw_width = 600;
raw_height = 1138;


pin_x_corrected = double(pin(1));

pin_x_corrected = int32(pin_x_corrected * sfw_width / raw_width);
pin_x_corrected = pin_x_corrected + sfw_left_displacement;

pin_y_corrected = double(pin(2));

pin_y_corrected = int32(pin_y_corrected * sfw_height / raw_height);
pin_y_corrected = pin_y_corrected + sfw_top_displacement;
pout = [pin_x_corrected pin_y_corrected];
end