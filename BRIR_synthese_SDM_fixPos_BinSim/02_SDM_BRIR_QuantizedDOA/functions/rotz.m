function R = rotz(alpha_deg)

alpha=deg2rad(alpha_deg);

R = [cos(alpha) -sin(alpha) 0; ...
     sin(alpha)  cos(alpha) 0; ...
              0           0 1];

end