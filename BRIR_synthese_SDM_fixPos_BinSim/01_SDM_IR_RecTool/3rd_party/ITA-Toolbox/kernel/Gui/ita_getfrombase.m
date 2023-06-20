function varargout = ita_getfrombase(varargin)
%ITA_GETFROMBASE - Get a variable from the base workspace
%
%  Syntax:
%   audioObj = ita_getfrombase(name) - get var with that name
%   audioObj = ita_getfrombase()     - get var last used (as returned by ita_inuse())
%   ita_getfrombase(name)            - plot var using ita_plot, plots into ita_main_window
%   
%   
%   See also: ita_inuse, ita_setinbase.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_getfrombase">doc ita_getfrombase</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode'); %Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
error(nargchk(0,1,nargin,'string'));

if nargin > 0
    sArgs        = struct('pos1_name','char');
    [name,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>
    if isempty(name)
        name = ita_inuse();
    end
else
    name = ita_inuse();
end

%% Special handling of '-- All --'
if strcmpi(name,'-- all --')
    [egal egal2 name] = ita_guisupport_getworkspacelist;
    name = name(1:end-1,1);
end

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back
result = [];
try
    if ischar(name)
        result = evalin('base',ita_guisupport_removewhitespaces(name));
    elseif iscellstr(name)
        result = evalin('base',ita_guisupport_removewhitespaces(name{1}));
        for idx = 2:numel(name)
            result(idx) = evalin('base',ita_guisupport_removewhitespaces(name{idx}));
        end
    end
catch %#ok<CTCH>
    if verboseMode
        disp(['Var ' name ' not found']);
    end
    varargout{1}= [];
    return;
end


%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    ita_plot_gui();
else
    % Write Data
    varargout(1) = {result}; 
end

%end function
end
