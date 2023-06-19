function ita_writeunv15(varargin)
%ITA_WRITEUNV15 - write a mesh to a unv file
%  This function takes a mesh object, as generated by ITA_BEAM_MAKEARRAY or
%  ITA_READUNV2411, and writes it as a unv15 dataset to the specified file.
%
%  Syntax:
%   ita_writeunv15(meshStruct,unvFilename)
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_writeunv15">doc ita_writeunv15</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  10-Jun-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_Mesh','itaCoordinates','pos2_unvFilename','string');
[Mesh,unvFilename,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

if isa(Mesh,'itaMeshNodes') && ~isempty(Mesh.ID)
    ids = Mesh.ID(:);
else
    ids = 1:Mesh.nPoints;
end

%%
% get the data of the mesh
X   = Mesh.x(:);
Y   = Mesh.y(:);
Z   = Mesh.z(:);

% structure for writeuff
DS{1}.dsType = 15;
DS{1}.binary = 0;
DS{1}.nodeN = ids;
DS{1}.x = X;
DS{1}.y = Y;
DS{1}.z = Z;

writeuff(unvFilename,DS,'replace');

%end function
end