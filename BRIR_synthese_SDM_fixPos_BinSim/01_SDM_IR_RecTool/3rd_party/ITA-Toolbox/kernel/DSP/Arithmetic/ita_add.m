function varargout = ita_add(varargin)
%ITA_ADD - Add two audioObjs
%  This function adds two audioObjs independent of the domain.
%
%  Syntax: audioObj = ita_add(audioObj1, audioObj2)
%
%   See also ita_subtract, ita_multiply_spk, ita_divide_spk.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_add">doc ita_add</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  26-Sep-2008


%% Initialization
% Number of Input Arguments
if nargin == 0 % generate GUI
    ele = 1;
    pList{ele}.description = 'First itaAudio';
    pList{ele}.helptext    = 'This is the first itaAudio for addition';
    pList{ele}.datatype    = 'itaAudioInUse';
    pList{ele}.default     = '';
    
    ele = 2;
    pList{ele}.description = 'Second itaAudio';
    pList{ele}.helptext    = 'This is the second itaAudio for addition';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 3;
    pList{ele}.datatype    = 'line';
    
    ele = 4;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Add two itaAudio objects']);
    if ~isempty(pList)
        result = ita_add(pList{1},pList{2});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{3}, result);
    end
    return;
else
    error(nargchk(2,2,nargin,'string'));
end

%% Find Audio Data
sArgs   = struct('pos1_a','itaSuper','pos2_b','anything');
[a,b,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

result = a + b;

%% Find output parameters
% Write Data
varargout(1) = {result};
%end function
end