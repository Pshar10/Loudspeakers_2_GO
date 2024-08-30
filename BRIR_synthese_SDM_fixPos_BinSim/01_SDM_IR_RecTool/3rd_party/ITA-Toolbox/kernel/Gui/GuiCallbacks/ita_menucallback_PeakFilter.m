function ita_menucallback_PeakFilter(hObject, event)
%TODO input arguments

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


x = ita_filter_peak();
ita_setinbase('last_ans',x);
ita_getfrombase;
end