function ita_legend(legendStrCell, excludeIdx, varargin)
%ITA_LEGEND - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   ita_legend(legendStringCell, idxOfEntryToExclude)
%   ita_legend(legendStringCell, idxOfEntryToExclude, furtherArgumentsForLegend )
%                                       %  furtherArgumentsForLegend are bypassed to original legend function 
%
%  Example:
%   plot(rand(10,3))
%   ita_legend({'1. blue' '3. red'}, 2) % no legend entry for second (green) line
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_legend">doc ita_legend</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  19-Jan-2012 

% TODO:
% - syntax wie orignal legend? alle optionen weiterleiten
% - axhandle als option
% -  check wenn mehr legend eintr�ge als lines


%% Initialization and Input Parsing
% sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
% [input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% 
if ~exist('excludeIdx', 'var')
    excludeIdx = [];
end


cAx = gca;

linHandles  = get(cAx, 'children');
nLines      = size(linHandles,1);


legendEntryHandle = cell2mat(get(cell2mat(get(linHandles,'Annotation')),'LegendInformation'));

set(legendEntryHandle, 'IconDisplayStyle','on');                            % set all on (in case ita_legend is called twice)
set(legendEntryHandle(nLines-excludeIdx+1), 'IconDisplayStyle','off');  

legend(legendStrCell, varargin{:})

% %end function
end