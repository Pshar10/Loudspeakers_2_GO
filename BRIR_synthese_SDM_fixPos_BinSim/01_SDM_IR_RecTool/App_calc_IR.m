%% Impulsantwortberechnung
% Berechnung der Impulsantworten im Nachgang
% Lukas Treybig; TU Ilmenau 2021



clc
clear all
close all
clc

nChannels = 7;

%lade irs daten
filepath = 'output/';
filename = 'SDM_HL_5LS_0_0_0.mat';


load([filepath filename])

for idx_speaker_ch = 1:length(irs.speakerNames)
    
    excitation=irs.sweep;
    reording=cell2mat(irs.sweepRec(idx_speaker_ch));
    
    
    for rec_channel = 1:nChannels
        current_ir = impzest(excitation,reording(:,rec_channel),'WarmupRuns',0);
        current_ir = highpass(current_ir,50,fs);
        current_ir_list(:,rec_channel) = current_ir;
    end
    irs.ir(idx_speaker_ch) = {current_ir_list};
end

%% save data
disp('Saving...')
save([filepath filename],'irs')
disp('Done!')