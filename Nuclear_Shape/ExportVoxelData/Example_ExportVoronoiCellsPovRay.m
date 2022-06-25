%% Export Voronoi Cells and Particles to Pov Only
% This script exports Particles (and their Voronoi cells) specified in array particles_to_export to 
% .inc files and generates a simple PovRay scene with colors of Voronoi
% Cells showing variation from mean value. 

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
ExportVoxelData(Particle_Properties_Corrected(particles_to_export),... % Voxel List
                'mesh_name','particle',... % Name of exported mesh
                'stl',false,... % No output to stl file
                'label_matrix',Label_Matrix_Corrected,... % Input Label Matrix
                'object_ids',particles_to_export,... % Choose just some particles to export
                'method','isosurface',... % Explicit selection of mesh extraction method
                'resample',1); % Explicit declaration of no resampling

%% Export Voronoi Cells declaration
ExportVoxelData(Voronoi_Properties_Corrected(particles_to_export),... % Voxel list
                'mesh_name','voronoi_cell',... % Name of exported mesh
                'method','isosurface',... % Explicit declaration of mesh extraction method
                'stl',false,... % No stl output
                'label_matrix',Voronoi_Cells_Corrected,... % Input Label Matrix
                'object_ids',particles_to_export,... % Choose just some voronoi cells to export
                'resample',0.5); % Reduce mesh size by resampling
            
%% Color coding packing fraction

ExportObjectsPovRayScene