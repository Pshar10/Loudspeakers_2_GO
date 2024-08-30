%% Sweeprecording mit Impulsantwortberechnung (abwählbar)
% SDM array
%
% Lukas Treybig; TU Ilmenau 2022



clc
close all
clear all 

addpath(genpath('functions/'));
addpath(genpath('3rd_party/'));
addpath(genpath('sweep/'));


%Orientation

% el=0° und az=0° entspricht eine Vektor auf y-Achse



%% Folders
Output = '../data/RIR/';

calc_IR = 1; %calculat Impulsrespons
flip_phase_measurment_mic = 1; %Kanal 7 (Messmikro) mit -1 multiplizieren;

%f_gain = [5.899974163771157,5.960146874493056,3.669551814562449,4.178224276367109,3.710109648676412,5.230395430311390,1]; %Messung RMS von IR
    
% Zu Beginn einer Messung Nullpunkt definieren und immer
% Lautsprecherposition, Mikrofonposition und die jeweiligen Orientierung
% auf diesen beziehen

tic
%% Meta-data 
irs.author = 'Lukas Treybig';   % name of measuring person
irs.room   = 'BÜRO';           % name of room
irs.info  = 'SDM';              % type of measurement
irs.speakerType = 'RL906';      % type of speaker

irs.micPos = [0 0 0];           % microphone position (x,y,z) in the grid in [m]
irs.micAzEl = [0 0];         % mircophone direction of view offset in degree


%irs.micCapsPos = [ 1 0 0;              %position of microphone  for micOffAzEl = [0 0]
%                   0 -0.7071 -0.7071;
%                   0 -0.7071 0.7071;
%                  -1 0 0;
%                   0 0.7071 0.7071;
%                   0 0.7071 -0.7071;
%                   0 0 0]*0.1/2;

%irs.gridOffXYZ = [0 0 0];       % grid offset in the room (x y z) in [m]
%irs.gridOffAzEl = [0 0];        % grid azimuth and elevation offset in degree


nSpeaker = 1;  % num of speakers

irs.speakerNames = { 'A'...
%                    ,'B'...
%                    ,'C'...
%                    ,'D'...
%                    ,'E'...
                    };
                
% speaker positions (x,y,z) in the grid in [m]
irs.speakerPos =   { [  1.00    0.00    0.00   ]...
%                    ,[	0.00    0.00    0.00  ]...
%                    ,[	0.00    0.00    0.00   ]...
%                    ,[  0.00    0.00    0.00   ]...
%                    ,[  0.00    0.00    0.00   ]...
                    };
                
% speaker azimuth and elevation in degree (in referenz to the grid)

irs.speakerAzEl =   { [ 210    0.00    ]...
%                     ,[ 150    0.00    ]...
%                     ,[ 180    0.00    ]...
%                     ,[ 290    0.00    ]...
%                     ,[ 70     0.00    ]...
                    };


%% Initial parameters
irs.fs = 48000;    % sampling rate 

irs.sweepLoudness   = 0.5; %Loudness factor

countdown = 0; % you need time to leave the room? in [s] 

nChannels = 7; % num of microphones

% Audio device stuff
% more info on available auzdio devices:    playrec('getDevices');
deviceID.out = 0; 
deviceID.in  = 0;
channels.in  = [1:nChannels]; %<--- Microphone Channels
channels.out = [1:nSpeaker];  %<--- Speaker Channels

nRecordingChannels = length(channels.in);


%--------------------------------------------------------------------------

%CheckDaten einfügen
if(nSpeaker~=length(irs.speakerAzEl) || nSpeaker~=length(irs.speakerPos) || nSpeaker~=length(irs.speakerNames) )
    error('Wrong number of speakers or speaker Meta-datas are wrong.')
end


%% pre generated sweep
switch(irs.fs)
    case 48000 
        %load('Sweep_6s2s_50to22000Hz_48kHz.mat');
        load('Sweep_log_6s2s_50to22000Hz_48kHz.mat');
    case 96000
        %load('Sweep_6s2s_50to22000Hz_96kHz.mat');
        load('Sweep_log_6s2s_50to22000Hz_96kHz.mat');
    case 192000 
        %load('Sweep_6s2s_50to22000Hz_192kHz.mat');
        load('Sweep_log_6s2s_50to22000Hz_192kHz.mat');
end

irs.sweep = s.*irs.sweepLoudness;
recLength = length(s);


% Run measurement
if playrec('isInitialised')
    playrec('reset')
end
    
%playrec('init','BitDepth','32-bit float',irs.fs,deviceID.out,deviceID.in);

playrec('init',irs.fs,deviceID.out,deviceID.in);


%% start measurement
if countdown > 0
    disp(['Countdown start! ' num2str(countdown) 's to go'])
    pause(countdown)
end

for idx_speaker_ch = 1:length(channels.out) % speaker loop
    
    disp('Recording...')
    
    measurementID = playrec('playrec',irs.sweep,channels.out(idx_speaker_ch),recLength,channels.in); % change channels.out
    playrec('block', measurementID);
    sweepRec(:,:) = playrec('getRec',measurementID);
    
    irs.sweepRec(idx_speaker_ch)={double(sweepRec)};
    
    if flip_phase_measurment_mic==1
        irs.sweepRec{idx_speaker_ch}(:,7)=-irs.sweepRec{idx_speaker_ch}(:,7);
    end    
    
    %irs.speakerName(idx_speaker_ch) = speakerNames(idx_speaker_ch);

    if max(sweepRec)>0.99
        disp('clipping!')
    end
    
    % Calc IRs from sweeps
    disp('Calculating IRs')
    excitation=irs.sweep;
    reording=cell2mat(irs.sweepRec(idx_speaker_ch));
    fs=irs.fs;

    
    if(calc_IR)
        for rec_channel = 1:length(channels.in)
            current_ir = impzest(excitation,reording(:,rec_channel),'WarmupRuns',0);
            current_ir = highpass(current_ir,50,fs);
            %current_ir = lowpass(current_ir,20000,fs,'Steepness',0.95);
            current_ir_list(:,rec_channel) = current_ir;
        end
        irs.ir(idx_speaker_ch) = {current_ir_list};
    end
        
end



%% Plot
figure  
for i=1:length(channels.out)
    
    subplot(length(channels.out),1,i); plot(irs.ir{i});
    title(['Response of all Mics; Loudspeaker ' num2str(i) '(' irs.speakerNames{i} ')']);
end

figure
for i=1:length(channels.out)
    
    NFFT = 2.^nextpow2(length(irs.ir{i}(:,7)));
    IR = abs(fft(irs.ir{i}(:,7),NFFT));
    f = irs.fs/2*linspace(0,1,NFFT/2);

    IR = 20*log10(abs(IR(:,1)));
    subplot(length(channels.out),1,i);
    semilogx(f,IR(1:floor(end/2),1),'LineWidth',1);
    grid on;
    title(['Freq. Response of Omni Mic; Loudspeaker ' num2str(i) '(' irs.speakerNames{i} '); Level: ' num2str(db(irs.sweepLoudness))]);
end

%% save data
disp('Saving...')

%Date
t = datetime('now');
t.Format = 'yyyyMMdd_HHmmss';
t=char(t);

save_name = strcat(Output,irs.room,'_',irs.info,'_',num2str(nSpeaker),'LS_',t,'.mat');
%save_name = strcat(Output,irs.info,'_',irs.room,'_',num2str(nSpeaker),'LS_', num2str(irs.micPos(1)), '_', num2str(irs.micPos(2)),'_',num2str(irs.micPos(3)),'.mat');


save(save_name,'irs')

disp('Done!')

toc

