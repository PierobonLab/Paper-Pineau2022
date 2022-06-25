%% Manual Data
% Script containing code, which shows each option of the ExportVoxelData
% package.
% Refer to Manual_ExportVoxelData.pdf for detailed discussion of each
% example.

%% Create data
% This cell creates data that is used throughout the Manual_Data script

% Make coordinate system
[X,Y,Z] = meshgrid(-249:250); 

% Nonintersecting objects
% Create empty matrix
BW_NI = false(500,500,500); % Black and White image (logical)

% Add Sphere
BW_NI((X-50).^2+(Y-50).^2+(Z+30).^2 <= 400) = true; 

% Add Ellipsoid
BW_NI((X/20).^2+(Y/50).^2+(Z/100).^2 <= 1) = true; 

% Intersecting Objects
% Create empty matrix
BW_I = false(500,500,500);
LM_I = zeros(500,500,500, 'uint8'); % Label matrix

% Add Sphere
BW_I((X-50).^2+(Y-50).^2+(Z+30).^2 <= 10000) = true; 
LM_I((X-50).^2+(Y-50).^2+(Z+30).^2 <= 10000) = 1; 

% Add Ellipsoid
BW_I((X/20).^2+(Y/50).^2+(Z/100).^2 <= 1) = true;
LM_I((X/20).^2+(Y/50).^2+(Z/100).^2 <= 1) = 2;

% Determine voxel list through finding region properties
RP_I = regionprops(LM_I, 'PixelList');

clear X Y Z
%% Input - Logical - Example 1

ExportVoxelData(BW_NI);

%% Input - Logical - Example 2

ExportVoxelData(BW_I);

%% Input - Label Matrix - Example 3

ExportVoxelData(LM_I);

%% Input - Voxel List - Example 4

ExportVoxelData(RP_I);

%% Mesh Extraction - Convexhull - Example 5

ExportVoxelData(BW_NI, 'method', 'convhull');

%% Mesh Extraction - Convexhull - Example 6

ExportVoxelData(BW_I, 'method', 'convhull');

%% Mesh Extraction - Isosurface - Example 7

ExportVoxelData(BW_I, 'method', 'isosurface');

%% Mesh Extraction - Geometric - Example 8

ExportVoxelData(BW_I, 'method', 'geometric');

%% Mesh Modification - Resampling - Example 9

ExportVoxelData(BW_I, 'resample', 0.2);

%% Mesh Modification - Smoothing - Example 10

ExportVoxelData(BW_I, 'smoothing', false);

%% Mesh Modification - Smoothing - Example 11

ExportVoxelData(BW_I, 'smoothing', struct('mode',1, 'itt',10, 'lambda',1, 'sigma',1));

%% Output - STL only - Example 12

ExportVoxelData(BW_I, 'pov', false);

%% Options - mesh_name - Example 13

ExportVoxelData(BW_I, 'mesh_name', 'new_mesh_name');

%% Options - output_dir - Example 14

ExportVoxelData(BW_I, 'output_dir', 'my_output_folder');

%% Options - label_matrix - Example 15

ExportVoxelData(RP_I, 'label_matrix', LM_I);

%% Options - object_ids - Example 16

ExportVoxelData(LM_I, 'object_ids', 1);

%% Options - shift_origin - Example 17

ExportVoxelData(BW_I, 'shift_origin', 0);

%% Options - shift_origin - Example 18

ExportVoxelData(BW_I, 'shift_origin', 1);

%% Options - img_dim - Example 19

ExportVoxelData(BW_I, 'img_dim', size(BW_I))

%% Options - img_shift - Example 20

ExportVoxelData(BW_I, 'img_shift', [100, 0, 0]);

%% Exporting Voxel Data to PovRay - No colouring - Example 21

% Export only PovRay files
ExportVoxelData(BW_NI, 'stl', false);

% Define parmeters of the export
scene_name = 'matlab_scene'; % Name of created file
mesh_name  = 'matlab_mesh'; % Name of the .inc file
dim        = size(BW_NI); % Dimensions of the image

% Create a cell array of strings with names of other .inc files, such as texture
% files etc, to be included as well apart of the mesh description .inc file
include_files = {'colors'};

% Create mesh_list of objects to export
mesh_list.name = [mesh_name '_all']; % Union of all exported objects is always accesible with
                                     % mesh_name_all
mesh_list.texture  = ''; % No texture
mesh_list.rgb      = [1, 1, 0]; % Set as yellow
mesh_list.transmit = 0;

% Add file with object meshes to the list
include_files = [ include_files mesh_name ];

% Create PovRay scene configuration
pov_configuration.scene_name      = scene_name;
pov_configuration.include_files   = include_files;
pov_configuration.camera_location = [ round(dim(2)/2), round(dim(1)/2), -(dim(3)+200) ]; % Camera location
pov_configuration.camera_look_at  = [ round(dim(2)/2), round(dim(1)/2), round(dim(3)/2) ]; % Camera look at

clear mesh_name scene_name include_files

% Add PovRay ligth sources

% Preallocate
pov_configuration.light_source = zeros(4,3); % Four light sources

% Add light sources
pov_configuration.light_source(1,:) = [ dim(2)+20, dim(1)+20, dim(3)+20 ];
pov_configuration.light_source(2,:) = [ 1, dim(1)+20, dim(3)+20 ];
pov_configuration.light_source(3,:) = [ dim(2)+20, 1, dim(3)+20 ];
pov_configuration.light_source(4,:) = [ dim(2)+20, dim(1)+20, 1 ];

clear dim

% Create PovRay Scene
N_PovCreateScene(pov_configuration, mesh_list);

clear pov_configuration mesh_list

%% Exporting Voxel Data to PovRay - Colouring - Example 22

% Export only PovRay files
ExportVoxelData(BW_NI, 'stl', false);

% Define parmeters of the export
scene_name = 'matlab_scene'; % Name of created file
mesh_name  = 'matlab_mesh'; % Name of the .inc file
dim        = size(BW_NI); % Dimensions of the image

% Create a cell array of strings with names of other .inc files, such as texture
% files etc, to be included as well apart of the mesh description .inc file
include_files = {'colors'};

% Property used for coloring
color_criteria = [1, 2]; % Just two different colours

% Create mesh_list of objects to export with coloring as a function of a given parameter

% Parameters of the mesh_list
transmit          = 0; % Scalar affecting transparency (0 opaque, 1 transparent)
texture_name      = ''; % No texture is being used
number_of_bins    = 2; % Number of bins used for grouping of colour_criteria, in this case it is superficial    
color_compression = 0; % compression of color histogram (0 no, 1 maximal(binary))

% Obtain a structure with color and transparency properties of exporte objects
mesh_list = N_PovCreateMeshList(mesh_name, color_criteria, color_compression, number_of_bins, transmit, texture_name);

clear color_criteria color_compression number_of_bins transmit texture_name

% Add file with object meshes to the list
include_files = [ include_files mesh_name ];

clear mesh_name

% Create PovRay scene configuration
pov_configuration.scene_name      = scene_name;
pov_configuration.include_files   = include_files;
pov_configuration.camera_location = [ round(dim(2)/2), round(dim(1)/2), -(dim(3)+200) ]; % Camera location
pov_configuration.camera_look_at  = [ round(dim(2)/2), round(dim(1)/2), round(dim(3)/2) ]; % Camera look at

clear scene_name include_files

% Add PovRay ligth sources

% Preallocate
pov_configuration.light_source = zeros(4,3); % Four light sources

% Add light sources
pov_configuration.light_source(1,:) = [ dim(2)+20, dim(1)+20, dim(3)+20 ];
pov_configuration.light_source(2,:) = [ 1, dim(1)+20, dim(3)+20 ];
pov_configuration.light_source(3,:) = [ dim(2)+20, 1, dim(3)+20 ];
pov_configuration.light_source(4,:) = [ dim(2)+20, dim(1)+20, 1 ];

clear dim

% Create PovRay SceneN
N_PovCreateScene(pov_configuration, mesh_list);

clear pov_configuration mesh_list

%% Exporting Voxel Data to Blender - No colouring - Example 23

ExportVoxelData(BW_NI, 'pov', false, 'img_dim', size(BW_NI));

%% Exporting Voxel Data to Blender - Separate files with coloring - Example 24

% Export voxel data as separate .stl files only
for i = 1 : 2 % Loop over both objects
    ExportVoxelData(LM_I,...
                    'mesh_name',strcat('Blender_', num2str(i)),...
                    'pov',false,...
                    'object_ids', i,...
                    'img_dim',size(LM_I));
end

clear i

% Define parmeters of the export
file_name = 'matlab_export';
mesh_name = 'Blender'; % Note lack of _
dim       = size(LM_I);

% Property used for coloring
color_criteria = [1, 2];

% Create mesh_list of objects to export with coloring as a function of a given parameter
% Parameters of the mesh_list
alpha             = 0.4; % Transparency affecting factor
number_of_bins    = 2; % Number of bins used for grouping of colour_criteria
color_compression = 0; % compression of color histogram (0 no, 1 maximal(binary))
mesh_list = N_StlCreateMeshList(mesh_name, color_criteria, color_compression, number_of_bins, alpha);

clear color_criteria alpha number_of_bins color_compression mesh_name

% Scaling Settings (Empirical Value) 
blender_max_coord = 3; % Assuming equal aspect ratio
scaling_factor = repmat(blender_max_coord / (dim(1)/2), 1, 3); % Assume equal scaling

clear blender_max_coord dim

% Create the blender_configuration structure
blender_configuration.file_name      = file_name;
blender_configuration.scaling_factor = scaling_factor;

clear file_name scaling_factor

% Export the properties file
N_StlExportToBlender(blender_configuration, mesh_list);

clear blender_configuration mesh_list