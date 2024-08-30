function ita_menucallback_read(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

aux = ita_read;
[junk,name,junk] = fileparts(aux(1).fileName);
ita_setinbase(name,aux);
ita_getfrombase;
end