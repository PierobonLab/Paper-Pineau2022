function [ num_faces ] = N_3DAddVoxelDataConvexHull(Voxel_List, mesh_name, resample, smoothing, stl_file, pov_file, origin)
%N_3DAddVoxelDatsConvexHull converts voxel data into mesh structure using convhull
%                           MATLAB command, simplifes and reduces mesh size and 
%                           outputs such mesh to STL and/or PovRay format.
%
% INPUT:
%   Voxel_List - N-by-3 matrix containing list of N non-zero voxels in
%                Cartesian Coordinates.
%   mesh_name  - string specifying name to be used for the mesh.
%   resample   - scalar number less or equal to 1. Specifies fraction of
%                elements present in the mesh after resampling.
%   smoothing  - is a structure containing fields describing if smoothing
%                should be performed and if so, what are its parameters. See help
%               ExportVoxelData for more information on structure's fields.
%   stl_file   - file stream (or a scalar 0 depending if it is active) to stl
%                output file
%   pov_file   - file stream (or a scalar 0 depending if it is active) to pov
%                output file
%   origin     - vector definining new origin of the exported mesh in
%                Cartesian Coordinates
%
% OUTPUT:
%   num_faces  - scalar specifying number of faces exported to STL file. See help
%                N_StlAddMesh.m for more details
%
% OUTPUT FILES:
%   Addition of mesh description in STL format to file specified by
%   stl_file.
%   An addition to PovRay file in the same directory as location of function execution,
%   containing declaration of the mesh.
%

% Convex hull computation (Note: Simplify flag)
K = convhull(Voxel_List,'Simplify',true);

% Indices of Face Voxels
face_voxels = K(:);
   
% Remove duplicates
face_voxels = unique(face_voxels);
    
% Create new voxel list
Voxel_List = Voxel_List(face_voxels,:);
    
% Recompute the hull to obtain correct referencing with respet to new vertices
K = convhull(Voxel_List); % Simplify is uncessary as it had been already performed 

% Export data
num_faces = N_3DAddMesh(K, Voxel_List, mesh_name, resample, smoothing, stl_file, pov_file, origin);

end
