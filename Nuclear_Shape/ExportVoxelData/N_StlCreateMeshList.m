function [ mesh_list ] = N_StlCreateMeshList(mesh_name, color_criteria, color_compression, number_of_bins, alpha)
%N_StlCreateMeshList outputs a mesh_list color coded structure that can be
%                    then exported to a .txt properties files that can be
%                    imported with io_mesh_stl_batch addon to Blender.
%
% INPUT:
%   mesh_name         - string giving name of the exported mesh
%   color_criteria    - array used for determination of coloring. Each linear
%                       entry corresponds to a corresponding exported object
%   color_compression - scalar specifying compression of color histogram
%   number_of_bins    - number of bins used in grouping of color_criteria
%                       (Default = 100)
%   alpha             - scalar specifying opacity of an object
%                       (Blender parameter) (Default = 1)
%
%
% OUTPUT:
%   mesh_list - structure containing mesh parameters. Following fields are
%               included:
%                   'name'  - string with the name of the object (as
%                             declared in .inc file)
%                   'rgb'   - 1-by-3 vector with entries from 0 to 1 defining
%                             rgb color to be used for the object
%                   'alpha' - scalar value from 0 to 1 describing how
%                             transparent an object is. (i.e 1 opaque, 0
%                             transparent) 
%

% Check number of bins
if ~exist('number_of_bins','var')
    number_of_bins = 100;
end

% Check transmittance
if ~exist('alpha','var')
    alpha = 1;
end

% Obtain grouped data
min_bin = min(color_criteria);
max_bin = max(color_criteria);
bin_width = (max_bin - min_bin) / number_of_bins;
[n, xout] = hist(color_criteria, min_bin : bin_width : max_bin);
cs = cumsum(n);
cs = cs / cs(end);

% Define minimum and maximum values used for colors
minC = xout(find(cs <= color_compression,1,'last'));
maxC = xout(find(cs >= (1 - color_compression),1,'first'));

% Safety check
if isempty(minC)
    minC = min_bin;
end

if isempty(maxC)
    maxC = max_bin;
end

% Create color map
cmap = colormap(jet(64));
close % Close opening figure

% Compute linear scaling y = a * x + b
a = (length(cmap)-1)/(maxC - minC);
b = (maxC - length(cmap)*minC)/(maxC - minC);

% Make mesh_list (Preallocate)
mesh_list(length(color_criteria)).name = '';

% Add colored objects
for i = 1 : length(color_criteria)
    
    % Name
    mesh_list(i).name    = strcat(mesh_name, '_', num2str(i));
     
    % Color coding
    cmap_index        = round(color_criteria(i) * a + b);
    cmap_index        = CheckBounds(cmap_index, 1, length(cmap));
    mesh_list(i).rgb  = cmap(cmap_index,:);
    
    % Transparency
    mesh_list(i).alpha = alpha;
end

end

% Internal functions
function [ x ] = CheckBounds(x, min_x, max_x)
%CheckBounds checks if a value of x is within given limits, if not it
%            outputs that limit value.
%
% INPUT:
%   x     - value of x prior of checking if within limits
%   min_x - minimum value of x permissible
%   max_x - maximum value of x permissible
%
% OUTPUT:
%   x - checked value of x within limits
%

% Too small
if x < min_x
    
    x = min_x;
    
elseif x > max_x % Too big
    
    x = max_x;
    
end

end

