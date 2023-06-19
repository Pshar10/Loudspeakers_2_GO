function y = schroeder(x)
[~,x2] = size(x);
y = 10.*log10(...
            flip(...
                cumtrapz(...
                    flip(x.^2),1) ) );
for k = 1:x2
y(:,k) = y(:,k) - y(1,k);
end
end