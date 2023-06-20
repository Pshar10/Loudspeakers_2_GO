function ita_menucallback_varselect(hObject, eventdata)
% Callback routine for click on a var in the menu list

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

varname = get(hObject,'UserData');
ita_main_window('handle',gcf);
ita_inuse(varname);
clf(ita_main_window);
ita_menu('handle',ita_main_window);
ita_getfrombase();
end