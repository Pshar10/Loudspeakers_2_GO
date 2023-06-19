
%Lukas Treybig, TU Ilmenau 2022
function [tmdBline, tmdB, m] = createRTfromschroederSE(sc, fs, mdB_start, mdB_end )

if sc(1) ~= 0
    sc = sc-sc(1);
end

mRTdB_start = find(sc <= mdB_start, 1);
mRTdB_end = find(sc <= mdB_end, 1);


if isempty(mRTdB_end)
    [mdB_end,mRTdB_end] = min(sc);
end

m = mdB_end/mRTdB_end;


tmdB = (mRTdB_end-mRTdB_start) /fs;
tmdBline = (0:length(sc)-1).*m;

end