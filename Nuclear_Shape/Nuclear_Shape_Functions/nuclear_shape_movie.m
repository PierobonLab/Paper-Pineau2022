%% shape=nuclear_shape_movie
% Iterate the nuclear_shape function on 3D+t file
% Compute several geometrical properties of a 3D tif stack and plot the
% interpolated mesh structure. Save results in a structure "shape"
% Can be simply called by shape=nuclear_shape_movie
%  NB: all results are in pixel (assumed implicitely dx=dy=dz=1)
% INPUT:
%     m: 3D+t tif file (read by importTIF), best results for 8 bit files
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

function shape=nuclear_shape_movie(m,nz,dropdata,fileout)
if nargin<1
    [fn, dn]=uigetfile('*.tif');
    filename=fullfile(dn,fn);
    m=double(importTIF(filename));
end
if nargin<2
    d=inputdlg({'Number of z'},'', 1,{'45'})
    nz=str2num(d{1});
end
if length(size(m))==3
    ntime=size(m,3)/nz;
else
    ntime=size(m,4);
end
m=reshape(m,[size(m,1), size(m,2), nz, ntime]);



if length(size(m))==3
    ntime=size(m,3)/nz;
else
    ntime=size(m,4);
end
m=reshape(m,[size(m,1), size(m,2), nz, ntime]);
parfor t=1:ntime
    t
    shape(t)=nuclear_shape(m(:,:,:,t));
end

if ((nargin>=3) && dropData) 
    [xDrop, yDrop, zDrop]= importDropData([filename(1:end-8) 'DropCOM.txt']);
    for t=1:length(shape)
        shape(t).xDrop=xDrop(t);
        shape(t).yDrop=yDrop(t);
        shape(t).zDrop=zDrop(t);
    end
else
    shape(t).xDrop=NaN;
    shape(t).zDrop=NaN;
    shape(t).zDrop=NaN;
end
if nargin>=4
    save(fileout,'shape');
end
