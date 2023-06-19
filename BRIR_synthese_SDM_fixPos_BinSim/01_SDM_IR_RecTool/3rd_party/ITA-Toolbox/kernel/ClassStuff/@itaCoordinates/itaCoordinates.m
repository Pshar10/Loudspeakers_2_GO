% This class allows to store the coordinates of a point in the 3d space.
% (value class for cartesian 3d-coordinates)

% Autor: Martin Pollow <mpo@akustik.rwth-aachen.de>
% 19.7.2009

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

classdef itaCoordinates
    properties(Access=private)
        mCoord = [NaN NaN NaN];          % [nPoints 3]
        mCoordSystem = 'cart';           % 'cart' | 'sph' |'cyl'
        mWeights = [];
    end
    
    properties(Access=protected)
        mPtrtree = []; % need this for findnearest, MMT
    end
    
    properties(Dependent)
        % supported coordinate systems:
        cart; x; y; z
        sph; r; theta; phi
        cyl; rho % using phi and z also     
        % and in degree angles:
        theta_deg; phi_deg;
        
        nPoints    % number of points in stored here
        azimuth; elevation
        weights % can be a vector or a single number
    end
    
    methods
        function this = itaCoordinates(varargin)
            if nargin == 0
                %% itaCoordinates() -> [x, y, z] = empty 0 x 3
                this.mCoord = nan(0,3);
            elseif nargin == 1
                if isa(varargin{1},'itaCoordinates')
                    %% copy constructor
                    this.mCoord = varargin{1}.mCoord;
                    this.mCoordSystem = varargin{1}.mCoordSystem;
                    this.mWeights = varargin{1}.mWeights;
                    % c = itaCoordinates(3) -> three points of NaNs (default system)
                elseif isscalar(varargin{1}) && isnumeric(varargin{1})
                    %% itaCoordinates(n) --> n points of NaNs
                    nPoints = varargin{1};
                    this.mCoord = nan(nPoints,3);
                    % c = itaCoordinates(struct) -> import result from class2struct
                elseif all(isnumeric(varargin{1})) && size(varargin{1},2) == 3
                    %% itaCoordinates([x y z])
                    this.mCoord = varargin{1};
                elseif isstruct(varargin{1})
                    %% struct input/convert
                    fieldName = fieldnames(varargin{1});
                    for ind = 1:numel(fieldName);
                        try
                            this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                        catch errmsg
                            % Wrong case handling (old/headerless) itaCoordinates
                            try % Just another try, case-insensitive this time
                                realfieldnames = fieldnames(this);
                                if strcmp(fieldName{ind}(1),'m') % Member field, try without m
                                    fieldind = strcmpi(realfieldnames, fieldName{ind}(2:end));
                                else
                                    fieldind = strcmpi(realfieldnames,fieldName{ind});
                                end
                                this.(realfieldnames{fieldind}) = varargin{1}.(fieldName{ind});
                            catch errmsg
                                ita_verbose_info(['Field ' fieldName{ind} ' does not exist or is not compatible'],1)
                                %disp(errmsg);
                            end
                        end
                    end
                    % for now always save and load as cart
                    % this.mCoordSystem = 'cart';
                end
                % c = itaCoordinates([1 2 3; 4 5 6], 'cart')
            elseif nargin == 2
                this.mCoord = varargin{1};
                this.mCoordSystem = varargin{2};
            end
        end
        
        function result = coordSystem(this)
            result = this.mCoordSystem;
        end
        
        % replaces subsref
        function this = n(this,index)
            % error check: do nothing, if out of bound or nothing given
            if nargin < 2 || isempty(this.mCoord), return; end;
            this.mCoord = this.mCoord(index,:);
        end
        
        function this = set.mCoord(this, value)
            % if the value is twisted, twist back
            if size(value,2) ~= 3
                error([mfilename('class') '  invalid size of input data']);
            end
            this.mCoord = value;
        end
        function this = set.mCoordSystem(this, value)
            isSingleString = ischar(value);
            if isSingleString && ismember(value, {'cart','sph','cyl'})
                this.mCoordSystem = value;
            else
                error([mfilename('class') '  invalid string for coordinate system']);
            end
        end
        
        function value = get.x(this), value = this.cart(:,1); end
        function value = get.y(this), value = this.cart(:,2); end
        function value = get.z(this)
            if this.isCyl
                value = this.cyl(:,3);
            else
                value = this.cart(:,3);
            end
        end
        function value = get.cart(this)
            this = makeCart(this);
            value = this.mCoord;
        end
        function value = get.r(this), value = this.sph(:,1); end
        function value = get.theta(this), value = this.sph(:,2); end
        function value = get.phi(this)
            if this.isCyl
                value = this.cyl(:,2);
            else
                value = this.sph(:,3);
            end
        end
        function value = get.theta_deg(this), value = 180/pi * this.sph(:,2); end
        function value = get.phi_deg(this)
            if this.isCyl
                value = 180/pi * this.cyl(:,2);
            else
                value = 180/pi * this.sph(:,3);
            end
        end
        function value = get.sph(this)
            this = makeSph(this);
            value = this.mCoord;
        end
        function value = get.rho(this), value = this.cyl(:,1); end
        function value = get.cyl(this)
            this = makeCyl(this);
            value = this.mCoord;
        end
         
        function this = set.x(this, value), this.cart(:,1) = value; end
        function this = set.y(this, value), this.cart(:,2) = value; end
        function this = set.z(this, value)
            if this.isCyl
                this.cyl(:,3) = value;
            else
                this.cart(:,3) = value;
            end
        end
        function this = set.cart(this, value)
            this = makeCart(this);
            this.mCoord = value;
            this.mCoordSystem = 'cart';
        end
        
        function this = set.r(this, value), this.sph(:,1) = value; end
        function this = set.theta(this, value), this.sph(:,2) = value; end
        function this = set.phi(this, value)
            if this.isCyl
                this.cyl(:,2) = value;
            else
                this.sph(:,3) = value;
            end
        end
        function this = set.theta_deg(this, value), this.sph(:,2) = pi/180 * value; end
        function this = set.phi_deg(this, value)
            if this.isCyl
                this.cyl(:,2) = pi/180 * value;
            else
                this.sph(:,3) = pi/180 * value;
            end
        end
        function this = set.sph(this, value)
            this = makeSph(this);
            this.mCoord = value;
            this.mCoordSystem = 'sph';
        end
        
        function this = set.rho(this, value), this.cyl(:,1) = value; end
        function this = set.cyl(this, value)
            this = makeCyl(this);
            this.mCoord = value;
            this.mCoordSystem = 'cyl';
        end

        
        function this = set.weights(this, varargin)
            w = varargin{1};
            if numel(w) == 1
                w = w .* ones(this.nPoints,1);
            end
            this = this.set_weights(w);
        end
        
        function result = isCart(this)
            result = strcmp(this.mCoordSystem,'cart');
        end
        function result = isSph(this)
            result = strcmp(this.mCoordSystem,'sph');
        end
        function result = isCyl(this)
            result = strcmp(this.mCoordSystem,'cyl');
        end
        
        function result = get.azimuth(this)
            result = mod(this.phi,2*pi)/pi*180;
        end
        function this = set.azimuth(this,value)
            this.phi = mod(value/180*pi,2*pi);
        end
        function result = get.elevation(this)
            result = 90 - mod(this.theta,2*pi)/pi*180;
        end
        function this = set.elevation(this,value)
            this.theta = mod(pi/2 - value/180*pi,2*pi);
        end
        
        function value = get.nPoints(this)
            value = size(this.mCoord,1);
        end
        
        function value = get.weights(this)
            value = this.mWeights;
        end
        
        function this = makeCart(this)
            switch this.mCoordSystem
                case 'cart'
                    % do nothing
                case 'sph'
                    % sph2cart
                    r = this.mCoord(:,1);
                    theta = this.mCoord(:,2);
                    phi = this.mCoord(:,3);
                    % apply builtin transformation
                    [x,y,z] = sph2cart(phi, pi/2 - theta, r);
                    this.mCoord = [x y z];
                    this.mCoordSystem = 'cart';
                case 'cyl'
                    % cyl2cart
                    rho = this.mCoord(:,1);
                    phi = this.mCoord(:,2);
                    [x,y] = pol2cart(phi,rho);
                    this.mCoord(:,[1 2]) = [x y];
                    this.mCoordSystem = 'cart';
                    
                otherwise
                    error('internal bug of itaCoordinates');
            end
        end
        function this = makeSph(this)
            switch this.mCoordSystem
                case 'cart'
                    % cart2sph
                    x = this.mCoord(:,1);
                    y = this.mCoord(:,2);
                    z = this.mCoord(:,3);
                    % apply builtin transformation
                    [phiMod, thetaMod, r] =  cart2sph(x,y,z);
                    % phi = 0..2*pi
                    % theta = 0..pi
                    phi = mod(phiMod, 2*pi);
                    theta = pi/2 - thetaMod;
                    this.mCoord = [r theta phi];
                    this.mCoordSystem = 'sph';
                case 'sph'
                    % do nothing
                case 'cyl'
                    % cyl2sph
                    this = makeCart(this);
                    this = makeSph(this);
                    
                otherwise
                    error('internal bug of itaCoordinates');
            end
        end
        function this = makeCyl(this)
            switch this.mCoordSystem
                case 'cart'
                    % cart2cyl
                    x = this.mCoord(:,1);
                    y = this.mCoord(:,2);
                    z = this.mCoord(:,3);
                    
                    % apply builtin transformation
                    [phiMod, rho] =  cart2pol(x,y);
                    % phi = 0..2*pi
                    phi = mod(phiMod, 2*pi);
                    
                    this.mCoord = [rho phi z];
                    this.mCoordSystem = 'cyl';
                case 'sph'
                    % sph2cyl
                    this = makeCart(this);
                    this = makeCyl(this);
                case 'cyl'
                    % do nothing
                    
                otherwise
                    error('internal bug of itaCoordinates');
            end
        end
 
        function this = makeDaff(this)
            switch this.mCoordSystem
                case 'cart'
                    % cart2daff
                    this = makeSph(this);
                    this = makeDaff(this);
                case 'sph'
                    % sph2daff
                    a = 180/pi*this.mCoord(:,3);
                    b = 90-180/pi*this.mCoord(:,2);
                    r = this.mCoord(:,1);
                    this.mCoord = [a b r];
                    this.mCoordSystem = 'daff';
                case 'cyl'
                    % cyl2daff
                    this = makeSph(this);
                    this = makeDaff(this);
                    
                otherwise
                    error('internal bug of itaCoordinates');
            end
        end
        
        function result = split(this,index)
            result = this.n(index);
        end
        
        function this = merge(varargin)
            if numel(varargin) == 1 && numel(varargin{1}) == 1 %Only one element
                this = varargin{1};
            else
                this = merge(varargin{1});
                varargin(1) = [];
                for idx = 1:numel(varargin)
                    input = merge(varargin{idx});
                    this.(this.coordSystem) = [this.(this.coordSystem); input.(this.coordSystem)];
                end
            end
        end
        
        
        function this = resize(this,n)
            if n > size(this.mCoord,1)
                this.mCoord(end+1:n,:) = NaN;
            end
            if n < size(this.mCoord,1)
                this.mCoord((n+1):end,:) = [];
            end
        end
        
        function this = build_search_database(this)
            if exist('BuildGLTree','file') == 3
                this = clear_search_database(this);
                this.mPtrtree=BuildGLTree(this.cart);
            else
                disp('build_search_tree@itaCoordinates: External mex file not found');
            end
        end
        
        function this = clear_search_database(this)
            if ~isempty(this.mPtrtree) && exist('DeleteGLTree','file') == 3
                DeleteGLTree(this.mPtrtree);
            end
            this.mPtrtree = [];
        end
        
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Copy all properties that were defined to be saved
            propertylist = propertiesSaved_itaCoordinates(this);
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        function result = propertiesSaved_itaCoordinates(this)
            % always save as cart
            %             result = {'cart', 'classrevision'};
            result = {this.mCoordSystem, 'classrevision', 'weights'};
        end
        
    end
    methods(Access = private)
        function this = set_weights(this, varargin)
            this.mWeights = varargin{1};
        end
    end
    
    methods(Static)
        function tutorial
            edit ita_toolbox_tutorial_itaCoordinates;
        end
        function this = loadobj(sObj)
            % Called when an object is loaded
            if isfield(sObj,'classrevision'), sObj = rmfield(sObj,{'classrevision'}); end;
            if isfield(sObj,'classname'), sObj = rmfield(sObj,{'classname'}); end;
            if isfield(sObj,'userName'), sObj = rmfield(sObj,{'userName'}); end;
            try
                this = itaCoordinates(sObj); % Just call constructor, he will take care
            catch errmsg
                disp(errmsg);
                this = itaCoordinates();
            end
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 11705 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
    end
end
