%% shape=nuclear_shape_drop_movie(fn,nz)
% Iterate the nuclear_shape function on 3D+t file
% Compute several geometrical properties of a 3D tif stack and plot the
% interpolated mesh structure. Save results in a structure "shape"
%  NB: all results are in pixel (assumed implicitely dx=dy=dz=1)
% INPUT (optional):
%     fn: filename of the 3D+t tif file (read by importTIF), best results for 8 bit files
%     nz: number of z of the stack (needed because the input file is nx*ny*(nz*nt) (if not given nz=45)
% OUTPUT:
%    shape: structure (one per time point) containing both structural properties (from the
%    binarised image) and differential quantities (curvature, roughness
%    etc), as well as fv1 fv2 fv3 fv4, four mesh structures of increasing
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


function [nucSh, dropSh, data]=nuclear_shape_drop_movie(fn,nz)

% load file
if nargin<1
    [fn, dn]=uigetfile('*.tif','Select nucleus file');
    filename=fullfile(dn,fn);
    m1=double(importTIF(filename));
    [fn, dn]=uigetfile('*.tif','Select drop file');
    filename2=fullfile(dn,fn);
    m2=double(importTIF(filename2));
    d=inputdlg({'Number of z'},'', 1,{'45'});
    nz=str2num(d{1});

else    
    filename=fn;
    m1=double(importTIF(filename));
    filename2=[fn(1:end-7),'drop.tif'];
    m2=double(importTIF(filename2));
end


if length(size(m1))==3
    ntime=size(m1,3)/nz;
else 
    ntime=size(m1,4);
end

m1=reshape(m1,[size(m1,1), size(m1,2), nz, ntime]);
m2=reshape(m2,[size(m2,1), size(m2,2), nz, ntime]);


% analyse nucleus
%nucSh=nuclear_shape_movie(m1,nz);
parfor t=1:ntime
   nucSh(t)=nuclear_shape(m1(:,:,:,t));
end
%nucSh=correct_ind(nucSh);

disp('ok')
% analyse droplet
%dropSh=drop_shape_movie(m2,nz);
parfor t=1:ntime
   dropSh(t)=drop_shape_simply(m2(:,:,:,t));
end

%dropShape=nuclear_shape_movie(m2,numz); % this gives the isosurface too (much longer)

% analyze dual quantities
data=analyse_nucdrop(nucSh, dropSh);


save([filename(1:end-4) '_NucDropShape.mat'],'nucSh', 'dropSh', 'data');
end

