function ita_menucallback_ComplexCepstrum(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

ita_setinbase('ANS',ita_cepstrum(ita_getfrombase));
ita_getfrombase;
end