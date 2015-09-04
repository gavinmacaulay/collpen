function pout = didson_raw_cart_to_cart_arissfw_point(pin)

pin_x_corrected = double(pin(1) - 3);

pin_x_corrected = int32(pin_x_corrected * 524 / 394);
pin_x_corrected = pin_x_corrected + 81;

pin_y_corrected = double(pin(2));

pin_y_corrected = int32(pin_y_corrected * 1022 / 744);
pin_y_corrected = pin_y_corrected + 22;
pout = [pin_x_corrected pin_y_corrected];
end