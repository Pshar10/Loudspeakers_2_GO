function ita_setinbase(varargin)
%ITA_SETINBASE - Save a variable in the base workspace
% If the variable is an itaAudio, the property ita_inuse is set, too
%
%  Syntax:
%   ita_setinbase(namev, value) - set var with that name and value
%   
%   
%   See also: ita_inuse, ita_getfrombase.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_setinbase">doc ita_setinbase</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009 

%% Initialization and Input Parsing
error(nargchk(2,2,nargin,'string'));

[path, name, fileExt] = fileparts(varargin{1}); 
                        %BMA: To assure that only file name will be used.
name = ita_guisupport_removewhitespaces(name);
name = genvarname(name); %use genvarname to make sure it can exist as matlab variable

value = varargin{2};

%BMA: If we want to avoid variables to be overwritten, then this piece of
%     code would do the job. But for now, we let then be overwritten.
% try
%     % first see if variable name already exists in base workspace
%     % and if it does, save the variable followed by _copy#, like
%     % windows normally does.
%     
%     WKSvar = evalin('base','whos');
%     comparison = strmatch(name,{WKSvar.name});
%     if ~isempty(comparison)
%         name = [name '_copy' num2str(length(comparison))];
%     end
% end

if isa(value,'itaSuper')
    ita_inuse(name);
end

%% Assign to workspace
try 
    assignin('base',name,value);   
catch %#ok<CTCH>
    ita_verbose_info(['Var ''' name ''' could not be set'],1);
end

end