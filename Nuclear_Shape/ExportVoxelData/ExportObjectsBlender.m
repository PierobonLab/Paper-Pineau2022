%% Export Objects Blender
% This package creates a .txt file with description of exported objects from
% ExportVoxelData.m and colors them according to matrix color_criteria.
% Exported txt file can then be used in batch import addon in Blender
%
% Requires: Label_Matrix, a matrix for defining color_criteria (e.g.
%          Region_Props.Area)
%

% Define parmeters of the export
file_name = 'matlab_export';
mesh_name = 'Blender_VC';
dim       = size(Label_Matrix_Corrected);

% Property used for coloring
color_criteria = Local_Packing_Fraction_Corrected(particles_to_export);

% Create mesh_list of objects to export with coloring as a function of a given parameter

% Parameters of the mesh_list
alpha             = 0.4;
number_of_bins    = 100; % Number of bins used for grouping of colour_criteria
color_compression = 0.1; % compression of color histogram (0 no, 1 maximal(binary))
mesh_list = N_StlCreateMeshList(mesh_name, color_criteria, color_compression, number_of_bins, alpha);

% Add particles to the mesh list (no coloring)
num_vc = size(mesh_list,2);
mesh_list(num_vc+1).name     = 'Blender_particle';
mesh_list(num_vc+1).rgb      = [1, 1, 0];
mesh_list(num_vc+1).transmit = 1;

% Scaling Settings (Empirical Value) 
blender_max_coord = 3; % Assuming equal aspect ratio
scaling_factor = repmat(blender_max_coord / (dim(1)/2), 1, 3); % Assume equal scaling

% Create the blender_configuration structure
blender_configuration.file_name      = file_name;
blender_configuration.scaling_factor = scaling_factor;

% Export the properties file
N_StlExportToBlender(blender_configuration, mesh_list);
