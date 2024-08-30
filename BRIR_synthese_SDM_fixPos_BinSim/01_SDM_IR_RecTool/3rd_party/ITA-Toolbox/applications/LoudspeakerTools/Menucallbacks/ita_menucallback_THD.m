function ita_menucallback_THD(varargin)

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

MS = ita_guisupport_measurement_get_global_MS;
uiwait(msgbox('Distortion measurement will now be performed','Start Measurement'));

if ~isa(MS,'itaMSTF')
    result = MS.run;
    distortions = ita_nonlinearities_find_harmonics(result, MS.excitation,'windowFactor',0.6);
else
    distortions = MS.run_HD;
end

THD = sqrt(sum(abs(distortions.ch(2:distortions.nChannels)')^2));
THD.channelNames = {['THD (sum over harmonics 2-' num2str(distortions.nChannels) ')']};
THD.comment = 'Total Harmonic Distortion'; 

assignin('base','THD',THD)

end