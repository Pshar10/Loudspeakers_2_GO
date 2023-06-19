function ita_toolbox_classtree(varargin) % Picture of all ITA classes
% generates a tree of all ITA classes and saves it in ITA-Toolbox/pics
%
%   Options:
%       excludeclasses ['template'] - Classes that shall not appear
%       includeapps [false] - also include classes defined in the apps

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


sArgs = struct('excludeclasses',{{'template'}},'includeapps',false);
sArgs = ita_parse_arguments(sArgs,varargin);


if ~ita_preferences('isGraphVizInstalled')
   ita_verbose_info('Please install GraphViz and set the preference to save the ClassTree',0); 
end

if sArgs.includeapps
    rootpath = ita_toolbox_path;
else
    rootpath = ita_toolbox_path('kernel');
end

viewClassTree(rootpath,ita_preferences('isGraphVizInstalled'), sArgs.excludeclasses);

end