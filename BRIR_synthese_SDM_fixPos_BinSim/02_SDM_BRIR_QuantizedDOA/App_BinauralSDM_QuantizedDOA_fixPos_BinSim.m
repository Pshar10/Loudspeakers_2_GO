% Copyright (c) Facebook, Inc. and its affiliates.

%% Description

% This script is an example showing how to use the functions provided in
% the BinauralSDM repository. The BRIRs generated by this script include
% the steps described in Amengual et al. 2020 - DOA Postprocessing 
% (smoothing and quantization) and RTMod+AP equalization. 
% 
% The overall process is as follows:
% - Spatial data from a multichannel RIR is obtained using the SDM
% utilizing the functions from the SDM Toolbox (Tervo & Patynen).
% - The spatial information is smoothed and quantized as proposed in
% Amengual et al. 2020.
% - Preliminary BRIRs are synthesized by selecting the closest directions
% from an HRIR dataset. In this example, a dataset of KU100 dummy head is
% utilized. The dataset was generated by Bernschutz et al. from the Audio
% Group of TH Cologne. The HRIR dataset is downloaded on the fly during the
% example. 
% - The reverberation time of the preliminary BRIRs is corrected using the
% RTMod method introduced in Amengual et al. 2020.
% - After RTMod correction, a cascade of 3 all-pass filters is applied to
% both left and right channels to improve the diffuseness of the late
% reverberation tail. This process is also introduced in Amengual et al.
% 2020.
% - Responses for arbitrarily defined head orientations are generated
% using the previous steps by rotating the DOA vectors.
% - The data is saved in a user defined folder.
%
% References:
% - (Tervo et al. 2013) - "Spatial Decomposition Method for Room Impulse
% Responses", JAES, 2013.
% - (SDM Toolbox) - "SDM Toolbox", S. Tervo and J. Patynen, Mathworks
% Exchange
% - (Amengual et al. 2020) - "Optimizations of the Spatial Decomposition 
% Method for Binaural Reproduction", JAES 2020.
% 
% Author: Sebastia Amengual (samengual@fb.com)
% Last modified: 11/17/2021
% 
% IMPORTANT NOTE: To ensure that relative paths work, navigate to the
% folder containing this script before executing.
%
% Modification: Lukas Treybig; TU Ilmenau 2022


clear all
close all
clc

addpath(genpath('../SDMtools/'));
addpath(genpath('../data/'));
addpath(genpath('functions/'));

%% load recorded data

% lade Daten mit mat file
filepath='../data/RIRs/';
%filepath = 'D:\Daten\PWHT2\';
%filepath = 'D:\Daten\2022_11_neuesRZ\';

save_BRIR_wavs = 0;
save_BinSim_mat_txt = 1;
save_irs_mat = 1;   %BRIR daten auch in irs.mat abspeichern?

def_fs = 48000;
MixingTime      = 0.10; % Mixing time (in seconds) of the room for rendering. Data after the mixing time will be rendered
BRIRLength      = 0.75;  % Duration of the rendered BRIRs (in seconds)

f_loudness = 5;


if(save_BinSim_mat_txt)
    %for filterstruct
    binsim_default = struct('type','','listenerOrientation',[],'listenerPosition',[],'sourceOrientation',[],'sourcePosition',[], 'custom',[], 'filter', []);
    struct_database_name = 'binsim_struct.mat';
    struct_it = 0;
    m_dist_scale = 1000; %entfernungen in m (1) mm (1000)
end

Files=dir([filepath,'*.mat']);
if(length(Files)>1)
    for idx=1 : length(Files)
        disp([num2str(idx),': ',Files(idx).name])
    end
    prompt = 'select file number which should be loaded:';
    k=input(prompt);
else
    k=1;
end

filename=Files(k).name;
load([filepath filename])

for idxSpeaker=1 :  length(irs.speakerNames) %clac for all speakers
     
    %% Analysis parameter initialization
    
    % Analysis parameters
    MicArray        = 'SDM';                % FRL Array is 7 mics, 10cm diameter, with central sensor. Supported geometries are FRL_10cm, FRL_5cm,
    % Tetramic and Eigenmike. Modify the file create_MicGeometry to add other geometries (or contact us, we'd be happy to help).
    
    Room            = irs.room;                 % Name of the room. RIR file name must follow the convention RoomName_SX_RX.wav
    SourcePos       = char(irs.speakerNames{idxSpeaker});    % Source Position. RIR file name must follow the convention RoomName_SX_RX.wav
    ReceiverPos     = [num2str(irs.micPos(1)), '_', num2str(irs.micPos(2)),'_',num2str(irs.micPos(3))]; % Receiver Position. RIR file name must follow the convention RoomName_SX_RX.wav
    
    %SourcePos   = ['SX_',num2str(irs.speakerPos{idx}(1)),'_',num2str(irs.speakerPos{idx}(2)),'_',num2str(irs.speakerPos{idx}(3))];
    %ReceiverPos = ['RX_',num2str(irs.micPos(1)), '_', num2str(irs.micPos(2)),'_',num2str(irs.micPos(3))]; % Receiver Position. RIR file name must follow the convention RoomName_SX_RX.wav
    
    Database_Path   = '../data/RIRs';   % Relative path to folder containing the multichannel RIR
    
    fs              = irs.fs;    % Sampling Rate (in Hz). Only 48 kHz is recommended. Other sampling rates have not been tested.
    
    
    
    %IR_exp = irs.ir{idxSpeaker}(:,:)*f_loudness;
    %audiowrite( [Database_Path filesep MicArray,'_',Room,'_',SourcePos,'_',ReceiverPos,'.wav'],IR_exp,fs,'BitsPerSample',32);
    %clear IR_exp;
    
    %% Room dependent-------------------------------------------
    % ----------------------------------------------------------
    %MixingTime      = 0.10;                 % Mixing time (in seconds) of the room for rendering. Data after the mixing time will be rendered
    % as a single direction independent reverb tail and AP rendering will be applied.
    DOASmooth       = 16;                   % Window length (in samples) for smoothing of DOA information. 16 samples is a good compromise for noise
    % reduction and time resolution.
    %BRIRLength      = 1.0;                  % Duration of the rendered BRIRs (in seconds)
    
    %  ---------------------------------------------------------
    %% ---------------------------------------------------------
    
    DenoiseFlag     = 0;                    % Flag to perform noise floor compensation on the multichannel RIR. This ensures that the RIR decays
    % progressively and removes rendering artifacts due to high noise floor in the RIR.
    FilterRawFlag   = 1;                    % Flag to perform band pass filtering on the multichannel RIR prior to DOA estimation. If active, only
    % information between 200Hz and 8kHz (by default) will be used for DOA estimation. This helps increasing
    % robustness of the estimation. See create_BRIR_data.m for customization of the filtering.
    AlignDOA        = 0;                    % If this flag is set to 1, the DOA data will be rotated so the direct sound is aligned to 0,0 (az, el).
    SpeedSound      = 345;                  % Speed of sound in m/s (for SDM Toolbox DOA analysis)
    WinLen          = 62;                   % Window Length (in samples) for SDM DOA analysis. For fs = 48kHz, sizes between 36 and 64 seem appropriate.
    % The optimal size might be room dependent. See Tervo et al. 2013 and Amengual et al. 2020 for a discussion.
    
    %end initialization
    
    
    [len anzch] = size(irs.ir{idxSpeaker});
    if(len<anzch)
        Raw_RIR = {irs.ir{idxSpeaker}'*f_loudness};
    else
        Raw_RIR = {irs.ir{idxSpeaker}*f_loudness};
    end
        
    
    % Initialize SRIR data struct
    
    SRIR_data = create_SRIR_data('MicArray', MicArray,...
        'Room',Room,...
        'SourcePos',SourcePos,...
        'ReceiverPos',ReceiverPos,...
        'fs',fs,...
        'MixingTime',MixingTime,...
        'DOASmooth',DOASmooth,...
        'Length',BRIRLength,...
        'Denoise',DenoiseFlag,...
        'FilterRaw',FilterRawFlag,...
        'AlignDOA',AlignDOA,...
        'Raw_RIR',Raw_RIR);
    
    
    
    % Initialize SDM analysis struct (from SDM Toolbox)
    SDM_Struct = createSDMStruct('c',SpeedSound,...
        'fs',SRIR_data.fs,...
        'micLocs',SRIR_data.ArrayGeometry,...
        'winLen',62);
    
    %% Download a HRIR from the Cologne audio team server
    % This step can be skipped if you already have a HRIR dataset
    if(0)
        HRIRurl = 'https://zenodo.org/record/3928297/files/HRIR_FULL2DEG.sofa?download=1';
        HRIRfolder = '../../Data/HRIRs/';
        HRIRfilename = 'KU100_HRIR_FULL2DEG_Koeln.sofa';
        disp('Downloading HRIR Dataset');
        if ~exist(HRIRfolder,'dir')
            mkdir(HRIRfolder)
        end
        HRIRsave = websave([HRIRfolder HRIRfilename],HRIRurl);
    end
    
    %% Rendering parameters
    QuantizeDOAFlag     = 1;                % Flag to determine if DOA information must me quantized.
    DOADirections   = 50;               % Number of directions to which the spatial information will be quantized using a Lebedev grid
    HRIR_Subject    = 'KEMAR';          % Name of the HRIR subject (only used for naming purposes while saving).
    %HRIR_Path       = 'data/HRIRs/TU-Berlin_QU_KEMAR_anechoic_radius_3m.sofa'; % Relative path to the HRIR.
    HRIR_Path       = 'data/HRIRs/Kemar_Aachn_HRTF_processed_sofa.sofa'; % Relative path to the HRIR.
    HRIR_Type       = 'SOFA';           % File format of the HRIR. Only SOFA is supported for now.
    NamingCond      = ['Quantized' num2str(DOADirections) 'DOA']; % String used for naming purposes, useful when rendering variations of the same RIR.
    BRIRAtten       = 30;               % Attenuation of the rendered BRIRs (in dB). Useful to avoid clipping. Use the same value when rendering various
    % positions in the same room to maintain relative level differences.
    AzStep = 2;
    ElStep = 2;
    AzOrient        = (-180:AzStep:180)';    % Render BRIRs every AzStep degrees in azimuth
    %ElOrient        = (-46:ElStep:46)';      % Render BRIRs every ElStep degrees in elevation
    ElOrient        = (0)';      % Render BRIRs every 5 degrees in elevation
    DestinationPath = '../data/SDMRenderedBRIRs/'; % Folder where the resulting BRIRs will be saved
    BandsPerOctave  = 1;                 % Bands per octave used for RT60 equalization
    EqTxx           = 20;                % Txx used for RT60 equalization. For very small rooms or low SNR measurements, T20 is recommended. Otherwise, T30 is recommended.
    
    % Initialize re-synthesized BRIR struct
    BRIR_data = create_BRIR_data('MixingTime',MixingTime,...
        'HRTF_Subject',HRIR_Subject,...
        'HRTF_Type',HRIR_Type,...
        'HRTF_Path',HRIR_Path,...
        'Length',BRIRLength,...
        'RenderingCondition',NamingCond,...
        'Attenuation',BRIRAtten,...
        'AzOrient',AzOrient,...
        'ElOrient',ElOrient,...
        'QuantizeDOAFlag',QuantizeDOAFlag,...
        'DOADirections',DOADirections,...
        'DestinationPath',DestinationPath,...
        'fs',fs,...
        'BandsPerOctave',BandsPerOctave,...
        'EqTxx',EqTxx);
    
    % Read HRTF dataset for re-synthesis
    HRTF = Read_HRTF(BRIR_data);
    
    %% Analysis
    
    % Estimate directional information using SDM. This function is a wrapper of
    % the SDM Toolbox DOA estimation (using TDOA analysis) to include some
    % post-processing. The actual DOA estimation is performed by the SDMPar.m
    % function of the SDM Toolbox.
    SRIR_data = Analyze_SRIR(SRIR_data, SDM_Struct);
    
    %% Synthesis
    
    % 1. Pre-processing operations (massage HRTF directions, resolve DOA NaNs).
    
    [SRIR_data, BRIR_data, HRTF_data, HRTF_TransL, HRTF_TransR] = PreProcess_Synthesize_SDM_Binaural(SRIR_data, BRIR_data, HRTF);
    
    %figure
    %plot3(SRIR_data.DOA(:,1),SRIR_data.DOA(:,2),SRIR_data.DOA(:,3),'o')
    
    % -----------------------------------------------------------------------
    %%% 2. Quantize DOA information, if required
    
    if BRIR_data.QuantizeDOAFlag == 1
        [SRIR_data, idx] = QuantizeDOA(SRIR_data, BRIR_data.DOADirections, 128);
    end
    
    % -----------------------------------------------------------------------
    %%% 3. Compute parameters for RTMod Compensation
    
    % Synthesize one direction to extract the reverb compensation - solving the
    % SDM synthesis spectral whitening
    PreBRIR = Synthesize_SDM_Binaural(SRIR_data, BRIR_data, HRTF_TransL, HRTF_TransR, [0 0],1);
    
    % Using the pressure RIR as a reference for the reverberation compensation
    BRIR_data.ReferenceBRIR = [SRIR_data.P_RIR SRIR_data.P_RIR];
    
    % Get the desired T30 from the Pressure RIR and the actual T30 from one
    % rendered BRIR
    [DesiredT30, OriginalT30, RTFreqVector] = GetReverbTime(SRIR_data, PreBRIR,BRIR_data.BandsPerOctave,BRIR_data.EqTxx);
    
    % -----------------------------------------------------------------------
    % 4. Render BRIRs with RTMod compensation for the specified directions
    
    % Initialize BRIR matrix
    BRIR_Early = zeros((BRIR_data.MixingTime+BRIR_data.TimeGuard)*BRIR_data.fs,2,length(BRIR_data.Directions));
    
    % Render BRIRs
    nDirs = length(BRIR_data.Directions);
    
    % Render early reflections
    hbar = parfor_progressbar(nDirs,'Please wait, rendering (step 1/2)...');
    parfor iDir = 1:nDirs
        hbar.iterate(1);
        BRIR_TimeDataTemp = Synthesize_SDM_Binaural(SRIR_data, BRIR_data, HRTF_TransL, HRTF_TransR, BRIR_data.Directions(iDir,:),0);
        BRIR_TimeDataTemp = ModifyReverbSlope(BRIR_data, BRIR_TimeDataTemp, OriginalT30, DesiredT30, RTFreqVector);
        BRIR_Early(:,:,iDir) = BRIR_TimeDataTemp;
    end
    close(hbar)
    
    % Render late reverb
    BRIR_full = Synthesize_SDM_Binaural(SRIR_data, BRIR_data, HRTF_TransL, HRTF_TransR, [0 0],1);
    BRIR_full = ModifyReverbSlope(BRIR_data, BRIR_full, OriginalT30, DesiredT30, RTFreqVector);
    
    % Remove leading zeros
    [BRIR_Early, BRIR_full] = removeInitialDelay(BRIR_Early,BRIR_full,-20,BRIR_data.MixingTime*BRIR_data.fs);
    
    % Split the BRIR
    [early_BRIR, late_BRIR, DS_BRIR, ER_BRIR]  = split_BRIR(BRIR_Early, BRIR_full, BRIR_data.MixingTime, BRIR_data.fs, 256);
    
    
    [lenDS(idxSpeaker),~,~]=size(DS_BRIR);
    [lenER(idxSpeaker),~,~]=size(ER_BRIR);
    [lenLR(idxSpeaker),~]=size(late_BRIR);
    
    % -----------------------------------------------------------------------
    % 5. Apply AP processing for the late reverb
    
    % AllPass filtering for the late reverb (increasing diffuseness and
    % smoothing out the EDC)
    allpass_delays = [37 113 215 347];                      % in samples
    allpass_RT = [0.1 0.1 0.1 0.1];                         % in seconds
    
    for iAllPass=1:3
        late_BRIR(:,1) = allpass_filter(late_BRIR(:,1),allpass_delays(iAllPass) , [0.1], 48e3);
        late_BRIR(:,2) = allpass_filter(late_BRIR(:,2),allpass_delays(iAllPass) , [0.1], 48e3);
    end
    
    % -----------------------------------------------------------------------
    % 6. Save BRIRs
    if(save_BRIR_wavs)
        hbar = parfor_progressbar(nDirs,'Please wait, saving (step 2/2)...');
        %SaveRenderingStructs(SRIR_data, BRIR_data)
        parfor iDir = 1:nDirs
            SaveBRIR(SRIR_data, BRIR_data, DS_BRIR(:,:,iDir), early_BRIR(:,:,iDir), ER_BRIR(:,:,iDir), late_BRIR,BRIR_data.Directions(iDir,:));
            hbar.iterate(1);
        end
        close(hbar)
    end
    
    if(save_BinSim_mat_txt)
        
        fileID=0;
        
        hbar = parfor_progressbar(nDirs,'Please wait, saving (step 2/2)...');
        for iDir = 1:nDirs

            % Write filtermap
            pitch= BRIR_data.Directions(iDir,2);
            yaw=BRIR_data.Directions(iDir,1);
            
            %fprintf(fileID,'%s %d %d %d %d %d %d %d %d %d %s \n','DS',irs.micPos(1),irs.micPos(2), yaw, pitch, 0, 0, 0 ,0 ,0 , ds_name);
            %fprintf(fileID,'%s %d %d %d %d %d %d %d %d %d %s \n','ER',irs.micPos(1),irs.micPos(2), yaw, pitch, 0, 0, 0 ,0 ,0 , early_name);
            
            % Save to binsim struct
            struct_it = struct_it+1;
            binsim(struct_it) = binsim_default;
            binsim(struct_it).type = 'DS';
            binsim(struct_it).listenerOrientation = [yaw,pitch,0];
            binsim(struct_it).listenerPosition = [irs.micPos(1), irs.micPos(2),irs.micPos(3)]*m_dist_scale;
            binsim(struct_it).sourceOrientation = [round(irs.speakerAzEl{idxSpeaker}),0];
            binsim(struct_it).sourcePosition = irs.speakerPos{idxSpeaker}*m_dist_scale;
            %binsim(struct_it).listenerPosition = [irs.micPos(1), irs.micPos(2),0]*m_dist_scale;
            %binsim(struct_it).sourceOrientation = [0,0,0];
            %binsim(struct_it).sourcePosition = [0,0,0];
            binsim(struct_it).custom = [0,0,0];
            binsim(struct_it).filter = single(DS_BRIR(:,:,iDir)./db2mag(BRIR_data.Attenuation));
            
            struct_it = struct_it+1;
            binsim(struct_it) = binsim_default;
            binsim(struct_it).type = 'ER';
            binsim(struct_it).listenerOrientation = [yaw,pitch,0];
            binsim(struct_it).listenerPosition = [irs.micPos(1), irs.micPos(2),irs.micPos(3)]*m_dist_scale;
            binsim(struct_it).sourceOrientation = [round(irs.speakerAzEl{idxSpeaker}),0];
            binsim(struct_it).sourcePosition = irs.speakerPos{idxSpeaker}*m_dist_scale;
            %binsim(struct_it).listenerPosition = [irs.micPos(1), irs.micPos(2),0]*m_dist_scale;
            %binsim(struct_it).sourceOrientation = [0,0,0];
            %binsim(struct_it).sourcePosition = [0,0,0];
            binsim(struct_it).custom = [0,0,0];
            binsim(struct_it).filter = single(ER_BRIR(:,:,iDir)./db2mag(BRIR_data.Attenuation));
            
        end
        %SaveRenderingStructs(SRIR_data, BRIR_data)
        close(hbar)
        
        % add latereverb to binsim struct
        struct_it = struct_it+1;
        binsim(struct_it) = binsim_default;
        binsim(struct_it).type = 'LR';
        binsim(struct_it).listenerOrientation = [0,0,0];
        binsim(struct_it).listenerPosition = [irs.micPos(1), irs.micPos(2),irs.micPos(3)]*m_dist_scale;
        binsim(struct_it).sourceOrientation = [round(irs.speakerAzEl{idxSpeaker}),0];
        binsim(struct_it).sourcePosition = irs.speakerPos{idxSpeaker}*m_dist_scale;
        %binsim(struct_it).sourceOrientation = [0,0,0];
        %binsim(struct_it).sourcePosition = [0,0,0];
        binsim(struct_it).custom = [0,0,0];
        binsim(struct_it).filter = single(late_BRIR./db2mag(BRIR_data.Attenuation));
        
        store_filename = strrep(filename,'.mat','');
        
        struct_path = [BRIR_data.DestinationPath,store_filename,'_',struct_database_name];
        
        newstructname = append('binsim_', num2str(idxSpeaker));
        assignin('base',newstructname, binsim )
        clear binsim
        struct_it = 0;
        
        if idxSpeaker == 1
            save(struct_path,newstructname,'-v7','-nocompression')
        else
            save(struct_path,newstructname,'-append','-nocompression')
        end
        
    end
    
    
    
    if(save_irs_mat)
        
        %irs.BRIR_DS(idxSpeaker)={single(DS_BRIR)};
        %irs.BRIR_ER(idxSpeaker)={single(ER_BRIR)};
        %irs.BRIR_LR(idxSpeaker)={single(late_BRIR)};
        
        BRIRs = zeros(length(late_BRIR),2,nDirs);
        for iDir = 1:nDirs
            BRIRs(1:length(DS_BRIR(:,:,iDir)),:,iDir) = BRIRs(1:length(DS_BRIR(:,:,iDir)),:,iDir) + DS_BRIR(:,:,iDir);
            BRIRs(1:length(ER_BRIR(:,:,iDir)),:,iDir) = BRIRs(1:length(ER_BRIR(:,:,iDir)),:,iDir) + ER_BRIR(:,:,iDir);
            BRIRs(1:length(late_BRIR),:,iDir) = BRIRs(1:length(late_BRIR),:,iDir) + late_BRIR(:,:);
        end
        
        irs.BRIRs(idxSpeaker)={single(BRIRs)};
        
    end
    
    
end


if(save_irs_mat)
    irs.BRIRs_info.Directions = BRIR_data.Directions;
    irs.BRIRs_info.AzOrient = BRIR_data.AzOrient;
    irs.BRIRs_info.ElOrient = BRIR_data.ElOrient;
    irs.BRIRs_info.HRTF_Subject = BRIR_data.HRTF_Subject;
    irs.BRIRs_info.HRTF_Path = BRIR_data.HRTF_Path;
    irs.BRIRs_info.MixingTime = BRIR_data.MixingTime;
    save([filepath filename],'irs');
end







%% create data files for pyBinSim
if(save_BinSim_mat_txt)
    %pyBinSimSetting_SourcesListenerDefs.txt
    numChan = length(irs.speakerNames);
    sourceOrientation = zeros(numChan,3);
    sourcePosition = zeros(numChan,3);
    for idxSpeaker=1:numChan
        lenOri=length(irs.speakerAzEl{idxSpeaker});
        sourceOrientation(idxSpeaker,1:lenOri) = irs.speakerAzEl{idxSpeaker}(1:lenOri);
        sourcePosition(idxSpeaker,:) = irs.speakerPos{idxSpeaker}*m_dist_scale;
    end
    
    listenerPosition=[irs.micPos(1), irs.micPos(2),irs.micPos(3)]*m_dist_scale;
    
    T = [numChan,...
        reshape(sourcePosition',1,[]),...
        reshape(round(sourceOrientation'),1,[]),...
        listenerPosition,...
        min(AzOrient),max(AzOrient),AzStep,...
        min(ElOrient),max(ElOrient),ElStep];
    
    writematrix(T,'../03_BinSim_fixPos/pyBinSimSetting_SourcesListenerDefs.txt')
    writematrix(T,[BRIR_data.DestinationPath,store_filename,'_pyBinSimSetting_SourcesListenerDefs.txt'])
    
    
    %pyBinSimSettings_isoperare.txt: load file and rewrite with new data
    
    T_binsim_Path = '../03_BinSim_fixPos/pyBinSimSettings_isoperare.txt';
    T_binsim = readtable(T_binsim_Path,'ReadVariableNames', false);
    
    blocksize = 512;
    if(max(lenDS)<blocksize)
        f_DS = ceil(blocksize/max(lenDS));
        f_DS = 1/f_DS;
    else
        f_DS = ceil(max(lenDS)/blocksize);
    end
    
    f_ER = ceil(max(lenER)/blocksize);
    f_LR = ceil(max(lenLR)/blocksize);
    
    for idxT = 1 : height(T_binsim)
        switch(char(T_binsim{idxT,1}))
            case 'blockSize'
                T_binsim(idxT,2)={num2str(blocksize)};
            case 'ds_filterSize'
                T_binsim(idxT,2)={num2str(f_DS*blocksize)};
            case 'early_filterSize'
                T_binsim(idxT,2) = {num2str(f_ER*blocksize)};
            case 'late_filterSize'
                T_binsim(idxT,2) = {num2str(f_LR*blocksize)};
            case 'filterDatabase'
                T_binsim(idxT,2) = {struct_path};
            case 'maxChannels'
                T_binsim(idxT,2) = {num2str(numChan)};
            case 'samplingRate'
                T_binsim(idxT,2) = {num2str(fs)};
            otherwise
        end
    end
    writetable(T_binsim,T_binsim_Path,'WriteVariableNames', false,'Delimiter',' ')
    writetable(T_binsim,[BRIR_data.DestinationPath,store_filename,'_pyBinSimSettings_isoperare.txt'],'WriteVariableNames', false,'Delimiter',' ')
end


%eine BRIR rausspeichern

%BRIR = irs.BRIRs{3}(:,:,91);

