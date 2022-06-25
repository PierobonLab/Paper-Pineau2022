function [ num_faces ] = N_3DAddVoxelDataGeometric(BW_cell, corner, mesh_name, resample, smoothing, stl_file, pov_file, origin)
%N_3DAddVoxelDatsGeometric converts BW voxel data into mesh structure by computing a
%                          geometric mesh and outputs such mesh to STL and/or PovRay format.
%
% This file is just a wrapper which ensures compatibility.
% Main algorithm and actual geometric mesh computation is performed by a 
% script CONVERT_voxels_to_stl written by Adam H. Aitkenhead (See below for information) 
% available on Mathworks.com at:
% http://www.mathworks.com/matlabcentral/fileexchange/27733-converting-a-3d-logical-array-into-an-stl-surface-mesh.
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

% Flip image from matrix coordinates to cartesian coordinates
BW_cell = permute(BW_cell,[2 1 3]);

% Perform geometric voxelisation (Uses internal function written by Adam H.
% Aitkenhead. See below for more information)
[faces, vertices] = N_3DAddVoxelDataGeometricInternal(BW_cell);

% Shift back from extracted cell coordinates to global matrix frame of reference
vertices = bsxfun(@plus, vertices, corner);
        
% Export the mesh
num_faces = N_3DAddMesh(faces, vertices, mesh_name, resample, smoothing, stl_file, pov_file, origin);

end

% Internal functions of the script
% Functions were written by Adam H. Aitkenhead (See below for full
% information). Few modifications were made as to ensure compatibility with
% the main script.

function [varargout] = N_3DAddVoxelDataGeometricInternal(gridDATA)
% CONVERT_voxels_to_stl  Convert a voxelised object contained within a 3D logical array into an STL surface mesh
%==========================================================================
% AUTHOR        Adam H. Aitkenhead
% CONTACT       adam.aitkenhead@christie.nhs.uk
% INSTITUTION   The Christie NHS Foundation Trust
% DATE          24th May 2010
%
% EXAMPLE       CONVERT_voxels_to_stl(STLname,gridDATA,gridX,gridY,gridZ,STLformat)
%       ..or..  [faces,vertices] = CONVERT_voxels_to_stl(STLname,gridDATA,gridX,gridY,gridZ,STLformat)
%
% INPUTS        STLname   - string            - Filename of the STL file.
%
%               gridDATA  - 3D logical array of size (P,Q,R) - Voxelised data
%                                     1 => Inside the object
%                                     0 => Outside the object
%
%               gridX     - A 1xP array       - List of the X axis coordinates.
%               gridY     - A 1xQ array       - List of the Y axis coordinates.
%               gridZ     - A 1xR array       - List of the Z axis coordinates.
%
%               STLformat - string (optional) - STL file format: 'binary' or 'ascii'
%
% OUTPUTS       faces    - Nx3 array   - A list of the vertices used in
%                          each facet of the mesh, identified using the row
%                          number in the array vertices.
%
%               vertices - Nx3 array   - A list of the x,y,z coordinates of
%                          each vertex in the mesh.
%               
%==========================================================================

%==========================================================================
% VERSION  USER  CHANGES
% -------  ----  -------
% 100524   AHA   Original version
% 100526   AHA   Improved memory handling
% 100530   AHA   Major speed improvement
% 100818   AHA   Improved documentation
% 101123   AHA   Allow the STL to be written in binary or ascii format
% 110314   AHA   Tidied the code a little
% 120709   AHA   Optionally output the mesh (Faces,Vertices) data
%==========================================================================

% MODIFICATIONS
%   - Removed checking of input parameters and outputting to STL file.
%     This is now handled by the main script.
%   - Added computation of gridX, gridY and gridZ as to fit function's
%     requirements. Coordinate shifting etc. is performed by the main
%     script.

% Compute gridX, gridY, gridZ
gridX = 1:size(gridDATA,1);
gridY = 1:size(gridDATA,2);
gridZ = 1:size(gridDATA,3);

%======================================================
% DEFINE THE LOWER AND UPPER LIMITS OF EACH VOXEL
%======================================================

gridXsteps = gridX(2:end)-gridX(1:end-1);
gridXlower = gridX-[gridXsteps(1),gridXsteps]/2;
gridXupper = gridX+[gridXsteps,gridXsteps(end)]/2;

gridYsteps = gridY(2:end)-gridY(1:end-1);
gridYlower = gridY-[gridYsteps(1),gridYsteps]/2;
gridYupper = gridY+[gridYsteps,gridYsteps(end)]/2;

gridZsteps = gridZ(2:end)-gridZ(1:end-1);
gridZlower = gridZ-[gridZsteps(1),gridZsteps]/2;
gridZupper = gridZ+[gridZsteps,gridZsteps(end)]/2;

%======================================================
% CHECK THE DIMENSIONS OF THE GRID
%======================================================

voxcountX = numel(gridX);
voxcountY = numel(gridY);
voxcountZ = numel(gridZ);

%======================================================
% FOR EACH VOXEL, IDENTIFY WHETHER ITS 6 NEIGHBOURS ARE WITHIN THE OBJECT.
% IF ANY NEIGHBOUR IS OUTSIDE THE OBJECT, DRAW FACETS BETWEEN THE VOXEL AND
% THAT NEIGHBOUR.
%======================================================

gridDATAshifted = false(size(gridDATA));
if voxcountX>2
  gridDATAwithborder = cat(1,false(1,voxcountY,voxcountZ),gridDATA,false(1,voxcountY,voxcountZ));         %Add border
  gridDATAshifted    = cat(1,false(1,voxcountY,voxcountZ),gridDATAshifted,false(1,voxcountY,voxcountZ));  %Add border
  gridDATAshifted    = gridDATAshifted + circshift(gridDATAwithborder,[-1,0,0]) + circshift(gridDATAwithborder,[1,0,0]);
  gridDATAshifted    = gridDATAshifted(2:end-1,:,:);  %Remove border
end
if voxcountY>2
  gridDATAwithborder = cat(2,false(voxcountX,1,voxcountZ),gridDATA,false(voxcountX,1,voxcountZ));         %Add border
  gridDATAshifted    = cat(2,false(voxcountX,1,voxcountZ),gridDATAshifted,false(voxcountX,1,voxcountZ));  %Add border
  gridDATAshifted    = gridDATAshifted + circshift(gridDATAwithborder,[0,-1,0]) + circshift(gridDATAwithborder,[0,1,0]);
  gridDATAshifted    = gridDATAshifted(:,2:end-1,:);  %Remove border
end
if voxcountZ>2
  gridDATAwithborder = cat(3,false(voxcountX,voxcountY,1),gridDATA,false(voxcountX,voxcountY,1));         %Add border
  gridDATAshifted    = cat(3,false(voxcountX,voxcountY,1),gridDATAshifted,false(voxcountX,voxcountY,1));  %Add border
  gridDATAshifted    = gridDATAshifted + circshift(gridDATAwithborder,[0,0,-1]) + circshift(gridDATAwithborder,[0,0,1]);
  gridDATAshifted    = gridDATAshifted(:,:,2:end-1);  %Remove border
end

%Identify the voxels which are at the boundary of the object:
edgevoxelindices = find(gridDATA==1 & gridDATAshifted<6)';
edgevoxelcount   = numel(edgevoxelindices);

%Calculate the number of facets there wil be in the final STL mesh:
facetcount = 2 * (edgevoxelcount*6 - sum(gridDATAshifted(edgevoxelindices)) );

%Create an array to record...
%Cols 1-6: Whether each edge voxel's 6 neighbours are inside or outside the object.
neighbourlist = false(edgevoxelcount,6);

%Initialise arrays to store the STL mesh data:
meshXYZ    = zeros(facetcount,3,3);
normalsXYZ = zeros(facetcount,3);

%Create a counter to keep track of how many facets have been written as the
%following 'for' loop progresses:
facetcountsofar = 0;

for loopP = 1:edgevoxelcount
  
  [subX,subY,subZ] = ind2sub(size(gridDATA),edgevoxelindices(loopP));
  
  if subX==1
    neighbourlist(loopP,1) = 0;
  else
    neighbourlist(loopP,1) = gridDATA(subX-1,subY,subZ);
  end
  if subY==1
    neighbourlist(loopP,2) = 0;
  else
    neighbourlist(loopP,2) = gridDATA(subX,subY-1,subZ);
  end
  if subZ==voxcountZ
    neighbourlist(loopP,3) = 0;
  else
    neighbourlist(loopP,3) = gridDATA(subX,subY,subZ+1);
  end
  if subY==voxcountY
    neighbourlist(loopP,4) = 0;
  else
    neighbourlist(loopP,4) = gridDATA(subX,subY+1,subZ);
  end
  if subZ==1
    neighbourlist(loopP,5) = 0;
  else
    neighbourlist(loopP,5) = gridDATA(subX,subY,subZ-1);
  end
  if subX==voxcountX
    neighbourlist(loopP,6) = 0;
  else
    neighbourlist(loopP,6) = gridDATA(subX+1,subY,subZ);
  end
  
  facetCOtemp         = zeros(2*(6-sum(neighbourlist(loopP,:))),3,3);
  normalCOtemp        = zeros(2*(6-sum(neighbourlist(loopP,:))),3);
  facetcountthisvoxel = 0;
  
  if neighbourlist(loopP,1)==0   %Neighbouring voxel in the -x direction
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXlower(subX),gridYlower(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXlower(subX),gridYlower(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXlower(subX),gridYupper(subY),gridZlower(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [-1,0,0];
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXlower(subX),gridYupper(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXlower(subX),gridYupper(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXlower(subX),gridYlower(subY),gridZupper(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [-1,0,0];
    facetcountsofar                        = facetcountsofar+2;
  end
  if neighbourlist(loopP,2)==0   %Neighbouring voxel in the -y direction
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXlower(subX),gridYlower(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXupper(subX),gridYlower(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXlower(subX),gridYlower(subY),gridZupper(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [0,-1,0];
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXupper(subX),gridYlower(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXlower(subX),gridYlower(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXupper(subX),gridYlower(subY),gridZlower(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [0,-1,0];
    facetcountsofar                        = facetcountsofar+2;
  end
  if neighbourlist(loopP,3)==0   %Neighbouring voxel in the +z direction
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXupper(subX),gridYlower(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXupper(subX),gridYupper(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXlower(subX),gridYlower(subY),gridZupper(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [0,0,1];
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXlower(subX),gridYupper(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXlower(subX),gridYlower(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXupper(subX),gridYupper(subY),gridZupper(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [0,0,1];
    facetcountsofar                        = facetcountsofar+2;
  end
  if neighbourlist(loopP,4)==0   %Neighbouring voxel in the +y direction
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXupper(subX),gridYupper(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXlower(subX),gridYupper(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXupper(subX),gridYupper(subY),gridZupper(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [0,1,0];
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXlower(subX),gridYupper(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXupper(subX),gridYupper(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXlower(subX),gridYupper(subY),gridZlower(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [0,1,0];
    facetcountsofar                        = facetcountsofar+2;
  end
  if neighbourlist(loopP,5)==0   %Neighbouring voxel in the -z direction
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXlower(subX),gridYlower(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXlower(subX),gridYupper(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXupper(subX),gridYlower(subY),gridZlower(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [0,-1,0];
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXupper(subX),gridYupper(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXupper(subX),gridYlower(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXlower(subX),gridYupper(subY),gridZlower(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [0,-1,0];
    facetcountsofar                        = facetcountsofar+2;
  end
  if neighbourlist(loopP,6)==0   %Neighbouring voxel in the +x direction
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXupper(subX),gridYupper(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXupper(subX),gridYupper(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXupper(subX),gridYlower(subY),gridZlower(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [1,0,0];
    facetcountthisvoxel                    = facetcountthisvoxel+1;
    facetCOtemp(facetcountthisvoxel,1:3,1) = [ gridXupper(subX),gridYlower(subY),gridZupper(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,2) = [ gridXupper(subX),gridYlower(subY),gridZlower(subZ) ];
    facetCOtemp(facetcountthisvoxel,1:3,3) = [ gridXupper(subX),gridYupper(subY),gridZupper(subZ) ];
    normalCOtemp(facetcountthisvoxel,1:3)  = [1,0,0];
    facetcountsofar                        = facetcountsofar+2;
  end
  
  meshXYZ(facetcountsofar-facetcountthisvoxel+1:facetcountsofar,:,:)  = facetCOtemp;
  normalsXYZ(facetcountsofar-facetcountthisvoxel+1:facetcountsofar,:) = normalCOtemp;
  
end

%======================================================
% PREPARE THE OUTPUT ARGUMENTS
%======================================================

if nargout==2
  [faces,vertices] = CONVERT_meshformat(meshXYZ);
  varargout(1)     = {faces};
  varargout(2)     = {vertices};
end


end %function

function [varargout] = CONVERT_meshformat(varargin)
%CONVERT_meshformat  Convert mesh data from array to faces,vertices format or vice versa
%==========================================================================
% AUTHOR        Adam H. Aitkenhead
% CONTACT       adam.aitkenhead@physics.cr.man.ac.uk
% INSTITUTION   The Christie NHS Foundation Trust
% DATE          17th August 2010
%
% USAGE         [faces,vertices] = CONVERT_meshformat(meshXYZ)
%         or... [meshXYZ]        = CONVERT_meshformat(faces,vertices)
%
% IN/OUTPUTS    meshXYZ  - Nx3x3 array - An array defining the vertex
%                          positions for each of the N facets, with: 
%                            1 row for each facet
%                            3 cols for the x,y,z coordinates
%                            3 pages for the three vertices
%
%               vertices - Nx3 array   - A list of the x,y,z coordinates of
%                          each vertex in the mesh.
%
%               faces    - Nx3 array   - A list of the vertices used in
%                          each facet of the mesh, identified using the row
%                          number in the array vertices.
%==========================================================================

%==========================================================================
% VERSION  USER  CHANGES
% -------  ----  -------
% 100817   AHA   Original version
% 111104   AHA   Housekeeping tidy-up.
%==========================================================================


if nargin==2 && nargout==1

  faces  = varargin{1};
  vertex = varargin{2};
   
  meshXYZ = zeros(size(faces,1),3,3);
  for loopa = 1:size(faces,1)
    meshXYZ(loopa,:,1) = vertex(faces(loopa,1),:);
    meshXYZ(loopa,:,2) = vertex(faces(loopa,2),:);
    meshXYZ(loopa,:,3) = vertex(faces(loopa,3),:);
  end

  varargout(1) = {meshXYZ};
  
  
elseif nargin==1 && nargout==2

  meshXYZ = varargin{1};
  
  vertices = [meshXYZ(:,:,1);meshXYZ(:,:,2);meshXYZ(:,:,3)];
  vertices = unique(vertices,'rows');

  faces = zeros(size(meshXYZ,1),3);

  for loopF = 1:size(meshXYZ,1)
    for loopV = 1:3
        
      %[C,IA,vertref] = intersect(meshXYZ(loopF,:,loopV),vertices,'rows');
      %The following 3 lines are equivalent to the previous line, but are much faster:
      
      vertref = find(vertices(:,1)==meshXYZ(loopF,1,loopV));
      vertref = vertref(vertices(vertref,2)==meshXYZ(loopF,2,loopV));
      vertref = vertref(vertices(vertref,3)==meshXYZ(loopF,3,loopV));
      
      faces(loopF,loopV) = vertref;
      
    end
  end
  
  varargout(1) = {faces};
  varargout(2) = {vertices};
  
  
end

end %function

