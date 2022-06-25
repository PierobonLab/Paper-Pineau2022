function [ num_facets ] = N_StlAddMesh(stl_file, K, V, ascii_mode)
%N_StlAddMesh adds STL type mesh to a stl_file. 
%             To create a working STL file requires execution of N_StlMakeFile 
%             upon completion of mesh export process.
%
% It is compatible with default output structure of faces K of convhull and 
% with vertices V obtained from 'PixelList' of 'regionprops' and used for
% computation of convhull.
%
% File is adapted from stlwrite.m script by Sven Holcombe, but extended to work
% with multiple mesh exports.
% 
% Website references:
% Original script stlwrite.m     - http://www.mathworks.com/matlabcentral/fileexchange/20922-stlwrite-write-binary-or-ascii-stl-file/content/stlwrite.m
% Description of STL file format = http://www.eng.nus.edu.sg/LCEL/RP/u21/wwwroot/stl_library.htm
% 
% INPUT:
%   stl_file   - file stream to temporary stl file
%   K          - matrix containing faces of the mesh surface
%   V          - matrix of containing vertices of the surface
%   ascii_mode - Optional flag specifying if ascii output should be used.
%                By default set to 0, i.e. binary output. 
%                Note: binary output should always be used, but ascii
%                      export is added for debugging purposes.
%
% OUTPUT:
%   num_faces - scalar specifying number of faces exported. This is a
%               critical number as it is used for proper file structure creation by
%               N_StlMakeFile. If ascii mode is used num_faces is exported
%               as 0.
%
% OUTPUT FILES:
%   Addition of mesh description in STL format to file specified by
%   stl_file.
%

% Check for ascii_mode
if ~exist('ascii_mode','var')
    ascii_mode = 0; % Set to binary output by default
end

% Create the facets
facets     = single(V');
facets     = reshape(facets(:,K'), 3, 3, []);
num_facets = size(facets, 3);

% Compute their normals
V1 = squeeze(facets(:,2,:) - facets(:,1,:));
V2 = squeeze(facets(:,3,:) - facets(:,1,:));
normals = V1([2 3 1],:) .* V2([3 1 2],:) - V2([2 3 1],:) .* V1([3 1 2],:);
clear V1 V2
normals = bsxfun(@times, normals, 1 ./ sqrt(sum(normals .* normals, 1)));
facets = cat(2, reshape(normals, 3, 1, []), facets);
clear normals

if ascii_mode
    
    % Set num_facets to ascii output format
    num_facets = 0;
   
    % Output the mesh
    fprintf(stl_file,[...
        'facet normal %.7E %.7E %.7E\r\n' ...
        'outer loop\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'endloop\r\n' ...
        'endfacet\r\n'], facets);
     
else % BINARY
  
    % Output the mesh
    % Add one uint16(0) to the end of each facet using a typecasting trick
    facets = reshape(typecast(facets(:), 'uint16'), 12*2, []);
    % Set the last bit to 0. (Note: For some software can be used to set color)
    facets(end+1,:) = 0;
    fwrite(stl_file, facets, 'uint16');  
    
end

end