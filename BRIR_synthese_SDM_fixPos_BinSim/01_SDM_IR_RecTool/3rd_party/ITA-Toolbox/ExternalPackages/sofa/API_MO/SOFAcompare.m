function [tf,reason,where] = SOFAcompare(Obj1, Obj2, varargin)
%SOFASOFAcompare
%   TF = SOFAcompare(Obj1, Obj2) compares Obj1 and Obj2 and
%   returns logical 1 (true) if they are identical.
%
%   [TF,REASON,WHERE] = SOFAcompare(Obj1, Obj2, varargin) provides the REASON 
%   and shows WHERE the difference arose. 
%
%   Limited functionality!!! Only attributes are compared now.
%
%   
%

% SOFA API - function SOFAcompare
% Copyright (C) 2012-2013 Acoustics Research Institute - Austrian Academy of Sciences
% Licensed under the EUPL, Version 1.1 or � as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "License")
% You may not use this work except in compliance with the License.
% You may obtain a copy of the License at: http://joinup.ec.europa.eu/software/page/eupl
% Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing  permissions and limitations under the License. 

tf=1;
reason='';
where='';

%   % check if the size is equal
% o1=whos('Obj1');
% o2=whos('Obj2');
% if o1.bytes ~= o2.bytes, tf=0; reason='Different size'; return; end

  % check if we have the same fields in Obj2 as in Obj1
Xf=fieldnames(Obj1);
for ii=1:length(Xf)
  if ~isfield(Obj2,Xf{ii}), tf=0; reason='Field missing in Obj2'; where=Xf{ii}; return; end
end

  % check if we have the same content of attributes in Obj2 as in Obj1
for ii=1:length(Xf)
  if isempty(strfind(Xf{ii},'_')), continue; end
  if ~strcmp(Obj1.(Xf{ii}),Obj2.(Xf{ii})), tf=0; reason='Field not equal'; where=Xf{ii}; return; end
end

