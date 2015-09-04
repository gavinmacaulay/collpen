function [pout_sfw_cart pout_sfw_pol pout_raw_pol pout_raw_pol_wide] ...
    = aris_match_raw_cartesian_to_sfw_and_polar(pin)

% Transform to ARIS sfw generated cartesian
pout_sfw_cart = aris_raw_cart_to_cart_arissfw_point(pin);

% Transform to raw polar
distance_to_sonar_origin = 82;
cart_h = 1138;
cart_w = 600;
polar_h = 1640;
widening_factor = 6;
sensor_h = cart_h + distance_to_sonar_origin;


a = pin(1) - cart_w / 2;
b = sensor_h - pin(2);
c = sqrt(a^2 + b^2);

alpha = radtodeg(atan(a/b));

% Raw aris angle ranges from -14.8 to 14.8 while sfw aris angle ranges
% from -13.6 to 13.6
alpha = alpha * 13.6 / 14.8;
beam = get_aris_beam_from_angle(alpha); % associate alpha to the corresponding beam

range = round(polar_h - (c * polar_h / cart_h) ...
    + polar_h * (sensor_h - cart_h) / cart_h);

pout_raw_pol = [beam range];

% Transform to ARIS sfw generated polar
pout_sfw_pol = aris_raw_polar_to_polar_arissfw_point(pout_raw_pol);

% Transform to raw polar wide
pout_raw_pol_wide = [(beam * widening_factor) range];

end