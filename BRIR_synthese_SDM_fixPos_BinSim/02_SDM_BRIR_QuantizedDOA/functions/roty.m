function R = roty(alpha_deg)

alpha=deg2rad(alpha_deg);

R = [cos(alpha)     0 sin(alpha); ...
     0              1          0; ...
     -sin(alpha)    0 cos(alpha)];

end