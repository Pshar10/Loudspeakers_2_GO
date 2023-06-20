function varargout = ita_nonlinearities_find_harmonics(varargin)
%ITA_NONLINEARITIES_FIND_HARMONICS - Find harmonic peaks in IR (exp. sweep measurements)
%  This function finds the peaks or IR of the harmonics (non-linear system)
%  in an impulse response measured with an exp. sweep.
%
%  Syntax:
%   audioObjOut = ita_nonlinearities_find_harmonics(IR, sweep_used)
%
%   Options (default):
%           'degree' (5) : maximum order of harmonics
%           'windowFactor' (0.9) : normalized window length 
%           'preShift' (0.01) : time span for considering non-causalities
%            
%
%  See also:
%   ita_generate_sweep, ita_nonlinear_limiter
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nonlinearities_find_harmonics">doc ita_nonlinearities_find_harmonics</a>

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  27-Jul-2011 

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'pos2_data', 'itaAudio','preShift',0.01,'windowFactor',0.9,'tukey',0.7,'degree',5,'sweeprate',[],'shift',true,'shift2samples',false);
[h_nonlin, sweep, sArgs] = ita_parse_arguments(sArgs,varargin); 

%% find harmonics and shift
o = 1:sArgs.degree;         
if isempty(sArgs.sweeprate)
   sArgs.sweeprate = ita_sweep_rate(sweep,[2000 5000]); 
end
delta_t  = log2(o) / sArgs.sweeprate; % shifts of harmonics relative to fundamental

delta_samples = delta_t*sweep.samplingRate;
if sArgs.shift2samples
   delta_samples = round(delta_samples);
end

t_length = [double(h_nonlin.trackLength) - delta_t(end) diff(delta_t)];

%% pre shift
h_nonlin = ita_time_shift(h_nonlin,sArgs.preShift,'time');

%% shift harmonic IRs to beginning
for idx = 1:sArgs.degree
    harmonics(idx) = ita_time_shift(h_nonlin,delta_samples(idx),'samples','frequencydomain'); %compensate delta t shift of harmonic IRs, pdi: frequencydomain for subsample shifts!
    if sArgs.windowFactor
        harmonics(idx) = ita_time_window(harmonics(idx),sArgs.windowFactor.* [sArgs.tukey 1] * t_length(idx),'time','DC',true);
    end
    if ~sArgs.shift
        harmonics(idx) = ita_time_shift(harmonics(idx),-delta_samples(idx),'samples','frequencydomain'); % shift back, if no shift is wanted
    end
    harmonics(idx).channelNames{1} = ['harmonic: ' num2str(idx) ]; %#ok<*AGROW>
end
harmonics = harmonics.merge;

%% compensate pre-shift
harmonics = ita_time_shift(harmonics,-sArgs.preShift,'time');

%% Add history line
harmonics = ita_metainfo_add_historyline(harmonics,mfilename,varargin);

%% Set Output
varargout(1) = {harmonics}; 

%end function
end