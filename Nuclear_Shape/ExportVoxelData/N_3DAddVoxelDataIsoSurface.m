function [ num_faces ] = N_3DAddVoxelDataIsoSurface(BW_cell, corner, mesh_name, resample, smoothing, stl_file, pov_file, origin)
%N_3DAddVoxelDatsIsoSurface converts BW voxel data into mesh structure by computing an
%                           isosurface and outputs such mesh to STL and/or PovRay format.
%
%
% INPUT:
%   BW_cell   - matrix containing BW representation of voxel data
%   corner    - corner of the BW_cell as outputed by 'BoxingBox' in
%               regionprops. (i.e. Cartesian Coordinates)
%   mesh_name - string specifying name to be used for the mesh.
%   resample  - scalar number less or equal to 1. Specifies fraction of
%               elements present in the mesh after resampling.
%   smoothing - is a structure containing fields describing if smoothing
%               should be performed and if so, what are its parameters. See help
%               ExportVoxelData for more information on structure's fields.
%   stl_file  - file stream (or a scalar 0 depending if it is active) to stl
%               output file
%   pov_file  - file stream (or a scalar 0 depending if it is active) to pov
%               output file
%   origin    - vector definining new origin of the exported mesh in
%               Cartesian Coordinates
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

% Determine isosurface
[faces, vertices] = isosurface(1 + corner(1) : corner(1) + size(BW_cell,2),... % x coordinate
                               1 + corner(2) : corner(2) + size(BW_cell,1),... % y coordinate
                               1 + corner(3) : corner(3) + size(BW_cell,3),... % z coordinate
                               BW_cell); % Matrix with the cell
% Export the mesh
num_faces = N_3DAddMesh(faces, vertices, mesh_name, resample, smoothing, stl_file, pov_file, origin);

end
