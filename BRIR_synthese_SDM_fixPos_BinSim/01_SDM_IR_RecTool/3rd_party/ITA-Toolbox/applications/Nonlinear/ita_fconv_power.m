function varargout = ita_fconv_power(varargin)
%ITA_FCONV_POWER - Power in time domain with adjustments to avoid aliasing
%
%  Syntax:
%   audioObjOut = ita_fconv_power(audioObjIn, integer)
%
%  Example:
%   y = ita_fconv_power(x, h) = x.^h;
%
%  See also:
%   conv, ita_fconv, ita_fconv2

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich - pdi@akustik.rwth-aachen.de
% Created:  05-Jul-2010 

%% Initialization and Input Parsing
sArgs        = struct('pos1_input1','itaAudio', 'pos2_exp','double');
[input1, exponent, sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Power Process
l1      = input1.nBins;
sr_old  = input1.samplingRate;

input1.signalType = 'power';

% Prepare the data for the multiplication in time domain
input1.freqData     = [input1.freqData; repmat(0*input1.freqData(2:end-1,:),exponent-1,1)];%*sqrt(2); %klein: Commented out the sqrt(2) to achieve same signal amplitude as with fconv2 TODO % Empirical Coefficient
input1.samplingRate = input1.samplingRate * exponent;

% Obtain the powered signal
output = input1 .^ exponent;

% Remove the components above the maximal frequency
output.freqData         = output.freqData(1:l1,:);
output.freqData(end,:)  = 0; %pdi new: nyquist zero
output.samplingRate     = sr_old;

%% Set Output
varargout(1) = {output}; 

end