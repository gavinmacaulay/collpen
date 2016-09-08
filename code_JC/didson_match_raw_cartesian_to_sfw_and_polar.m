function [pout_sfw_cart pout_sfw_pol pout_raw_pol pout_raw_pol_wide] ...
    = didson_match_raw_cartesian_to_sfw_and_polar(pin)

% Transform to ARIS sfw generated cartesian
pout_sfw_cart = didson_raw_cart_to_cart_arissfw_point(pin);

% Transform to raw polar
distance_to_sonar_origin = 56;
cart_h = 744;
cart_w = 400;
polar_h = 512;
widening_factor = 6;
sensor_h = cart_h + distance_to_sonar_origin;


a = pin(1) - cart_w/2;
b = sensor_h - pin(2);
c = sqrt(a^2 + b^2);

alpha = round(radtodeg(atan(a/b)));

alpha_corrected = lens_distortion(96,alpha); % This function belongs to the 
% original didson_reader. Although the parameters it uses do not match 
% exactly what is in the paper (as follows) it will be used for compatibility
% alpha_corrected = round(1.012 * (0.0023*(alpha^3) ...
%                                  - 0.0085 * (alpha^2)...
%                                  + 3.003*alpha...
%                                  + 47.73));
range = round(polar_h - (c * polar_h / cart_h) ...
    + polar_h * (sensor_h - cart_h) / cart_h);

pout_raw_pol = [alpha_corrected range];

% Transform to ARIS sfw generated polar
pout_sfw_pol = didson_raw_polar_to_polar_arissfw_point(pout_raw_pol);

% Transform to raw polar wide
pout_raw_pol_wide = [(alpha_corrected * widening_factor) range];

end