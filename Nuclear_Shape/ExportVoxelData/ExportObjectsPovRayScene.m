%% Export Objects PovRay Scene
% This package creates a PovRay Scene with exported objects from
% ExportVoxelData.m and colors them according to matrix color_criteria.
%
% Requires: Label_Matrix, a matrix for defining color_criteria (e.g.
%          Region_Props.Area)
%

% Define parmeters of the export
scene_name = 'matlab_scene';
mesh_name  = 'voronoi_cell';
dim        = size(Label_Matrix_Corrected);

% Property used for coloring
color_criteria = Local_Packing_Fraction_Corrected(particles_to_export);

% Create a cell array of strings with names of .inc files, such as texture
% files etc. File containing definition of objects (particle.inc) will be added
% automatically.
include_files = {'colors','particle'};

% Create mesh_list of objects to export with coloring as a function of a given parameter

% Parameters of the mesh_list
transmit          = 0.4;
texture_name      = '';
number_of_bins    = 100; % Number of bins used for grouping of colour_criteria
color_compression = 0.1; % compression of color histogram (0 no, 1 maximal(binary))
mesh_list = N_PovCreateMeshList(mesh_name, color_criteria, color_compression, number_of_bins, transmit, texture_name);

% Add file with object meshes to the list
include_files = [ include_files mesh_name ];

% Create PovRay scene configuration
pov_configuration.scene_name      = scene_name;
pov_configuration.include_files   = include_files;
pov_configuration.camera_location = [ round(dim(2)/2), round(dim(1)/2), -(dim(3)+200) ]; % Camera location
pov_configuration.camera_look_at  = [ round(dim(2)/2), round(dim(1)/2), round(dim(3)/2) ]; % Camera look at

% Add PovRay ligth sources

% Preallocate
pov_configuration.light_source = zeros(4,3); % Four light sources

% Add light sources
pov_configuration.light_source(1,:) = [ dim(2)+20, dim(1)+20, dim(3)+20 ];
pov_configuration.light_source(2,:) = [ 1, dim(1)+20, dim(3)+20 ];
pov_configuration.light_source(3,:) = [ dim(2)+20, 1, dim(3)+20 ];
pov_configuration.light_source(4,:) = [ dim(2)+20, dim(1)+20, 1 ];

% Create PovRay Scene
N_PovCreateScene(pov_configuration, mesh_list);
