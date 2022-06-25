function [] = N_StlMakeFile(stl_file, mesh_name, stl_loc, total_faces, delete_tmp)
%N_StlMakeFile creates a STL file format description of the mesh.
%
% INPUT:
%   stl_file    - file stream (or a scalar 0 depending if it is active) to stl
%                 output file
%   mesh_name   - string specifying name to used for the mesh
%   stl_loc     - string specifying location of the output file
%   total_faces - total number of faces of the outputted mesh. (0
%                 corresponds to ascii format. % See help N_StlAddMesh for explanation) 
%   delete_temp - Optional scalar, which specifies if temporary STL file
%                 with vertices should be removed. (Default 1 == Removed)
%
% OUTPUT:
%   none
%
% OUTPUT FILES:
%   STL file in stl_loc.stl containing description of the mesh
%

% Check if delete_tmp is set
if ~exist('delete_tmp','var')
    delete_tmp = 1; % Delete temporary file by default
end

% Close current stl_file file stream
fclose(stl_file);

% Reopen data file with reading permission
stl_file = fopen([stl_loc '.tmp'],'r');

% Check if ascii mode was used
if total_faces == 0 

    % Read in the data
    tmp_data = fscanf(stl_file,'%c');
    
    % Close temp_file data
    fclose(stl_file);
    
    % Open new file stream to STL format file
    stl_file  = fopen([stl_loc '.stl'],'w');
    
    % Write header
    fprintf(stl_file,'solid %s\r\n', mesh_name);
    
    % Append tmp_data containing faces description
    fprintf(stl_file, tmp_data);
    
    % Write footer
    fprintf(stl_file,'endsolid %s\r\n',mesh_name);
 
else %  Binary mode

    % Read in the data
    tmp_data = fread(stl_file, inf, 'uint16');
    
    % Close temp_file data
    fclose(stl_file);
    
    % Open new file stream to STL format file
    stl_file  = fopen([stl_loc '.stl'],'w');
    
    % Write header
    fprintf(stl_file, '%-80s', 'Test');       % Title of the mesh
    fwrite(stl_file, total_faces, 'uint32');  % Number of faces
    
    % Append tmp_data containing faces description
    fwrite(stl_file,tmp_data,'uint16');
      
end

% Close the file stream
fclose(stl_file);
    
% Delete temporary file
if delete_tmp
    delete([stl_loc '.tmp']);
end 

end