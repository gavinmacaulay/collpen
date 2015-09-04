function pout = didson_raw_polar_to_polar_arissfw_point(pin)

pin_x_corrected = double(pin(1));

pin_x_corrected = int32(pin_x_corrected * 1098 / 96);
pin_x_corrected = pin_x_corrected + 52;

pin_y_corrected = double(pin(2));

pin_y_corrected = int32(pin_y_corrected * 675 / 512);
pin_y_corrected = pin_y_corrected + 228;

pout = [pin_x_corrected pin_y_corrected];
end