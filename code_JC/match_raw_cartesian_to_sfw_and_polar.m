function [pout_sfw_cart pout_sfw_pol pout_raw_pol pout_raw_pol_wide] ...
    = match_raw_cartesian_to_sfw_and_polar(pin)

% Transform to ARIS sfw generated cartesian
pout_sfw_cart = raw_cart_didson_to_cart_arissfw_point(pin);

% Transform to raw polar
image_h = 800;

a = pin(1) - c1/2;
b = image_h - pin(2);
c = sqrt(a^2 + b^2);

alpha = round(radtodeg(atan(a/b)));
alpha_corrected = round(1.012 * (0.0023*(alpha^3) ...
                                 - 0.0085 * (alpha^2)...
                                 + 3.003*alpha...
                                 + 47.73));
range = round(r2 - (c*r2/r1) + r2*(image_h-r1)/r1);

pout_raw_pol = [alpha_corrected range];

% Transform to ARIS sfw generated polar
pout_sfw_pol = raw_polar_didson_to_polar_arissfw_point(pout_raw_pol);

% Transform to raw polar wide
pout_raw_pol_wide = [alpha_corrected*6 range];

end