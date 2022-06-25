function [ num_faces] = N_3DAddMesh(faces, vertices, mesh_name, resample, smoothing, stl_file, pov_file, origin, ascii_mode)
%N_3DAddMesh performs calls to add mesh to STL and/or POV files.
%
% This file was introduced to serve as a wrapper for output functions. This so
% that possible generic mesh simplifications and/or additional file formats
% can be easily implemented.
%
% INPUT:
%   faces      - matrix containing faces of the mesh surface
%   vertices   - matrix of containing vertices of the surface
%   mesh_name  - string specifying name to be used for the mesh.
%   resample   - scalar number less or equal to 1. Specifies fraction of
%                elements present in the mesh after resampling.
%   smoothing  - is a structure containing fields describing if smoothing
%                should be performed and if so, what are its parameters. See help
%                ExportVoxelData for more information on structure's fields.
%   stl_file   - file stream (or a scalar 0 depending if it is active) to stl
%                output file
%   pov_file   - file stream (or a scalar 0 depending if it is active) to pov
%                output file
%   origin     - vector definining new origin of the exported mesh in
%                Cartesian Coordinates
%   ascii_mode - Optional flag specifying if ascii output should be used.
%
% OUTPUT:
%   num_faces - scalar specifying number of faces exported to STL file. See help
%               N_StlAddMesh.m for more details
%
% OUTPUT FILES:
%   Addition of mesh description in STL format to file specified by
%   stl_file.
%   An addition to PovRay file in the same directory as location of function execution,
%   containing declaration of the mesh.
%

% Check for ascii_mode
if ~exist('ascii_mode','var')
    ascii_mode = 0; % Set to binary
end

% Predefine num_faces to prevent undeclared variable error
num_faces = 0;

% Resample if value different than 1
if resample < 1
    [faces, vertices] = N_MeshResample(faces, vertices, resample);
end

% Smooth if enabled
if smoothing.smooth
    [faces, vertices] = N_SmoothMesh(faces, vertices,...
                                     smoothing.mode, smoothing.itt,...
                                     smoothing.lambda, smoothing.sigma);
end

% Shift origin of the image (If inputed)
if exist('origin','var') && any((origin ~= 0))
    vertices = bsxfun(@minus, vertices, origin);
end

% If stl_file output is active
if stl_file >= 3
    num_faces = N_StlAddMesh(stl_file, faces , vertices, ascii_mode);    
end

% If pov_file output is active
if pov_file >=3
    N_PovAddMesh(pov_file, faces , vertices, mesh_name);
end


end