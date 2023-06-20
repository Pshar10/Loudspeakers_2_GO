function varargout = ita_loudspeakertools_limiter(varargin)
%ITA_LOUDSPEAKERTOOLS_LIMITER - performs limiting function for loudspeakers
%  This function uses the thiele-small parameters of a loudspeaker to model
%  its behavior and perform a limitation of an input signal to achieve a
%  given maximum membrane excursion.
%
%  Modeling and limitation are done in time-discrete processing. The
%  block size  and limiter setings can be specified via the options.
%
%  Syntax:
%   audioObjOut = ita_loudspeakertools_limiter(TSparamIn,audioObjIn, options)
%
%   Options (default):
%           'limit' (Inf)           : limiter threshold
%           'blockSize' (8)         : block size in samples
%           'attackSamples' (48)    : attack duration
%           'holdSamples' (512)     : hold duration
%           'releaseFactor' (50)    : release slop in dB/s
%           'model' ('R_e')         : which loudspeaker model (R_e or none)
%
%  Example:
%   [limiterSignal,limitedExcursion] = ita_loudspeakertools_limiter(TS,input,'limit',3e-3)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_loudspeakertools_limiter">doc ita_loudspeakertools_limiter</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  23-May-2014 


%% Initialization and Input Parsing
sArgs = struct('pos1_TS', 'itaThieleSmall', 'pos2_input', 'itaAudio', 'limit', Inf, 'blockSize', 8, 'attackSamples', 48, 'holdSamples', 512, 'releaseFactor', 50, 'model', 'Re');
[TS, input, sArgs] = ita_parse_arguments(sArgs, varargin);
% possible models: none, Re

fs = input.samplingRate;
blockSize = sArgs.blockSize;
attackSamples = sArgs.attackSamples;
holdThreshold = 10^(1/20); % 1 dB to limiter threshold

%% build LS IIR filter from Thiele-Small parameters
% H(z) = X(z)/U(z) = (b0 + b1*z^-1 ...)/(a0 + a1*z^-1 ...)
% x(k)  = b(1)*u(k) + b(2)*u(k-1) + b(3)*u(k-2) + b(4)*u(k-3) - (a(1)*x(k-1) + a(2)*x(k-3) + a(3)*x(k-3))
% coefficients will be normalised by a0

% extract thiele-small parameters
R  = double(TS.R_e);
M  = double(TS.M);
n  = double(TS.n);
m  = double(TS.m);
w  = double(TS.w);

% if enclosure parameters are specified, do the necessary calculations
if ~isempty(TS.n_g)
    n = n*double(TS.n_g)/(n + double(TS.n_g));
end

if ~isempty(TS.w_g)
    w = w + double(TS.w_g);
end

% either no model (limit input voltage) or simple loudspeaker model
switch sArgs.model
    case 'none'
        b = [1 0];
        a = [1 0];
        
    case 'Re'
        a0 = R/n + 4*R*m*fs^2 + 2*fs*(M^2 + R*w);
        a1 = 2*(R/n - 4*R*m*fs^2);
        a2 = R/n + 4*R*m*fs^2 - 2*fs*(M^2 + R*w);
        
        a = [a0 a1 a2]./a0;
        b = M.*[1 2 1]./a0;
    otherwise
        error('wrong model type, can only be: none or Re');
end

% how many samples of IIR delay
order = numel(a)-1;

% delay by 1 block size + attack time + order
nBlock = ceil((order+blockSize+attackSamples+input.nSamples)/blockSize);
totalSamples = nBlock*blockSize;
extraSamples = totalSamples - (input.nSamples+attackSamples+blockSize+order);

%% apply to input
% input signal
rawInput            = [zeros(order,1); input.time; zeros(totalSamples - input.nSamples - order,1)];
% input signal shifted by attack time (+ 1 block size + order)
shiftedInput        = [zeros(order+blockSize+attackSamples,1); input.time; zeros(extraSamples,1)];
% calculated limiter signal
limiterSignal       = ones(size(shiftedInput));
% input limited by previous limiter value
limitedInput        = zeros(size(shiftedInput));
% output calculated with limited input
limitedOutput       = zeros(size(shiftedInput));
% limiter applied to shifted input
limitedShiftedInput = zeros(size(shiftedInput));
% output calculated with limited shifted input
limitedShiftedOutput = zeros(size(shiftedInput));

lastPeakRel = Inf;
gainReductionFactor = 1; % defines attack slope
% timers
attackTimer = 0;
holdTimer = 0;
% release slope
releaseFactor = sArgs.releaseFactor*0.02*(10^(50/20/fs)-1);
% duration of release period (determined by current output)
releaseSamples = 0;
filterStates = zeros(order,1);
filterStatesShifted = zeros(order,1);

for iBlock = 1:nBlock
    sampleIdxLin = min(order + (1:blockSize) + (iBlock-1)*blockSize,totalSamples);
    
    if ~isinf(sArgs.limit)        
        % get limiter state from last block and limited signal ...
        lastLimiterValue = limiterSignal(sampleIdxLin(1)-1);
        limitedInput(sampleIdxLin) = lastLimiterValue.*rawInput(sampleIdxLin);
        % ... and use it to calculate displacement
        [limitedOutput(sampleIdxLin),filterStates] = filter(b,a,limitedInput(sampleIdxLin),filterStates);
        
        % now determine limiter for current displacement
        peakVal = max(abs(limitedOutput(sampleIdxLin)));
        peakRel = sArgs.limit/peakVal;
        % get a dynamic release factor
        releaseFactorDyn = 1 + releaseFactor;
        
        % only if new peak is observed
        if peakRel < 1 && peakRel < lastPeakRel
            lastPeakRel = peakRel;
            gainReductionFactor = peakRel.^(1/attackSamples);
            % reset timers
            releaseSamples = 0;
            holdTimer   = 0;
            attackTimer = attackSamples;
        end
        
        % attack state
        if attackTimer > 0
            attackSamplesLeft = min(attackTimer,blockSize);
            % apply reduction factor during attack time
            limiterSignal(sampleIdxLin(1:attackSamplesLeft)) = lastLimiterValue.*(gainReductionFactor.^(1:attackSamplesLeft));
            attackTimer = attackTimer - attackSamplesLeft;
            
            % start hold phase in this block
            if attackTimer == 0
                holdTimer = sArgs.holdSamples - (blockSize - attackSamplesLeft);
                limiterSignal(sampleIdxLin(attackSamplesLeft+1:blockSize)) = limiterSignal(sampleIdxLin(attackSamplesLeft));
                lastPeakRel = Inf;
            end
            % hold state
        elseif attackTimer == 0 && holdTimer > 0
            if peakRel < holdThreshold
                holdTimer = sArgs.holdSamples;
            end
            holdSamplesLeft = min(holdTimer,blockSize);
            % hold last value during hold time
            limiterSignal(sampleIdxLin(1:holdSamplesLeft)) = lastLimiterValue;
            holdTimer = holdTimer - holdSamplesLeft;
            
            % start release phase in this block
            if holdTimer == 0
                % get current value ...
                releaseVal = min(1,limiterSignal(sampleIdxLin(holdSamplesLeft)));
                % ... and determine release duration
                releaseSamples = ceil(-log(releaseVal)/log(releaseFactorDyn));
                releaseSamplesLeft = min(releaseSamples,blockSize-holdSamplesLeft);
                % apply release factor
                limiterSignal(sampleIdxLin(holdSamplesLeft+(1:releaseSamplesLeft))) = releaseVal.*(releaseFactorDyn.^(1:releaseSamplesLeft));
                releaseSamples = releaseSamples - releaseSamplesLeft;
            end
        elseif holdTimer == 0 && releaseSamples > 0
            releaseSamplesLeft = min(releaseSamples,blockSize);
            % apply release factor
            limiterSignal(sampleIdxLin(1:releaseSamplesLeft)) = lastLimiterValue.*(releaseFactorDyn.^(1:releaseSamplesLeft));
            releaseSamples = releaseSamples - releaseSamplesLeft;
        end
    end
    
    % limiterSignal is complete
    % now apply to shifted input ...
    limitedShiftedInput(sampleIdxLin) = shiftedInput(sampleIdxLin).*limiterSignal(sampleIdxLin);
    % ... and get final limited excursion output
    [limitedShiftedOutput(sampleIdxLin),filterStatesShifted] = filter(b,a,limitedShiftedInput(sampleIdxLin),filterStatesShifted);
end

limiter = itaAudio(limiterSignal(:),fs,'time');
limOut = itaAudio(limitedShiftedOutput(:),fs,'time');

%% Add history line
limiter = ita_metainfo_add_historyline(limiter,mfilename,varargin);
limOut = ita_metainfo_add_historyline(limOut,mfilename,varargin);

%% Set Output
varargout(1) = {limiter};
varargout(2) = {limOut};

%end function
end