function varargout = ita_guisupport_currentdomain(varargin)
%ITA_GUISUPPORT_CURRENTDOMAIN - get/set last domain used (used by ita_menu and ita_main_window)
%
%   Syntax: ita_guisupport_currentdomain(domain) - set domain
%   Syntax: domain = ita_guisupport_currentdomain() - get domain
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_guisupport_currentdomain">doc ita_guisupport_currentdomain</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  20-Jun-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
error(nargchk(0,1,nargin,'string'));

%persistent ita_gui_current_domain;

figuredomain = getappdata(gcf,'ita_domain');

if isempty(figuredomain)
    %figuredomain = ita_gui_current_domain;
end

if nargin > 0
%     ita_gui_current_domain = varargin{1};
    setappdata(gcf,'ita_domain',varargin{1});
end

%% Find output parameters
if nargout == 1
    varargout(1) = {figuredomain};
end
%end function
end