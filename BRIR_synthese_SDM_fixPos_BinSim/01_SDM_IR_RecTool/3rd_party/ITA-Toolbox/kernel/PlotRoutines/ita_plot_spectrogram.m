function varargout = ita_plot_spectrogram(varargin)
%ITA_PLOT_SPECTROGRAM - Plot Spectrogram
%  This function plots the spectrogram
%
%  Syntax: ita_plot_spectrogram(audioObj,options)
%  Call: ita_plot_spectrogram(audioObj,'linear')
%  Call: ita_plot_spectrogram(audioObj,'FFT', [samples], 'overlap', [factor])
%  Options (default):
%   'log' ('off') :
%   'clim' ([]) :
%   'cut' ('off') :
%   'figure_handle' ([]) :
%   'axes_handle' ([]) :
%   'upcontrol' ('false') :
%   'upcontrol2' ('false') :
%   'nofigure' ('false') :
%   'FFT' ([]) :
%   'overlap' ([]) :
%   'nodb' (false) :
%   'ylog' (false) :
%   'linewidth' (ita_preferences('linewidth')) :
%   'fontname' (ita_preferences('fontname')) :
%   'fontsize' (ita_preferences('fontsize')) :
%   'xlim' ([]) :
%   'ylim' ([]) :
%   'axis' ([]) :
%   'aspectratio' ([]) :
%   'hold' ('off') :
%   'precise' (true) :
%
%   See also ita_plot.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_spectrogram">doc ita_plot_spectrogram</a>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  06-Oct-2008 - pdi
% Modified: 02 Dez 2008 - jko - Frequency-Axis Ticks & Labels from 500Hz up to 1MHz (only log!)

%% Get Defaults
% matlabdefaults = ita_set_plot_preferences; %set ita toolbox preferences and get the matlab default settings

% TODO % 20u Pa scaling. pdi

%% Initialization
error(nargchk(1,10,nargin,'string'));
sArgs   = struct('pos1_data','itaAudioTime','log','off','clim',[],'cut','off','figure_handle',[],'axes_handle',[]...
    ,'nofigure','false','FFT',[],'overlap',[],'nodb',false,'ylog',false,'linewidth',ita_preferences('linewidth'),'fontname',ita_preferences('fontname'),'fontsize',ita_preferences('fontsize'), 'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','precise',true);
[data,sArgs]   = ita_parse_arguments(sArgs,varargin);

if data.nChannels > 1
    ita_verbose_info('ita_plot_spectrogram: More than one channel, plotting first one',1)
    data = data.ch(1);
end

%% Plot Setup and Init
if isempty(sArgs.FFT)
    nSamples = data.nSamples;
    nWindow  = 2^nextpow2(nSamples / 2000);
    if nWindow < 1024
        nWindow = 1024;
        nOverlap = nWindow ./ 8;
    else
        nOverlap = nWindow./2; %10;
    end
    
    nFFT     = nWindow; %2048;
else
    nFFT = sArgs.FFT;
    nWindow = nFFT;
    nOverlap = round(nFFT*sArgs.overlap);
end

%% pdi: checking for very long data and avoiding memory overflow!
if data.fftDegree > 24;
    nBlocks = 8;
else
    nBlocks = 1;
end
block_length = data.nSamples / nBlocks;


%% do spectrogram
for ch_idx = 1:data.nChannels
    
    p = [];
    t = [];
    for part_idx = 1:nBlocks
        limits = (part_idx-1)*block_length + 1 : (part_idx)*block_length;
        [y_part,f,t_part,p_part] = spectrogram(double(data.timeData(limits,ch_idx)),nWindow,nOverlap,nFFT,data.samplingRate ,'yaxis'); %#ok<ASGLU>
        t = [t, t_part + (part_idx-1)*block_length ./ data.samplingRate]; %#ok<AGROW>
        p = [p p_part]; %#ok<AGROW>
    end
    
    %     end
    clear y
    clear y_part
    clear t_part
    clear p_part
    p = double(p);
    if sArgs.nodb
        p = abs(p);
    else
        p = 10*log10(abs(p));
    end
    if ~sArgs.nofigure
        %% Figure and axis handle
        if ~isempty(sArgs.figure_handle) && ishandle(sArgs.figure_handle)
            fgh = sArgs.figure_handle;
            figure(fgh);
            if ~sArgs.hold
                hold off;
            else
                hold on;
            end
        else
            fgh = ita_plottools_figure;
        end
        
        if isempty(sArgs.axes_handle)
            sArgs.axes_handle = gca;
            sArgs.resize_axes = true;
        else
            axes(sArgs.axes_handle); %#ok<LAXES>
            sArgs.resize_axes = false;
        end
        
        %% Get CLIMs
        if isempty(sArgs.clim)
            a(2) = max(max(p));
            a(2) = 10 * ceil (a(2)/10);
            a(1) = a(2)-70;
        else %specified by user
            a = sArgs.clim;
        end
        
        %% Cut results to CLIM to avoid sparcles?
        if sArgs.cut
            disp('cutting')
            p(p < a(1)-20) = a(1)-20;
            p(p > a(2)+20) = a(2)+20;
        end
        
        
        %nice edge values
        if a(1) < a(2)
            %         surf(t,f,p); %edgecolor none
            %         axis xy; axis tight; colormap(jet); view(0,90);
            %
            f = f/1000;
            lnh = pcolor(sArgs.axes_handle,t,f,p);
            axh = get(fgh,'CurrentAxes');
            setappdata(axh,'ChannelHandles',lnh);
            setappdata(axh,'FigureHandle',gcf); %pdi: saver to write this, than to estimate via parent / GUI problem
            
            %% call help function
            sArgs.abscissa = t;
            sArgs.plotData = p;
            
            sArgs.xAxisType  = 'time'; %Types: time and freq
            sArgs.yAxisType  = 'freq';
            sArgs.plotType   = 'spectrogram'; %Types: time, mag, phase, gdelay
            sArgs.xUnit      = 's';
            sArgs.yUnit      = 'Hz';
            sArgs.titleStr   = ['Spectrogram - ' data.comment ' (nWin:' num2str(nWindow) ' nOver:' num2str(nOverlap) ' nFFT:' num2str(nFFT) ') ' data.channelNames{1}];
            sArgs.xLabel     = 'Time in seconds';
            sArgs.yLabel     = 'Frequency in Hz';
            sArgs.figureName = sArgs.titleStr;
            % % %             sArgs.nodb       = 1; %pdi:out
            if sArgs.log
                sArgs.ylog = true;
            end
            sArgs.legendString = data.legend;
            [fgh,axh] = ita_plottools_figurepreparations(data,fgh,axh,axh,'options',sArgs);
            
            if sArgs.nodb
            else
                set(axh,'CLim',a);
            end
            ylim([0 data.samplingRate./2/1000])
            grid off
            shading interp
            set(axh,'Box','off')
            set(axh,'TickDir','out')
            set(axh,'TickLength',[0.003 0.02])
            ita_plottools_colormap('artemis');
        end
    end
    %% Return the figure handle
    if nargout
        varargout{1} = p;
        varargout{2} = fgh;
        varargout{3} = axh;
    end
    
    colorbar;
    %end function
end

% ita_restore_matlab_default_plot_preferences(matlabdefaults) % restore matlab default settings