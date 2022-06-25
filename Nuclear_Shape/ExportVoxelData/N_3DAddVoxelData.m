function [ ] = N_3DAddVoxelData(Voxel_List, mesh_name, stl_file, pov_file)
%N_3DAddVoxelDats converts voxel data into mesh structure and outputs such
%                 mesh to STL and/or PovRay format.
%
%
% Each cell can be reffered to eiter as an individual object or one can
% refer to all cells as a single object as particle_name_all.
%
% INPUT:
%   Region_Props - structure containing PixelList for every cell in
%                  Cartesian Coordinates
%   mesh_name    - optional string specifying base name to be used for mesh
%                  naming. (Default: 'test')
%
% OUTPUT:
%   none
%
% OUTPUT FILES:
%   A PovRay file in the same directory as location of function execution,
%   containing declarations of all cells.
%

% Convex hull computation (Note: Simplify flag)
K = convhull(Voxel_List,'Simplify',true);

% If stl_file output is active
if stl_file >= 3
    fprintf('STL export...');
    
    N_StlAddMesh(stl_file,K, Voxel_List, mesh_name);
    
    fprintf(' completed\n', mesh_name);  
    
end

% If pov_file output is active
if pov_file >=3
    fprintf('PovRay export...');
   
    % Indices of Face Voxels
    face_voxels = K(:);
   
    % Remove duplicates
    face_voxels = unique(face_voxels);
    
    % Create new voxel list
    Voxel_List = Voxel_List(face_voxels,:);
    
    % Recompute the hull to obtain correct referencing with respet to new vertices
    K = convhull(Voxel_List);
    
    % Output the mesh to pov_file
    N_PovAddMesh(pov_file, K, Voxel_List, mesh_name );
   
    fprintf(' completed\n\n', mesh_name);  
end

end
