function varargout = ita_abs(varargin)
%ITA_ABS - Absolute value of signal
%  This function calculates the absolute values of the signal in the 
%  domain of the input signal.
%
%  Syntax: itaAudio = ita_abs(itaAudio)
%
%   See also ita_real, ita_abs.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_imag">doc ita_imag</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  27-Feb-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
error(nargchk(1,1,nargin,'string'));
sArgs        = struct('pos1_data','itaSuper');
[result,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% abs
ita_verbose_info([thisFuncStr 'Using ' result.domain 'domain.'],2);
result.data = abs(result.data) ;

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end