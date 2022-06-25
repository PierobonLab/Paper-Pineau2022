function [] = N_PovAddMesh(pov_file, K, V, mesh_name)
%N_PovAddMesh declares PovRay formatted triangular mesh to file specified
%             by filestream pov_file. 
%
% It is compatible with default output structure of faces K of convhull and 
% with vertices V obtained from 'PixelList' of 'regionprops' and used for
% computation of convhull.
%
% Inspired by: 
%   PovRay documentation on mesh2                    - http://www.povray.org/documentation/view/3.6.1/68/
%   Ankur Pawar website on exporting MATLAB Surfaces - https://sites.google.com/site/workofap/3d/matlab3d 
%
% INPUT:
%   pov_file  - file stream to the pov_file being used
%   K         - matrix containing faces of the mesh surface
%   V         - matrix of containing vertices of the surface
%   mesh_name - Optional name for the mesh to be used. (Default: 'meshname')
%
% OUTPUT:
%   none
%
% OUTPUT FILES:
%   An addition to PovRay file in the same directory as location of function execution,
%   containing declaration of the mesh.
%

% Check if a mesh_name is given
if ~exist('mesh_name','var')
    mesh_name = 'meshname';
end

% Output mesh's declaration
fprintf(pov_file,['#declare ' mesh_name ' = mesh2 {\n' ]);

% Ouput vertices
fprintf(pov_file,'\t\t\t\tvertex_vectors{\n');

% Number of vertices
num_V = size(V,1);
fprintf(pov_file,'\t\t\t\t\t\t\t\t%d\n', num_V);

% Output vertices
fprintf(pov_file,'\t\t\t\t\t\t\t\t< %g, %g, %g >,\n', V(1:num_V-1,:)');
fprintf(pov_file,'\t\t\t\t\t\t\t\t< %g, %g, %g >\n', V(num_V,:)); % No coma at the end
fprintf(pov_file,'\t\t\t\t\t\t\t\t}\n');

% Output faces
K = K - 1; % PovRay faces are zero-indexed
fprintf(pov_file,'\t\t\t\tface_indices{\n');

% Number of faces
num_K = size(K,1);
fprintf(pov_file,'\t\t\t\t\t\t\t\t%d', num_K);
fprintf(pov_file,',\n\t\t\t\t\t\t\t\t< %d, %d, %d >',K(1:num_K-1,:)'); 
fprintf(pov_file,',\n\t\t\t\t\t\t\t\t< %d, %d, %d >',K(num_K,:)); % No coma at the end
fprintf(pov_file,'\n\t\t\t\t\t\t\t\t}\n');

fprintf(pov_file,'\t\t\t\t}');

end