function position = find_direct_path(IR,Fs,MinPeakHeight)
% IR --> RIR or BRIR
% Fs --> sampling rate
% MinPeakHeight   --> threshold for peak detection (NORMALIZED SIGNAL!!); if not specified -> default = 0.05  
% IRs must be column vectors  
% If IR is a matrix of impulse responses, the function returns a vector of
% direct path positions 

if nargin < 3 
    mph = 0.02; 
else
    mph = MinPeakHeight;
end

[IR_length, numCh] = size(IR);

if numCh > IR_length
    error('Number of channels is bigger than the channel length. Did you transpose the IR Vector/Matrix?') 
end

mpd = Fs*.001; % minimum peak distance; neglecting other peaks in the vicinity of the true peak 

position = zeros(1,numCh);

for k = 1:numCh
   temp = IR(:,k)./max(abs(IR(:,k))); % normalize signals to 1 
   [~,position(k)] = findpeaks(temp,'MinPeakDistance',mpd,'MinPeakHeight',mph,'NPeaks',1); 
end

end 