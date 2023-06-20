function ita_menucallback_ClearHistory(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

result = ita_getfrombase;
result.header = ita_metainfo_rm_historyline(result,'all');
ita_setinbase(ita_inuse(),result);
disp(result.header)
end