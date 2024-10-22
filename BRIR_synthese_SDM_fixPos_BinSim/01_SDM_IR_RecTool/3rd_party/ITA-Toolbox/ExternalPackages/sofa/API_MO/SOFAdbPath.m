function [dbPath,f]=SOFAdbPath(newPath)
% [dbPath,f]=SOFAdbPath 
%
%   [dbPath,f]=SOFAdbPath returns the path to the directory containing
%   HRTFs for demos and applications. It also returns the system-specific 
%		file separator for creating file names. 
% 
%   [...]=SOFAdbPath(Path) sets the path to the directory for further calls
%   of SOFAdbPath.

% SOFA API - function SOFAstart
% Copyright (C) 2012-2013 Acoustics Research Institute - Austrian Academy of Sciences
% Licensed under the EUPL, Version 1.1 or � as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "License")
% You may not use this work except in compliance with the License.
% You may obtain a copy of the License at: http://joinup.ec.europa.eu/software/page/eupl
% Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing  permissions and limitations under the License.

f=filesep;

persistent CachedPath;

if exist('newPath','var')
  CachedPath=newPath;
elseif isempty(CachedPath)
  basepath=which('SOFAstart');
  basepath=basepath(1:end-length('SOFAstart')-3); % Kill the function name from the path.
  CachedPath=fullfile(basepath, '..', 'HRTFs');
end
dbPath=CachedPath;

  