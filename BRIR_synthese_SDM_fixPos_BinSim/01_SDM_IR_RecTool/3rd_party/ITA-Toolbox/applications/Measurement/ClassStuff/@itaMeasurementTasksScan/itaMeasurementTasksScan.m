classdef itaMeasurementTasksScan < itaMeasurementTasks
    % Measurement Tasks Scan are unified Setups for common Measurements
    % with several measurement positions. e.g. Italian or XY or Vibrometer.
    % There are no instances of this class. This class is more or less like
    % an abstract super class.
    
    % Author: Pascal Dietrich - Mai 2010
    
    % ---------------------------------------------------------------------
    % Continuous Measurement added. Now three points of the position object
    % are discribing the measurement. First point is the start position,
    % second the moving vector.
    % Be aware that only the phi-direction is implemented!
    %
    % Benedikt Krechel - Januar 2011
    
    % <ITA-Toolbox>
    % This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    
    % *********************************************************************
    % *********************************************************************
    properties
        waitBeforeMeasurement = 0; % time in seconds to wait before each measurement starts
        ContinuousMeasurement = 0; % true for continuous measurements
        % jck: added for Slayer room measurements
        SeparateMeasurement = 0; % true for continuous measurements
    end
    properties (Hidden = false, SetObservable = true, AbortSet = true)
            measurementPositions = itaCoordinates(); %itaCoordinates Obj with measurement positions to be measured
    end
    properties (Hidden = true)
        mLastMeasurement = 0; %ID of last measurement
        mCurrentPosition = cart2sph(itaCoordinates(1)); % itaCoordinates
    end
    % *********************************************************************
    % *********************************************************************
    properties (Access = protected, Hidden = true)
        mSerialObj       = [];%store the serial Obj in here
    end
    % *********************************************************************
    % *********************************************************************
    methods
%         jck/mpo: commented out due to problems with setting the measurement positions, 4.4.13 
%         function this = itaMeasurementTasksScan
%             addlistener(this,'measurementPositions','PostSet',@this.sort_measurement_positions);
%         end
        function result = isReferenced(this)
            %return 1 if the Obj has been moved to reference position
            result = ~(any(isnan(this.mCurrentPosition.sph)));
        end
        
        function result = currentPosition(this)
            %get the coordinates of the current position ID
            result = this.mCurrentPosition;
        end
        
        function run(this)
            if this.ContinuousMeasurement
                if mod(this.measurementPositions.nPoints, 2) ~= 0
                    ita_verbose_info(['Number of positions must be a multiple of 2 for continuous measurements [Startposition/Speedvector]!'],0);
                    return;
                end
            end
            % Start the measurement, go thru the entire list of measurement
            % positions
            if this.mLastMeasurement == 0
                this.moveTo(this.measurementPositions.n(1));
            end
            posStarted  = this.mLastMeasurement;
            timeStarted = now;
            
            if ~isdir(this.dataPath)    %maku 14.07.2010
                mkdir(this.dataPath);   %makes shure that it works after a user's this.reset without calling this.init
            end
            if ~isdir(this.finalDataPath)
                mkdir(this.finalDataPath);
            end
            
            while this.mLastMeasurement < this.measurementPositions.nPoints
                %% do the measurement
                if this.ContinuousMeasurement
                    result = this.runContinuousMeasurement;
                else
                    result = this.runMeasurement;
                end
                
                %% write data
                if this.ContinuousMeasurement
                    filename_raw    = [int2str(this.mLastMeasurement/2) '.ita'];
                else
                    filename_raw    = [int2str(this.mLastMeasurement) '.ita'];
                end
                filename        = [this.dataPath filesep filename_raw];
                filename_final  = [this.finalDataPath filesep filename_raw];
                ita_write(result,filename);
                movefile(filename,filename_final); %speed reasons - pdi
                
                %% time remaining
                time_elapsed = (now - timeStarted)*24*60*60;
                time_remaining = (this.measurementPositions.nPoints - this.mLastMeasurement) * time_elapsed / max(this.mLastMeasurement - posStarted - 0.5,1);
                time_finished = now + time_remaining/60/60/24;
                if this.ContinuousMeasurement
                    disp([int2str(this.mLastMeasurement/2) ' of ' int2str(this.measurementPositions.nPoints/2) ' done. ' num2str(time_elapsed/60,4) 'minutes elapsed, ' num2str(time_remaining/60,4) 'minutes left. Time of completion: ' datestr(time_finished)]);
                else
                    disp([int2str(this.mLastMeasurement) ' of ' int2str(this.measurementPositions.nPoints) ' done. ' num2str(time_elapsed/60,4) 'minutes elapsed, ' num2str(time_remaining/60,4) 'minutes left. Time of completion: ' datestr(time_finished)]);
                end
%                 if ~isempty(this.diaryFile) % jck: file becomes too large! Clipping can be found in errorLog
%                     diary off;
%                     diary([this.dataPath filesep this.diaryFile ]); %pdi changed to dataPath folder
%                 end
            end
            ita_verbose_info([num2str((now - timeStarted)*24) ' hours later...'],0);
%             diary off; % jck: see comment above
        end
        
        function result = runMeasurement(this,measurementNo)
            %run a single measurement, e.g. the result seems broken...
            % MS.runMeasurement(measurementNodeNumber)
            this.measurementSetup.reset = false;
            % Make measurement for Position # in measurementPositions
            if nargin < 2
                measurementNo = this.mLastMeasurement+1;
            end
            
            if measurementNo == 0
                save(this,[this.dataPath filesep 'iMS.mat']);
                measurementNo = 1;
            end
            
            % Go to position
            this.moveTo(this.measurementPositions.n(measurementNo));
            
            % wait some time?
            pause(this.waitBeforeMeasurement);
            
            % Run measurement
            % jck: added for Slayer room measurements
            if this.SeparateMeasurement
                result = this.measurementSetup.run_separate('crop',false);
            else
                result = this.measurementSetup.run;
            end
            
            % set channelCoordinates
            for idx = 1:numel(result)
                if ~sum(sum(isnan(result(idx).channelCoordinates.sph)))
                    result(idx).channelCoordinates = result(idx).channelCoordinates + repmat(this.measurementPositions.n(measurementNo), result(idx).nChannels);
                else
                    result(idx).channelCoordinates = repmat(this.measurementPositions.n(measurementNo), result(idx).nChannels);
                end
            end
            this.mLastMeasurement = measurementNo;
        end
        
        function result = runContinuousMeasurement(this, measurementNo)
            % TODO: @benedikt: das hat hier eigentlich nichts verloren!
            
            %run a single measurement, e.g. the result seems broken...
            % MS.runMeasurement(measurementNodeNumber)
            this.measurementSetup.reset = false;
            % Make measurement for Position # in measurementPositions
            if nargin < 2
                measurementNo = this.mLastMeasurement+1;
            end            
            if measurementNo == 0
                save(this,[this.dataPath filesep 'iMS.mat']);
                measurementNo = 1;
            end            
            % Go to position
            this.moveTo(this.measurementPositions.n(measurementNo)); % Maybe we need here some correction factors...
            
            % Prepare measurement move:
            this.prepare_move_turntable(9999, 'speed', this.measurementPositions.phi(measurementNo+1)/pi*180, 'wait', false, 'continuous', true);
            
            % Prepare measurement... (important for MSTFinterleaved,
            % otherwise we will waist time for generating the signal)
            if isa(this.measurementSetup, 'itaMSTFinterleaved')
                this.measurementSetup.final_excitation;
                this.measurementSetup.final_compensation;
            end
            
            % wait some time?
            pause(this.waitBeforeMeasurement);
            
            % Start movement (fast start) and run measurement:
            this.start_move_now;
            result = this.measurementSetup.run_raw_imc_dec;
            this.stop;
            % set channelCoordinates
            for idx = 1:numel(result)
                if ~sum(sum(isnan(result(idx).channelCoordinates.sph)))
                    result(idx).channelCoordinates = result(idx).channelCoordinates + repmat(this.measurementPositions.n(measurementNo), result(idx).nChannels);
                else
                    result(idx).channelCoordinates = repmat(this.measurementPositions.n(measurementNo), result(idx).nChannels);
                end
            end
            this.mLastMeasurement = measurementNo + 1;
            
        end
        
%         function this = sort_measurement_positions(this)    
%             ita_verbose_info('Oh Lord, this function is (more or less) abstract and therefore I will do NOTHING!.', 1);
%             % sort measurement positions
%         end
    end %methods
    
    % *********************************************************************
    % *********************************************************************
    methods (Abstract)
        this = moveTo(this)
        %do a move to get to this position
        
        this = reference(this)
        %go to reference, or do triangulization
        
        this = gui(this)
        %call a nice GUI for dummies
        
    end %methods abstract
    
    % *********************************************************************
    % *********************************************************************
end