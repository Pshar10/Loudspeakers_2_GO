function varargout = ita_plottools_aspectratio(varargin)
%ITA_PLOTTOOLS_ASPECTRATIO - Scale Figure according to aspect ratio
%  This function rescales a figure according to a given aspect ratio or an
%  aspect ratio set in the Toolbox Preferences. If an  aspect ratio of 0,
%  is set, the plot will be maximized to full screen.
%
%  Syntax: ita_plottools_aspectratio(aspectratio)
%  Syntax: ita_plottools_aspectratio(hfig,aspectratio)
%
%   Parameters: aspect ratio = height/width, rational number e.g. 0.8
%               hfig : figure handle
%
%   See also ita_plottools_figure, ita_plottools_maximize, ita_preferences_aspectratio.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_aspectratio">doc ita_plottools_aspectratio</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Author: Sebastian Fingerhuth -- Email: sfi@akustik.rwth-aachen.de
% Created:  04-Mar-2009

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
error(nargchk(0,2,nargin,'string'));

if nargin == 0
    %% use preferences aspect ratio and scale current figure
    aspectratio = ita_preferences_aspectratio();
    hfig = gcf;
elseif nargin == 1
    %use this aspect ratio
    hfig = gcf;
    aspectratio = varargin{1};

else % handle and aspect ratio given
    hfig        = varargin{1};
    aspectratio = varargin{2};
end

set(hfig,'Units','pixels')
%% scale figure
if aspectratio
    % TODO % maximum monitor size / figure
    mpos = get(0,'MonitorPosition')
    if size(mpos,1) > 1
        single_monitor = false;
        [value, idx] = max(max(abs(mpos(:,[1 3]))));
        [idx tmp] = find(value == abs(mpos));
        mpos = mpos(idx,:); %get only main monitor, which is the bigger one
    else
        single_monitor = true;
    end

    monitor_width  = mpos(3)-mpos(1)+1;
    monitor_height = mpos(4)-mpos(2)+1;
    if aspectratio > monitor_height / monitor_width;
        figure_height = monitor_height;
        figure_width  = monitor_height ./ aspectratio;
    else
        figure_height = monitor_width * aspectratio;
        figure_width  = monitor_width;
    end

    figure(hfig)
    abs_mon_position = [mpos(1) 0  figure_width figure_height] + ...
        [monitor_width-figure_width monitor_height-figure_height  0 0 ]

    %apply settings
    set(hfig,'OuterPosition',abs_mon_position)
    set(hfig,'Units','normalized')
    set(hfig,'PaperPositionMode','auto')

else
    ita_plottools_maximize(hfig);
end


%end function
end