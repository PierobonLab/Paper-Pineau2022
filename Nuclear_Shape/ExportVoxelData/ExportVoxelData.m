function [ ] = ExportVoxelData(export_data, varargin)
%ExportVoxelData permits export of voxel data (i.e. a 3D matrix) to STL
%                and/or PovRay mesh file formats.
%
% INPUT:
%   export_data - required input, containing Voxel Data. Script determines correct one
%                 automatically. Three types are accepted:
%                       - structure containing region properties such as
%                         'PixelList' and 'BoundingBox' (For isosurface option)
%                         Note: If only voxel list is available, create a dummy
%                         region properties structure, 
%                         i.e. dummy.PixelList = voxel_list
%                       - label matrix with objects' IDs in their location
%                       - a logical (BW) matrix. This can produce unexpected
%                         results during connected region properties computation
%                         if objects are not segmented.
%
% INPUT OPTIONS:
%   mesh_name    - optional mesh name to be given to meshes/files created.
%                  (Default is 'matlab_mesh')
%   method       - optional method used for determination of mesh. Two methods are
%                  implemented:
%                       - 'convhull'   - computes convex hull for each object. 
%                                        Note: this reduces required mesh size, however
%                                        some object features can be lost.
%                       - 'isosurface' - determines a mesh modelling the
%                                        object more accurately. This is
%                                        default setting. Requires region properties 
%                                        with field 'BoundingBox' and Label_Matrix. 
%                                        Both requirements can be generated
%                                        during program execution.
%                       - 'geometric'  - finds a mesh representing
%                                        geometric structure of all voxels. No smoothing is
%                                        performed. This is just pure data conversion. 
%                                        Requires input of label matrix and region properties with field
%                                       'BoundingBox'. Both requirements can be generated
%                                        during program execution.
%                                        Note: This computation uses script
%                                        written by Adam H. Aitkenhead.
%                                        Please see the
%                                        N_3DAddVoxelDataGeometric.m file
%                                        for detailed information.
%
%   resample     - optional scalar number less or equal to 1. Specifies fraction of
%                  elements present in the mesh after resampling. By
%                  default 1, i.e. all elements of the mesh are exported.
%
%   smoothing    - optional structure or logical variable (scalar 0 or 1 works as well). 
%                  This variable specifies parameters of mesh smoothing (structure entry) or 
%                  if smoothing should not be performed (logical value set to false). If no
%                  entry is present default smoothing will be performed.
%                  smoothing structure should contain:
%                       - 'mode'   - value 0 or 1 (default)
%                                    If zero uses inverse distance between vertices as weights. The
%                                    mesh becomes smoother but also edge distances more uniform
%                                    If one uses the normalized curvature operator as weights. The
%                                    mesh is mainly smoothed in the normal direction, thus the
%                                    orignal ratio in length between edges is preserved.
%                       - 'itt'    - Number of smoothing itterations (default 1)
%                       - 'lambda' - Amount of smoothing [0....1] (default 1)
%                       - 'sigma'  - (If mode is 0), Influence of neighbour point is 
%                                    Weight = 1 / ( inverse distance + sigma)   (default sigma=1);
%        
%                  Mesh smothing is performed using function implemented by
%                  Dirk-Jan Kroon. Parameter description is copied from his work. Please
%                  see N_SmoothMesh.m for more information.
%
%   label_matrix - if export_data entered is a regionprops structure and if 'isosurface' method is to be used 
%                  then label matrix can be entered with this option.
%
%   object_ids   - if isosurface is to be computed for just part of object
%                  present in the Label_Matrix, array specifying objects' IDs (in their
%                  entry sequence in region properties) must be entered
%
%   shift_origin - a scalar value specifying if an attempt to shift origin
%                  to geometrical matrix center should be made. (0 = no
%                  shift (Default), 1 = shift) May be supplemented with
%                  img_dim parameter.
%   
%   img_dim      - vector specifying matrix size, i.e. output of size(matrix_to_export)
%                  If inputed and no setting to shift_origin is made, then
%                  by default a shift to geometrical center is made.
%  
%   img_shift    - vector specifying displacement of image's origin in Cartesian, i.e.
%                  input ...,'img_shift', [5, -4, 1], ... shifts coordinates
%                  of origin 5 units in x, -4 units in y and 1 unit in z
%                  direction
%
%   stl          - optional logical (scalar 0 or 1 as well) flag specifying if export to 
%                  STL file is to be made. (Default stl = true)
%
%   pov          - optional logical (scalar 0 or 1 as well) flag specifying if export to
%                  PovRay file is to be made. (Default pov = true)
%
%   Options can be entered as: 
%   ExportVoxelData(export_data, ..., 'option_name', option_value, ...)
%
% OUTPUT:
%   none
%
% OUTPUT FILES:
%   A .stl file in the same directory as location of function execution,
%   containing binary definition of mesh describing export_data objects.
%   A PovRay .inc file in the same directory as location of function execution,
%   containing declarations of mesh describing export_data objects
%   individually and declaration of all objects together as object
%   'mesh_name'_all.
%
% In case of any problems, questions or suggestions please send an e-mail
% to one of addresses below:
%
% Author:  Cyprian Lewandowski
% E-mails: cyprian.lewandowski11@imperial.ac.uk
%          cyprian.lewandowski@gmail.com
%
% Last revision: 20.09.2013
%

% Parse input arguments
p = ParseInput(export_data, varargin{:});

% If Resampling is performed and N_MeshResample does not exists, then download
% the necessary content.
% Resampling part of the package cannot be included into MathWorks.com submission, 
% as iso2mesh operates under GNU license which is not supported.
if (p.resample ~= 1) && (~(exist('N_MeshResample.m','file') == 2))
    fprintf('*** Downloading and unpacking resampling content... ***\n');
    urlwrite('https://drive.google.com/uc?export=download&id=0BybuboAGRbuvMU80VFpMRVA1Zzg','Mesh_Resample_Content.zip');
    unzip('Mesh_Resample_Content.zip');
    delete('Mesh_Resample_Content.zip');
end

% Check what smoothing input is given
if isstruct(p.smoothing) % A structure is present i.e smoothing is performed
    
    % Set 'smooth' field to true.
    p.smoothing.smooth = true;
else  % Scalar or logical value of smoothing is given
    % Ensure that p.smoothing is logical
    p.smoothing = logical(p.smoothing);
    
    % Convert to structure format with the field smooth (i.e. whether to
    % smooth) set to either false or true depending on input and default settings)
 
    p.smoothing = struct('mode',1,'itt',1,'lambda',1,'sigma',1,'smooth', p.smoothing);
end

if p.smoothing.smooth % Smoothing is performed
    % Add bin folder to Matlab's check pack
    addpath('bin');
    
    % Check if required compiled mex files are present and up-to-date if
    % not then compile
    check_mex_compiled('-largeArrayDims','smoothpatch_curvature_double.c');
    check_mex_compiled('-largeArrayDims','smoothpatch_inversedistance_double.c');
    check_mex_compiled('-largeArrayDims','vertex_neighbours_double.c');
end

% Check if Label_Matrix will be required
if strcmp(p.method, 'isosurface') || strcmp(p.method, 'geometric') % In case if isosurface or geometric method is used
    label_matrix_required = true;
else
    label_matrix_required = false;
end

% Check type of export_data
if ~isstruct(p.export_data) % Not a list of voxels
        
    if  (islogical(p.export_data) && ( ndims(p.export_data) == 3 )) % BW image
        disp('*** BW image inputed as export data ***');
        
        % Find connected components
        disp('*** Determining connected components... ***');
        connected_components = bwconncomp(p.export_data);
        
        % Determine region properties
        disp('*** Determining region properties... ***');
        Region_Props = regionprops(connected_components, 'Area','PixelList','BoundingBox','Centroid');
        
        if label_matrix_required % Create label_matrix if required
            disp('*** Creating Label Matrix... ***');
            Label_Matrix = labelmatrix(connected_components);
        end
            
    elseif ndims(p.export_data) == 3  % Label Matrix
        disp('*** Label Matrix inputed as export data ***');
        
        % Determine region properties
        disp('*** Determining region properties... ***');
        Region_Props = regionprops(p.export_data, 'Area','PixelList','BoundingBox','Centroid');
        
        if label_matrix_required % In case if isosurface or geometric method is used, set Label_Matrix
            disp('*** Copying Label Matrix... ***');
            Label_Matrix = p.export_data;
        end
    else
        disp('*** Wrong export data format ***');
        p.method = 'error';
    end
    
elseif isstruct(p.export_data) % Region Props inputed
    disp('*** Region Properties inputed as export data ***');
    
    Region_Props = p.export_data;
    
    if label_matrix_required && isequal(p.Label_Matrix, 0)  % In case if isosurface method is used and Label Matrix is not inputed
        disp('*** No Label Matrix is present ***');
        
        % Check if custom Object_IDs array is given
        if isequal(p.object_ids, 0)
            p.object_ids = 1 : size(Region_Props,1); % i.e. use all detected regions
        end
 
        Label_Matrix = CreateLabelMatrix(Region_Props, p.object_ids, p.img_dim);
        
    else
        Label_Matrix = p.Label_Matrix;
        p = rmfield(p,'Label_Matrix');
    end
    
else
    disp('*** Wrong export data format ***');
    p.method = 'error';
end

% Remove export_data from structure and memory
p = rmfield(p,'export_data');

% Check if inputed Region_Props contains 'BoundingBox' for the required
% cases
if label_matrix_required && ~isfield(Region_Props,'BoundingBox')
    
    disp('*** Regenerating Region Properties... ***');
    
    % Regenerate required Region_Props structure
    Region_Props = regionprops(Label_Matrix, 'Area','PixelList','BoundingBox','Centroid');
    
    % Remove empty fields
    empty_elements = arrayfun(@(x) isempty(x.Area),Region_Props);
    Region_Props(empty_elements)=[];
    
end

% Check if custom Object_IDs array is given and if not then generate a default
% (This was alrady checked once, but
% this is global)
if isequal(p.object_ids, 0)
    p.object_ids = 1 : size(Region_Props,1); % i.e. use all detected regions
end

% Set origin shift to be made if only img_dim is inputed and shift_origin
% is not inputed as not to compute
if any(p.img_dim ~= 0) && (p.shift_origin ~= 0)
    p.shift_origin = 1;
elseif p.shift_origin == 0
    p.img_dim = [0, 0, 0];
end

% If image dimensions were not inputed estimate them  
if all(p.img_dim == 0) && (p.shift_origin == 1)
    
    p.img_dim = DetermineMatrixDimensions(Region_Props);

end

% Estimate new origin
origin = p.img_dim / 2;
  
% Shift to Cartesian Coordinates (Note: This is not really necessary for XY symmetric images)
origin = [ origin(2), origin(1), origin(3) ];

% Add img_shift if required (Sign due to subtraction of origin later on)
origin = origin - p.img_shift;

% Check if directory exists
if ~isempty(p.output_dir) % Do not check if root directory
    if ~(exist(p.output_dir,'dir') == 7) % Folder does not exist
        mkdir(p.output_dir)
    end
    
    fprintf('*** Saving output in: %s ***\n', p.output_dir);
end

% Open a file streams
% STL
if p.stl && ~strcmp(p.method, 'error')
    stl_loc  = fullfile(p.output_dir, p.mesh_name);
    stl_file = fopen([stl_loc '.tmp'],'w'); % Temporary file stream
else
    stl_file = 0;
end

% POV
if p.pov && ~strcmp(p.method, 'error')
    pov_loc  = fullfile(p.output_dir, p.mesh_name);
    pov_file = fopen([pov_loc '.inc'],'w');
    
    % Include comments in Pov file
    fprintf(pov_file, '// Individual cells\n\n');
    
else
    pov_file = 0;
end

% Total number of faces exported (See help N_StlMakeFile for explanation)
total_faces = 0;

disp('*** Starting Voxel Data export... ***');

% Determine mesh execution method
switch p.method
    case 'convhull'
        
        % Create waitbar
        h = waitbar(0,'1','Name','Exporting mesh...',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
        
        waitbar(0, h, sprintf('Starting exporting process...'));
        
        for i = 1 : length(p.object_ids) % Loop over all object
            
            %Check for Cancel button press
            if getappdata(h,'canceling')
                break
            end
            
            % Output progress in the waitbar's message field
            waitbar(i/length(p.object_ids),h, sprintf('Object %u / %u ', i, length(p.object_ids)));
              
            % Export an object
            num_faces = N_3DAddVoxelDataConvexHull(Region_Props(p.object_ids(i)).PixelList, strcat(p.mesh_name, '_', num2str(i)), p.resample, p.smoothing, stl_file, pov_file, origin);
            
            % Add to number of faces exported
            total_faces = num_faces + total_faces;
  
        end
        
        % Delete the waitbar
        delete(h)
        
    case 'isosurface'
        
        % Create waitbar
        h = waitbar(0,'1','Name','Exporting mesh...',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
        
        waitbar(0, h, sprintf('Starting exporting process...'));
        
        for i = 1 : length(p.object_ids) % Loop over all objects
            
            %Check for Cancel button press
            if getappdata(h,'canceling')
                break
            end
            
            % Output progress in the waitbar's message field
            waitbar(i/length(p.object_ids),h, sprintf('Object %u / %u ', i, length(p.object_ids)));
              
            % Extract particle boundaries and check if upper bounds do not
            % exceed boundaries
            %(Note: BoundingBox outputs in Cartesian coordinates)
            row_bottom = round(Region_Props(p.object_ids(i)).BoundingBox(2));
            row_top    = CheckBound( round(Region_Props(p.object_ids(i)).BoundingBox(2) + Region_Props(p.object_ids(i)).BoundingBox(5)), size(Label_Matrix,1));

            column_bottom = round(Region_Props(p.object_ids(i)).BoundingBox(1));
            column_top    = CheckBound( round(Region_Props(p.object_ids(i)).BoundingBox(1) + Region_Props(p.object_ids(i)).BoundingBox(4)), size(Label_Matrix,2));
        
            z_bottom = round(Region_Props(p.object_ids(i)).BoundingBox(3));
            z_top    = CheckBound( round(Region_Props(p.object_ids(i)).BoundingBox(3) + Region_Props(p.object_ids(i)).BoundingBox(6)), size(Label_Matrix,3));
            
            % Extract that part of the Label_Matrix
            LM_extracted = Label_Matrix(row_bottom : row_top, column_bottom : column_top, z_bottom : z_top);
            
            % Eliminate objects not in interest
            LM_extracted(LM_extracted ~= p.object_ids(i)) = 0;
            
            % Compute location of BoundingBox corner in Cartesian Coordinates
            box_corner = [column_bottom row_bottom z_bottom];
        
            % Compute and export IsoSurface mesh
            num_faces = N_3DAddVoxelDataIsoSurface(LM_extracted > 0, box_corner, [p.mesh_name '_' num2str(i)], p.resample, p.smoothing, stl_file, pov_file, origin);
         
            % Add to number of faces exported
            total_faces = num_faces + total_faces;
           
        end
        
        % Delete the waitbar
        delete(h)
    
    case 'geometric' 
        
        % Create waitbar
        h = waitbar(0,'1','Name','Exporting mesh...',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(h,'canceling',0)
        
        waitbar(0, h, sprintf('Starting exporting process...'));
        
        for i = 1 : length(p.object_ids) % Loop over all objects
            
            %Check for Cancel button press
            if getappdata(h,'canceling')
                break
            end
            
            % Output progress in the waitbar's message field
            waitbar(i/length(p.object_ids),h, sprintf('Object %u / %u ', i, length(p.object_ids)));
              
            % Extract particle boundaries and check if upper bounds do not
            % exceed boundaries
            %(Note: BoundingBox outputs in Cartesian coordinates)
            row_bottom = round(Region_Props(p.object_ids(i)).BoundingBox(2));
            row_top    = CheckBound( round(Region_Props(p.object_ids(i)).BoundingBox(2) + Region_Props(p.object_ids(i)).BoundingBox(5)), size(Label_Matrix,1));

            column_bottom = round(Region_Props(p.object_ids(i)).BoundingBox(1));
            column_top    = CheckBound( round(Region_Props(p.object_ids(i)).BoundingBox(1) + Region_Props(p.object_ids(i)).BoundingBox(4)), size(Label_Matrix,2));
        
            z_bottom = round(Region_Props(p.object_ids(i)).BoundingBox(3));
            z_top    = CheckBound( round(Region_Props(p.object_ids(i)).BoundingBox(3) + Region_Props(p.object_ids(i)).BoundingBox(6)), size(Label_Matrix,3));
            
            % Extract that part of the Label_Matrix
            LM_extracted = Label_Matrix(row_bottom : row_top, column_bottom : column_top, z_bottom : z_top);
            
            % Eliminate objects not in interest
            LM_extracted(LM_extracted ~= p.object_ids(i)) = 0;

            % Compute location of BoundingBox corner in Cartesian Coordinates
            box_corner = [column_bottom row_bottom z_bottom];
        
            % Compute and export geometric mesh
            num_faces = N_3DAddVoxelDataGeometric(LM_extracted > 0, box_corner, [p.mesh_name '_' num2str(i)], p.resample, p.smoothing, stl_file, pov_file, origin);
         
            % Add to number of faces exported
            total_faces = num_faces + total_faces;
            
        end
        
        % Delete the waitbar
        delete(h)
       
    otherwise % The error case
        disp('*** No data has been exported ***');
end
     
% Make STL format file
if stl_file >= 3
    disp('*** Concluding STL data export... ***');
    N_StlMakeFile(stl_file, p.mesh_name, stl_loc, total_faces);
end

% Make POV file and export all objects as a single object
if pov_file >= 3
   disp('*** Concluding PoV data export... ***');
   
    % Include comments in PoV file
    fprintf(pov_file, '// All cells as a single object\n\n');

    % Output all particles as a single object
    fprintf(pov_file,['#declare ' p.mesh_name '_all =\tunion{\n' ]);

    % Loop over all particles
    for i = 1 : size(Region_Props,1)
    
        fprintf(pov_file,['\t\t\t\t\t\t\t\tobject{ ' p.mesh_name '_' num2str(i) ' }\n' ]);
    
    end

    % Nice formatting :)
    fprintf(pov_file,'\t\t\t\t\t\t\t\t}\n');

    % Close file
    fclose(pov_file);
end

disp('*** ExportVoxelData is finished ***');

end

% ParseInput
function [ parsed_input ]  = ParseInput(export_data, varargin)

% Parse inputs
p = inputParser;

% export_data
check_export_data = @(x) ~isempty(x); % just a dummy validate method
addRequired(p, 'export_data', check_export_data);

% mesh_name
default_mesh_name = 'matlab_mesh';
addParamValue(p, 'mesh_name', default_mesh_name, @ischar);

% output_dir
default_output_dir = '';
addParamValue(p, 'output_dir', default_output_dir, @ischar);

% method
default_method = 'isosurface';
valid_methods  = {'convhull','isosurface','geometric'};
check_method   = @(x) any(validatestring(x, valid_methods));
addParamValue(p, 'method', default_method, check_method);

% resample
default_resample = 1;
addParamValue(p, 'resample', default_resample, @isscalar);

% smoothing
default_smoothing = struct('mode',1,'itt',1,'lambda',1,'sigma',1); % See help ExportVoxelData for description of each
check_smoothing   = @(x) isstruct(x) || islogical(x) || isscalar(x); 
addParamValue(p, 'smoothing', default_smoothing, check_smoothing);

% Label_Matrix
default_label_matrix = 0;
check_label_matrix   = @(x) ndims(x) == 3;
addParamValue(p, 'Label_Matrix', default_label_matrix, check_label_matrix);

% Objects_IDs
default_object_ids = 0;
addParamValue(p, 'object_ids', default_object_ids, @isvector);

% shift_origin
default_shift_origin = -1;
addParamValue(p, 'shift_origin', default_shift_origin, @isscalar);

% img_dim
default_dim = [0, 0, 0];
addParamValue(p, 'img_dim', default_dim, @isvector);

% img_shift
default_img_shift = [0, 0, 0];
addParamValue(p, 'img_shift', default_img_shift, @isvector);

% Output to STL file
default_stl  = true;
check_option = @(x) islogical(x) || isscalar(x);
addParamValue(p, 'stl', default_stl, check_option);

% Output to POV file
default_pov = true;
addParamValue(p, 'pov', default_pov, check_option);

% Parse input
parse(p, export_data, varargin{:});

% Output results
parsed_input = p.Results; 
end

% Function for checking if a mex file is compiled for the system and is
% up-to-date. 
% Source: 
% http://www.mathworks.de/matlabcentral/fileexchange/27140-check-whether-mex-file-is-compiled-for-system

function check_mex_compiled(varargin)
% Check if mex file is compiled for system
% 
%   check_mex_compiled(source_file)
%   check_mex_compiled(options,source_file)
% 
%   check_mex_compiled(source_file) checks whether a mex
%   source file source_file is compiled for the current
%   operating system OR whether the source file has been
%   modified since it was compiled. It is compiled if it
%   does not pass these tests (to the same directory as the
%   source file). source_file must be a string that is the
%   name of a source file on the MATLAB search path.
% 
%   check_mex_compiled(options,source_file) passes the
%   script switches in options to the mex compiler, one
%   argument per switch.
% 
%   Example
% 
%       % check function compiled, with debugging info, and
%       % with large-array-handling API
%       check_mex_compiled('-g','-largeArrayDims','myfun.c')
% 
% See also MEX.

% !---
% ==========================================================
% Last changed:     $Date: 2012-01-17 15:15:36 +0000 (Tue, 17 Jan 2012) $
% Last committed:   $Revision: 100 $
% Last changed by:  $Author: mu31ch $
% ==========================================================
% !---

source_file = varargin{end};

% Check input filename
if ~ischar(source_file)
    error('source_file: must be a string')
end

% Check extension is specified
if isempty(strfind(source_file,'.'))
    error('source_file: no file extension specified')
end

% Locate source file
[pathstr,name,ext] = fileparts(which(source_file));

filename = [pathstr filesep name ext]; % Create filename
mexfilename = [pathstr filesep name '.' mexext]; % Deduce mex file name based on current platform

if strcmp(pathstr,'') % source file not found
    error([source_file ': not found'])
elseif exist(mexfilename,'file')~=3 || get_mod_date(mexfilename)<get_mod_date(filename)
     % if source file does not exist or it was modified after the mex file
    disp(['Compiling "' name ext '".'])
    d = cd;
    cd(pathstr)
    % compile, with options if appropriate
    if length(varargin)>1
        options = varargin{1:end-1};
        mex(options,source_file)
    else
        mex(source_file)
    end
    disp('Done.')
    cd(d)
end

end
% ----------------------------------------------------------
% Local functions:
% ----------------------------------------------------------

% ----------------------------------------------------------
% get_mod_date: get file modified date
% ----------------------------------------------------------
function datenum = get_mod_date(file)
d = dir(file);
datenum = d.datenum;
end

% end of check_mex_compiled()

function [ Upper_Bound ] = CheckBound(Upper_Bound, max_value )
%CheckBound checks if upper boundary exceeds matrix dimensions specified
%             by max_value
%
%   INPUT:
%       Upper_Bound - estimated value of upper bound prior to checking
%       max_value   - maximum index of the image
%
%   OUTPUT:
%       Upper_Bound - value of upper bound that does not exceed matrix
%                     dimensions
%

if( Upper_Bound > max_value)
    Upper_Bound = max_value;
end

end

function [ dim ] = DetermineMatrixDimensions(Region_Props)
%DetermineMatrixDimensions finds boundaries of a matrix containing objects
%                          specified with Region_Props.PixelList
%
% INPUT:
%   Region_Props - structure as outputed by regionprops with a field
%                  PixelList containing Cartesian Coordinates of all white pixels for a
%                  given object in the matrix
%
% OUTPUT:
%   dim          - vector estimating dimensions of the matrix in matrix
%                  coordinates (i.e. dim(1) = row max, dim(2) = col max, dim(3) = z max)
%

% Preallocate dummy max_row, max_col, max_z matrices
max_row = zeros(size(Region_Props,1),1);
max_col = zeros(size(Region_Props,1),1);
max_z   = zeros(size(Region_Props,1),1);

% Loop over all pixels to find bounds
disp('Determining Image Matrix dimensions...');

for i = 1 : size(Region_Props,1)
    
    % Extract list of pixels
    % Note: PixelList is in Cartesian Coords
    pixels = Region_Props(i).PixelList;
    
    % Find maxima for each region
    max_row(i) = max(pixels(:,2));
    max_col(i) = max(pixels(:,1));
    max_z(i)   = max(pixels(:,3));
    
end

% Determine dimensions
dim_row = max(max_row(:));
dim_col = max(max_col(:));
dim_z   = max(max_z(:));

% Output
dim = [dim_row, dim_col, dim_z];

end

function [ Label_Matrix ] = CreateLabelMatrix(Region_Props, object_ids, img_dim)
% CreateLabelMatrix reconstructs Label Matrix from PixelList contained in
%                   Region_Props.
%
% INPUT:
%   Region_Props - structure containing properties of regions among them
%                  PixelList, that is a list of xyz coordinates of each voxel in the
%                  region.
%   object_ids   - array with ids of objects, so that they can be
%                  referenced to. It is not strictly required for local Label_Matrix
%                  reconstruction, but it is introduced to maintain compatibility with
%                  remainder of the script.
%   img_dim      - vector specifying dimensions of the Label Matrix. If
%                  inputed as a zero vector, it is treated as default option and
%                  dimensions of the matrix are estimated
%
% OUTPUT:
%   Label_Matrix - reconstructed Label_Matrix from PixelLists
%

% Estimate Label Matrix dimensions if inputed as default
if all(img_dim == 0)
    [ img_dim ] = DetermineMatrixDimensions(Region_Props);
end

% Maximum object id
max_id = max(object_ids);

% Determine class of the Label_Matrix
if max_id <= 255
    label_matrix_class = 'uint8';
elseif max_id <= 65535
    label_matrix_class = 'uint16';
elseif max_id <= (2^32-1)
    label_matrix_class = 'uint32';
else
    label_matrix_class = 'double';
end

% Preallocate Label_Matrix
Label_Matrix = zeros(img_dim(1), img_dim(2), img_dim(3), label_matrix_class);

disp('Creating Label Matrix...');

% Create Label_Matrix
for i = 1 : size(Region_Props,1)
    
    % Extract list of pixels
    % Note: PixelList is in Cartesian Coords
    pixels = Region_Props(i).PixelList;
    
    % Set active region
    region_id = object_ids(i);
    
    % Write each pixel
    for j = 1 : size(pixels,1)
        Label_Matrix(pixels(j,2), pixels(j,1), pixels(j,3)) = region_id;
    end
    
end

disp('Label Matrix generated');

end
