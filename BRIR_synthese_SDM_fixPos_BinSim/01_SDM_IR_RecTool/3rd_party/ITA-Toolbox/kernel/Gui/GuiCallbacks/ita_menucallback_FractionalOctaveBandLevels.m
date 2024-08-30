function ita_menucallback_FractionalOctaveBandLevels(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

levels = ita_spk2frequencybands(ita_getfrombase);
levels.bar;
ita_setinbase('bandlevels',levels);
end