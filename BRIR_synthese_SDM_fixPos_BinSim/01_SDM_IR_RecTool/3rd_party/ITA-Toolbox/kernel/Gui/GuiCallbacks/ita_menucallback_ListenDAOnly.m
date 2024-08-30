function ita_menucallback_ListenDAOnly(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

ita_portaudio(ita_normalize_dat(ita_getfrombase)*0.99,'keepsamplingrate'); 

end