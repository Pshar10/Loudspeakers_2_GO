function ita_menucallback_RunMeasurement(hObject, eventdata) %#ok<INUSD>
% gets variables from Workspace

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

runMS = ita_guisupport_measurement_get_global_MS;

result = runMS.run;

%set the variables into the workspace
ita_setinbase('lastANS', result);
ita_getfrombase();
end