function Obj = SOFAaddVariable(Obj,Name,Dim,Value)
%SOFAaddVariable
%   Obj = SOFAaddVariable(Obj,Name,Dim,Value) adds a user-defined variable
%   to the SOFA structure OBJ. NAME must be a string with the variable name 
%   ('API', 'PRIVATE', or 'GLOBAL' are not allowed). DIM is a string 
%   describing the dimensions of the variable according to SOFA specifications. 
%   The content of NAME is stored in VALUE which must be of the size DIM. 
%   The used-defined variable NAME will be stored as Obj.NAME and its
%   dimension will be stored as Obj.API.Dimensions.NAME. Note that user-
%   defined variables can be saved in SOFA file and thus remain in the 
%   object when loaded from a SOFA file. 
%
%   Obj = SOFAaddVariable(Obj,Name,'PRIVATE',Value) adds a private variable
%   to OBJ. The private variable NAME will be stored as Obj.PRIVATE.NAME. 
%   Note that the private variables will be not stored in SOFA files and
%   arbitrary dimensions are allowed.
%

% SOFA API - function SOFAaddVariable
% Copyright (C) 2012-2013 Acoustics Research Institute - Austrian Academy of Sciences
% Licensed under the EUPL, Version 1.1 or � as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "License")
% You may not use this work except in compliance with the License.
% You may obtain a copy of the License at: http://joinup.ec.europa.eu/software/page/eupl
% Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing  permissions and limitations under the License. 

switch upper(Dim)
  case 'PRIVATE'
    Obj.PRIVATE.(Name)=Value;
  otherwise
    switch Name 
      case {'API','PRIVATE','GLOBAL'}
        error('This variable name is reserved.');
      otherwise
      Obj.(Name)=Value;
      Obj.API.Dimensions.(Name)=Dim;
    end
end
