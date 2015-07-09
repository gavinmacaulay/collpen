function I=make_zoneplate(zone_size);

zone_coef=pi/(zone_size*2);
szx=zone_size;
szy=zone_size;

for iy=1:szy,
  for ix=1:szx,
    x=[ix; iy]-[128; 128];
%    f=1.5*x;% f=1.5*[100; 100];
    f=x;
    fl=1+cos(zone_coef*(x'*f));
    I(iy,ix) = (fl*255/2);
  end;
end;
