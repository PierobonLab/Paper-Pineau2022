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

%%  *****************************************************************
%  Copyright 2022 by Paolo Pierobon (CNRS, Institut Curie, PSL Research
%  University, INSERM U932, 26 rue d'Ulm, 75248 Paris, Cedex 05, France.)
%  Email: <pppierobon@gmail.com>
%  
%  Licensed under GNU General Public License 3.0 or later. 
%  Some rights reserved. See COPYING, AUTHORS.
%  @license GPL-3.0+ <http://spdx.org/licenses/GPL-3.0+>
%
%%  *****************************************************************

function shape=nuclear_shape(m,plotresults); 


%% load file (3D+T)
% m=double(importTIF('~/Documents/project/Judith/decon/test_8RL_interp.tif'));

%% for each time step



%% smooth with 3x3x3 gaussian and threshold:
m=medfilt3(m,[5,5,5]); % radius 2
m=smooth3(m,'gaussian'); % 3D gaussian std 1
th=multithresh(m);
bw=m>th;
%disp(['threshold ' num2str(th)]);

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
% convexity (ratio to convex hull, NB works with 3D too!)
shape.convexity=imConvexity(bw2); 
% raw volume
shape.vol=sum(bw2(:));


shape=define_emtpy_str(shape);

%% %%% start computing geometrical properties %%%%%
try % think of a better control e.g. on the distribution of values


%% segment (marching cube or isosurface)
% s=size(m);
% [x,y,z]=meshgrid(1:s(1), 1:s(2), 1:s(3));
% x=permute(x,[2 1 3]); % correct coordinates
% y=permute(y,[2 1 3]);
% z=permute(z,[2 1 3]);
% [F,V,col] = MarchingCubes(x,y,z,mbw,0);

fv = isosurface(mbw,1);

%% simplify mesh (keep 20%)
ratio=1500/length(fv.vertices);
%[fv1.faces, fv1.vertices]=N_MeshResample(fv.faces,fv.vertices,ratio);
fv1 = reducepatch(fv.faces, fv.vertices,ratio);

%% check for consistency (if a point is duplicated or isolated correct)
% for now this just keep the original file
[p,idx, ggg]=unique(sort(fv1.faces')','rows','stable');
if (length(idx)~=size(fv1.faces,1))
   % fv1=correct_faces(fv1);  % wait for a funtioning version
    fv1=fv;
end
% correct the orientation of faces (otherwise the curvature comes out wrong)
fv1.faces(:, [1 2 3])=fv1.faces(:, [2 1 3]);

%% smooth mesh (smoothpatch)
% fv3=smoothpatch(FV,0, 100, 1, 1);

% smooth for realistic representation
[fv2.faces, fv2.vertices]=N_SmoothMesh(fv1.faces, fv1.vertices ,1, 10, 1, 1);
[Cmean2,Cgaussian2,Dir1,Dir2,Lambda21,Lambda22]=patchcurvature(fv2,1);

%ultra smooth for curvature minima search
[fv3.faces, fv3.vertices]=N_SmoothMesh(fv1.faces, fv1.vertices ,1, 20, 1, 1);
[Cmean3,Cgaussian3,Dir1,Dir2,Lambda31,Lambda32]=patchcurvature(fv3,1);

% ultrasmoothing of the whole structure (neg curv might be lost) 
[fv4.faces, fv4.vertices]=N_SmoothMesh(fv1.faces, fv1.vertices ,1, 80, 1, 1);
[Cmean4,Cgaussian4,Dir1,Dir2,Lambda41,Lambda42]=patchcurvature(fv4,1);

% % % % % % % %%%%%%%%%%%%%%
% % % % % % % volume
% % % % % % % change fv names
% % % % % % % save fv
% % % % % % % %%%%%%%%%%%%%


%% compute the curvature on the patch
% options.curvature_smoothing = 1;
% options.verb=0;
% arrange face orientation (positive curvatures are correct)
% [Umin,Umax,Cmin,Cmax,Cmean,Cgauss,Normal] = compute_curvature(fv3.vertices,fv3.faces,options);


% % % %% plot
% % % subplot(1,2,1);
% % % patch(fv3,'FaceColor','interp','FaceVertexCData',Cmean,'edgecolor','none');view(3); camlight; lighting gouraud;
% % % caxis(mean(Cmean)+[-std(Cmean) std(Cmean)])
% % % colorbar
% % % 
% % % c=double((Lambda1<0).*(Lambda2<0)); % concave surface both principal curvature negative
% % % subplot(1,2,2);
% % % patch(fv3,'FaceColor','interp','FaceVertexCData',c,'edgecolor','none');view(3); camlight; lighting gouraud;
% % % caxis([0 1]);




% area patch
shape.totalarea=area_patch(fv2);
shape.meanareapatch=area_patch(fv2)/length(fv2.faces);

%% compute curvature shape descriptor (on fv2!!!)
% position minimal curvature (is it the invag?)
[shape.curvemin vertexmin]=min(Cmean2);
shape.vertexminpos=vertexmin; % index in the vertex matrix
shape.vertexmin=fv2.vertices(vertexmin,:);

% negative curvature (computed on mesh)
shape.Cmean_mesh_nratio=sum(Cmean2<0)/length(Cmean2);                     % computed on the meshes
% negative curvature (computed on area)
shape.Cmean_area_nratio =areaselect(fv2, find(Cmean2<0))/shape.totalarea;  % computed on the real area

% concavity ratio on mesh
c=double((Lambda21<0).*(Lambda22<0)); % concave surface both principal curvature negative
shape.concavity_mesh_nratio=sum(c)/length(Cmean2); 
% concavity ratio on Area
shape.concavity_area_nratio=areaselect(fv2, find(c))/shape.totalarea;  % computed on the real area
% concavity (define as both negative principal curvature) 
shape.concavity=c;


% curvature vectors (computed on fv2)
shape.C1=Lambda21;
shape.C2=Lambda22;
shape.Cmean=Cmean2;
shape.Cgauss=Cgaussian2;
shape.Ctotmean=nanmean(abs(Cmean2));  % 

%% roughness
% roughness is computed as sqrt mean square distance between two surfaces
% at a two different smoothness levels (fv2 and fv4)
v=fv4.vertices-fv2.vertices; % differences are taken on the vertices, should be done on the patches but should not change much
shape.rough_dist=sqrt(nansum(v(:,1).^2+v(:,2).^2+v(:,3).^2)/length(v));
% or as mean of the local gaussian curvature
shape.rough_Cmean=sqrt(nanmean(Cmean2-Cmean4).^2);
shape.rough_Cgauss=sqrt(nanmean(Cgaussian2-Cgaussian4).^2);

%% plot the mesh
if (nargin>1 && plotresults)
   patch_indent(fv3,1,1);    
end

shape.fv1=fv1;
shape.fv2=fv2;
shape.fv3=fv3;
shape.fv4=fv4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TO DO
% study on the effect of smoothing:
% introduce a metric for roughness

catch
    warning('problems');
end
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