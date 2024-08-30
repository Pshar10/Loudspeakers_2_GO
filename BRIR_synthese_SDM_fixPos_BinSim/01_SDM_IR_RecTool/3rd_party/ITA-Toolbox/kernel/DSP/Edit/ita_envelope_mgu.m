function varargout = ita_envelope_mgu(varargin)
%ITA_ENVELOPE_MGU - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_envelope_mgu(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_envelope_mgu(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_envelope_mgu">doc ita_envelope_mgu</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  19-Oct-2011 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','itaAudio', 'linear', true);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% 

if sArgs.linear 
    hinterData = hilbert(input.timeData, input.nSamples*2)



% 
% hilli = data;
% re = real(hilbert(hilli.timeData));
% im = imag(hilbert(hilli.timeData));
% hilli.timeData = [abs(complex(re,im)) abs(complex(re,[-im(1); im(2:end)])) ];
% hilli(:).channelUnits = '';
% hilli.plot_dat_dB
% 
% 
% 
% tmp = data;
% tmp.timeData = [data.timeData real(hilbert(data.time)) imag(hilbert(data.time)) abs(hilbert(data.time))];
% tmp.channelNames = {'raw', 'real' 'imag', 'abs' ''};
% tmp.channelUnits = '';
% tmp.plot_dat_dB
% 
% 
% del = tmp;
% del.freqData = [del.freqData(:,2:3) abs(del.freqData(:,2)).*exp(j*angle(del.freqData(:,3)))  abs(del.freqData(:,3)).*exp(j*angle(del.freqData(:,2))) ]
% del.channelUnits(:) = '';
% del.channelNames ={'real' 'imag' 'abs(real)*exp(imag)' 'abs(imag)*exp(real)' }
% del.plot_dat_dB

% sample use of the ita warning/ informing function
% ita_verbose_info('Testwarning',0); 


%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end