% Copyright (c) Facebook, Inc. and its affiliates.

function SaveBRIR(SRIR_data, BRIR_data, DS_BRIR, early_BRIR, ER_BRIR, late_BRIR,ang)
% This function saves the BRIR dataset generated from the re-synthesis
% through SDM. 
% Input arguments:
%   - SRIR_data: Struct containing all the SRIR information (see
%   create_SRIR_data)
%   - BRIR_data: Struct containing BRIR information (see create_BRIR_data)
%   - DS_BRIR: Direct sound part of the BRIR
%   - early_BRIR: Early part of the BRIR (containing DS)
%   - ER_BRIR: Early reflections (without direct sound).
%   - late_BRIR: Angle independent late reverb tail.
%
%   Author: Sebasti� V. Amengual
%   Last modified: 11/17/2021

if isfield(BRIR_data,'customPath')
    Save_Path = [BRIR_data.DestinationPath  regexprep(BRIR_data.HRTF_Subject,' ','_'), '\' BRIR_data.customPath];
else
    Save_Path = [BRIR_data.DestinationPath  regexprep(BRIR_data.HRTF_Subject,' ','_'), '\' SRIR_data.Room '_' SRIR_data.SourcePos '_' SRIR_data.ReceiverPos];
end    

if ~exist([Save_Path filesep], 'dir')
    mkdir([Save_Path filesep]);
end

attenuation = db2mag(BRIR_data.Attenuation);

if max(max(abs(DS_BRIR)))/attenuation>1
    error(['The exported BRIRs are clipping! - The max value is' num2str(max(abs(DS_BRIR))/attenuation)]);
end


%ds_name = [Save_Path filesep BRIR_data.RenderingCondition filesep 'az' num2str(ang(1)) 'el' num2str(ang(2)) '_DS.wav'];
%early_name = [Save_Path filesep BRIR_data.RenderingCondition filesep 'az' num2str(ang(1)) 'el' num2str(ang(2)) '_EARLY.wav'];
%late_name = [Save_Path filesep BRIR_data.RenderingCondition filesep 'LATE.wav'];
%audiowrite(ds_name,DS_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32);
%audiowrite(early_name,ER_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32);
%audiowrite(late_name,late_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32);
BRIR_all = late_BRIR;
BRIR_all(1:length(early_BRIR),:) = BRIR_all(1:length(early_BRIR),:)+early_BRIR(1:end,:);
audiowrite([Save_Path filesep 'az' num2str(ang(1)) 'el' num2str(ang(2)) '.wav'],BRIR_all./attenuation,BRIR_data.fs,'BitsPerSample',32);


%audiowrite([Save_Path filesep BRIR_data.RenderingCondition filesep 'az' num2str(ang(1)) 'el' num2str(ang(2)) '.wav'],early_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32);
%audiowrite([Save_Path filesep BRIR_data.RenderingCondition filesep 'az' num2str(ang(1)) 'el' num2str(ang(2)) '_DS.wav'],DS_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32);
%audiowrite([Save_Path filesep BRIR_data.RenderingCondition filesep 'az' num2str(ang(1)) 'el' num2str(ang(2)) '_ER.wav'],ER_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32);
%audiowrite([Save_Path filesep BRIR_data.RenderingCondition filesep 'late_reverb.wav'],late_BRIR./attenuation,BRIR_data.fs,'BitsPerSample',32); 
