%% Export Voronoi Cells and Particles to Blender Only
% This script exports Particles (and their Voronoi cells) specified in array particles_to_export to 
% .stl files and generates a configuration file with colors of Voronoi
% Cells showing variation from mean value.
% Configuration file can be imported to Blender using the Batch import
% addon.

%% Load variables if not present
if ~exist('Voronoi_Cells_Corrected','var')
    load('Example_Voxel_Data');
end

% Variables included
%   - Label_Matrix_Corrected           - label matrix of spaghetti particles
%   - Particle_Properties_Corrected    - structure from regionprops for all
%                                        particles
%   - Voronoi_Cells_Corrected          - label matrix of voronoi cells of those
%                                        spaghetti particles
%   - Voronoi_Properties_Corrected     - structure from regionprops for all
%                                        voronoi cells
%   - particles_to_export              - indices of particles to export
%   - Local_Packing_Fraction_Corrected - array of local packing fractions
%                                        for all particles
%   - Voronoi_Volumes_Corrected        - array of volumes of voronoi cells
%                                        for all particles
%   - Datarecord                       - structure with information about
%                                        border if you would like to find new particles

%% Export Particles as a mesh
ExportVoxelData(Particle_Properties_Corrected(particles_to_export),... % Voxel data
                'mesh_name','Blender_particle',... % Exported file name
                'pov',false,... % No .inc file is being exported
                'object_ids',particles_to_export,... % Export only given particles
                'method','convhull',... % To reduce file size. This is sufficeint as object are simple.
                'img_dim',size(Label_Matrix_Corrected)); % To perform origin shift

%% Export Voronoi Cells declaration (as separate stl files)
for i = 1 : length(particles_to_export) % Loop over all exported object
    ExportVoxelData(Voronoi_Properties_Corrected(particles_to_export(i)),... % Voxel Data
                    'mesh_name',strcat('Blender_VC', num2str(i)),... % File name. Note the file naming convention
                    'method','isosurface',... % Included to point out difference wrt particle export
                    'pov',false,... % No .inc file
                    'label_matrix',Voronoi_Cells_Corrected,... % Label Matrix is provided to speed up export
                    'object_ids',particles_to_export(i),... % Export only selected particle from the list
                    'img_dim',size(Label_Matrix_Corrected),... % Perform origin shift
                    'resample',0.5); % Reduce output file size
end
            

%% Perform color coding on packing fraction

ExportObjectsBlender