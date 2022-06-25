function [ ] = N_StlExportToBlender( blender_configuration, mesh_list )
%N_StlExportToBlender exports a configuration .txt file that can be used by 
%                     the batch STL import addon (io_mesh_stl_batch) to import
%                     STL files with given color and transparency into Blender.
%
% INPUT:
%   blender_configuration - a structure which specifies properties of the
%                           exported Blender configuration file. The structure should
%                           contain fields:
%                               'file_name'      - string specifying output
%                                                  file name
%                               'scaling_factor' - a vector defining scaling of exported 
%                                                  objects (in X Y Z), used within Blender 
%                                                  to make them fit the Blender default 
%                                                  scene size
%                           
%   mesh_list             - structure containing mesh parameters. Following fields 
%                           are required:
%                               'name'  - string with the name of the object (as
%                                         declared in .inc file)
%                               'rgb'   - 1-by-3 vector with entries from 0 to 1 defining
%                                         rgb color to be used for the object
%                               'alpha' - scalar value from 0 to 1 describing how
%                                         transparent an object is. (i.e 1 opaque, 0
%                                         transparent) 
%
% OUTPUT:
%   none
%
% OUTPUT FILES:
%   A .txt configuration file located at the place of script execution.
%   
%   Configuration file structure (See code below for variables' description):
%       sf(1) sf(2) sf(3)
%       mesh_list(1).name mesh_list(1).rgb(1) mesh_list(1).rgb(2) mesh_list(1).rgb(3) mesh_list(1).alpha
%       mesh_list(2).name mesh_list(2).rgb(1) mesh_list(2).rgb(2) mesh_list(2).rgb(3) mesh_list(2).alpha
%       ... until all objects are included.
%

% Open a file stream
file_name           = strcat(blender_configuration.file_name,'.txt');
configuration_file  = fopen(file_name,'w');

% Dummy variable for ease of notation
sf = blender_configuration.scaling_factor;

% Output the scaling information
fprintf(configuration_file, '%u %u %u\n', sf(1), sf(2), sf(3));

% Add exported objects information
for i = 1 : size(mesh_list,2) % Loop over all objects
    
    fprintf(configuration_file, ...
    '%s %u %u %u %u\n',...
                       mesh_list(i).name,... 
                       mesh_list(i).rgb(1),...
                       mesh_list(i).rgb(2),...
                       mesh_list(i).rgb(3),...
                       mesh_list(i).alpha);
                   
end

% Close file
fclose(configuration_file);

end

