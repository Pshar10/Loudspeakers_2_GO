function varargout = mrdivide(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

error(nargchk(2,2,nargin,'string'));
if isa(varargin{1},'itaValue') || isnumeric(varargin{1})
   varargout{1} = ita_amplify(varargin{2}^-1,varargin{1});
   return;
elseif isa(varargin{2},'itaValue') || isnumeric(varargin{2})
    varargout{1} = ita_amplify(varargin{1},1/varargin{2});
    return;
end

allIsWell = false;
if isa(varargin{1},'itaSuper')
    allIsWell = all(isFreq(varargin{1}));
    if isa(varargin{2},'itaSuper')
        allIsWell = allIsWell && all(isFreq(varargin{2}));
    end
end

if allIsWell
    varargout{1} = mrdivide@itaSuper(varargin{:});
else
    error('itaResult.mrdivide:your signals are not in the frequency domain, use operator ./ instead!');
end

end