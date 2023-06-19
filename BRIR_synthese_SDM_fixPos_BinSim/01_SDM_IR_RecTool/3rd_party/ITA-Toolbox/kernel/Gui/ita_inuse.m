function varargout = ita_inuse(varargin)
%ITA_INUSE - Get/Set last variable used by GUI
%  Sets or gets the last variable used by the ITA-Toolbox GUI. The name of
%  the variable is saved in the appData of the figure (for multi window
%  working) and als saved as persitent.
%
%  Syntax:
%   varName = ita_inuse() - get last used audioObj
%   varName = ita_inuse(fgh) - get last used audioObj by this window
%   ita_inuse(audioObj) - set last used audioObj/varName
%   ita_inuse(fgh, audioObj) - set last used audioObj/varName for this window
%   ita_inuse() - just display the name of the last audioObj used
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_inuse">doc ita_inuse</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009


persistent ita_last_var_in_use;

if nargin >= 1 % We got input
    if ischar (varargin{1})
        result = varargin{1};
        
    elseif isa(varargin{1},'itaSuper')
        % Find this var in the base workspace
        [tmp2, names, tmp3, workspaceids] = ita_guisupport_getworkspacelist(); %#ok<ASGLU>
        hits = find(strcmp(varargin{1}.id, workspaceids));
        if ~numel(hits) == 1
            ita_verbose_info('ita_inuse: Variable not unique, check with rsc if you have any trouble',2)
        else
            result = ita_inuse(names{hits}.name);
        end
    elseif ishandle(varargin{1})
        if nargin == 2 && isa(varargin{2},'itaSuper')
            % Find this var in the base workspace
            [tmp2, names, tmp3, workspaceids] = ita_guisupport_getworkspacelist(); %#ok<ASGLU>
            hits = find(strcmp(varargin{2}.id, workspaceids));
            if numel(hits) > 1
                ita_verbose_info('ita_inuse: Variable not unique, check with rsc if you have any trouble',2)
                hits = hits(1);
            elseif numel(hits) < 1
                varargout{1} = '';
                return;
            end
            result = names{hits}.name;
        else
            try
                result = getappdata(varargin{1},'VarInUse');
            catch
                result = [];
            end
        end
    else
        error('ita_inuse: I cant handle this input')
    end
    fgh = ita_main_window();
    if ~isempty(fgh) && ishandle(fgh)
        setappdata(fgh,'VarInUse',result);
    end
    ita_last_var_in_use = result;
end

try
    result = getappdata(ita_main_window,'VarInUse');
catch
    result = [];
end
if isempty(result)
    result = ita_last_var_in_use;
end
if isempty(result) %still empty? get the first variable names
    try
        [tmp2, names, tmp3, workspaceids] = ita_guisupport_getworkspacelist(); %#ok<ASGLU>
        result = names{1}.name;
    end
end

if nargout == 1
    varargout{1} = result;
else
    disp(['Seems you last worked with this var: ' result]);
end

end