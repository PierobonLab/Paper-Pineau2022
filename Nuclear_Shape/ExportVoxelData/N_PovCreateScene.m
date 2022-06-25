function [ ] = N_PovCreateScene(pov_configuration, mesh_list)
%N_PovCreateScene exports a simple scene, which is ready to be rendered using
%                 PovRay. 
%
% Exported scene includes all meshes specified in structure mesh_list (see
% below for structure of mesh_list) and properties of the scene specified
% in pov_configuration structure.
%
% INPUT:
%   pov_configuration - structure containing scene parameters. Following
%                       fields are required:
%                           'scene_name'      - filename of the created scene
%                           'include_files'   - cell string array specifying names
%                                               of .inc files to include
%                           'camera_location' - vector giving location of
%                                               the camera
%                           'camera_look_at'  - vector giving coordinates of
%                                               the point at which camera is directed at
%                           'light_source'    - N-by-3 matrix specifing
%                                               location of each source (out of N) to add
%                      
%
%
%   mesh_list         - structure containing mesh parameters. Following fields are
%                       required:
%                           'name'     - string with the name of the object (as
%                                        declared in .inc file)
%                           'texture'  - optional texture name to be used.
%                                        Empty by default.
%                           'rgb'      - 1-by-3 vector with entries from 0 to 1 defining
%                                        rgb color to be used for the object
%                           'transmit' - scalar value from 0 to 1 describing how
%                                        much of light ray is transmitted. (i.e 0 opaque, 1
%                                        transparent)
%
% OUTPUT:
%   none
%
% OUTPUT FILES:
%   A PovRay scene file .pov located in the place of function execution.
%

% Open a file stream
file_name = strcat(pov_configuration.scene_name,'.pov');
pov_file  = fopen(file_name,'w');

% Include files
for i = 1 : length(pov_configuration.include_files)
    fprintf(pov_file, '#include "%s.inc"\n', cell2mat(pov_configuration.include_files(i)));
end

% Settings
fprintf(pov_file, 'global_settings { assumed_gamma 1 }\n');
fprintf(pov_file, 'background { color rgb < 0.5, 0.5, 0.5 > }\n');

% Camera location

% Dummy variables for ease of notation
loc  = pov_configuration.camera_location;
look = pov_configuration.camera_look_at;

fprintf(pov_file, 'camera {\n\t\tlocation  < %g, %g, %g>\n\t\tlook_at   < %g, %g, %g>\n}\n', loc(1),loc(2), loc(3), look(1), look(2), look(3));

% Add light soures
for i = 1 : size(pov_configuration.light_source,1)
    % Get ligth_source in loop
    ls = pov_configuration.light_source(i,:);
    
    % Output
    fprintf(pov_file, 'light_source { <%g, %g, %g> color White}\n', ls(1), ls(2), ls(3));
end

% Add objects
for i = 1 : size(mesh_list,2) % Loop over all objects
    
    fprintf(pov_file, ...
    'object{\n %s\n texture{ %s pigment{color rgb < %g, %g, %g > transmit %g }}\n}\n',...
                       mesh_list(i).name,... 
                       mesh_list(i).texture,...
                       mesh_list(i).rgb(1),...
                       mesh_list(i).rgb(2),...
                       mesh_list(i).rgb(3),...
                       mesh_list(i).transmit);
                   
end

% Close file
fclose(pov_file);

disp('*** PovRay Scene file created ***');

end

