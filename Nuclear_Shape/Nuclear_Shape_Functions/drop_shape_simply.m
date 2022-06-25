%% shape=nuclear_shape(m,plotresults)
% Compute several geometrical properties of a 3D tif stack and plot the
% interpolated mesh structure. Save results in a structure "shape"
%  NB: all results are in pixel (assumed implicitely dx=dy=dz=1)
% INPUT:
%     m: 3D tif file (read by importTIF), best results for 8 bit files
%     plotresults( opt) : binary, if 1 plot the computed shape in the less smooth form
% OUTPUT:
%    shape: structure containing both structural properties (from the
%    binarised image) and differntial quantities (curvature, roughness
%    etc), as well as fv1 fv2 fv3 fv4, four mesh structres of increasing
%    smoothness (0, 5, 10, 80 ).

function shape=drop_shape_simply(m); 

%%%%%%%%%%%%%%
%% Required script/function:
% geom3D
% matImage
% ExportVoxelData
% toolbox_graph
% patchcurvature


% importTIF (PP)
% imEquivalentEllipsoid (from matImage toolbox)
% N_Mesh_Resample (from ExportVoxelData toolbox)
%       (as alternative consider reducepatch from matlab but it is less clear what is the algorithm to reduce data!!)
% N_Smoothmesh (from ExportVoxelData toolbox)
%       (as alternative conside laplacian smoothing changing weight from toolbox_graph)
% area_patch (PP from https://www.mathworks.com/matlabcentral/answers/93023)
% 

%% load file (3D+T)
% m=double(importTIF('~/Documents/project/Judith/decon/test_8RL_interp.tif'));

%% for each time step
%% interpolate for isotropic image



%% smooth with 3x3x3 gaussian and threshold:
m=smooth3(m,'gaussian');
th=multithresh(m);
bw=m>th;

%% simplify shape
% use morphological tools

[xx,yy,zz] = ndgrid(-1:1);
nhood = sqrt(xx.^2 + yy.^2 + zz.^2) <= 1.0;
bw2=imdilate(imerode(imerode(imfill3(imdilate(bw,nhood)),nhood),nhood),nhood);
% bw1=imfill3(bw);
% bw2=imdilate(imerode(bw1, nhood),nhood);
mbw=m.*bw2; 
%% check for bottom upper planes to be empty
% this is not necessary but guarantees compactness of the surface
mbw(:,:,1)=zeros;
mbw(:,:,end)=zeros;

%% compute shape descriptors:
% ellipsoid
[ellipsoid, labels] = imEquivalentEllipsoid(bw2);
% COM
shape.COM=ellipsoid(1:3);
% principal axis
shape.principal_axis=ellipsoid(4:6);
% eigenvectors(columns of the matrix are principal axis of inertia NORMALIZED)
shape.eigvec=eulerAnglesToRotation3d(ellipsoid(7:9));
% rotation euiler angle (deg)
shape.euler_angle=ellipsoid(7:9);
% ellipsoide
shape.ellipsoide=ellipsoid;
% raw area
shape.rawarea=imSurfaceArea(bw2);
% convexity (ratio to convex hull)
shape.convexity=imConvexity(bw2);
% raw volume
shape.vol=sum(bw2(:));


shape=define_emtpy_str(shape);
end
%%%% FUNCTIONS

function [area singlearea]=area_patch(p)
verts = getfield(p, 'vertices');
faces = getfield(p, 'faces');
a = verts(faces(:, 2), :) - verts(faces(:, 1), :);
b = verts(faces(:, 3), :) - verts(faces(:, 1), :);
c = cross(a, b, 2);
singlearea=1/2 * (sqrt(sum(c.^2, 2)));
area = 1/2 * sum(sqrt(sum(c.^2, 2)));
end

% compute the area of the patch associated to a selection of vertex
function area=areaselect(fv,sel);
ring = compute_vertex_face_ring(fv.faces); % compute a cell containing which patch is linked to vertex i
p.vertices=fv.vertices;
p.faces=fv.faces(horzcat(ring{sel(:)'}),:);
[area singlearea]=area_patch(p);
end

function s=define_emtpy_str(s);
s=setfield(s,'totalarea',nan);
s=setfield(s,'meanareapatch',nan);
s=setfield(s,'curvemin',nan);
s=setfield(s,'vertexminpos',nan);
s=setfield(s,'vertexmin',nan);
s=setfield(s,'Cmean_mesh_nratio',nan);
s=setfield(s,'Cmean_area_nratio',nan);
s=setfield(s,'concavity_mesh_nratio',nan);
s=setfield(s,'concavity_area_nratio',nan);
s=setfield(s,'concavity',nan);
s=setfield(s,'rough_dist',nan);
s=setfield(s,'rough_Cmean',nan);
s=setfield(s,'rough_Cgauss',nan);
s=setfield(s,'C1',nan);
s=setfield(s,'C2',nan);
s=setfield(s,'Cmean',nan);
s=setfield(s,'Cgauss',nan);
s=setfield(s,'Ctotmean',nan);
s=setfield(s,'rough_Cgauss',nan);
s=setfield(s,'fv1',nan);
s=setfield(s,'fv3',nan);
s=setfield(s,'fv2',nan);
s=setfield(s,'fv4',nan);
end